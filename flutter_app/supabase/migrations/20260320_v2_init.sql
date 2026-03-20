create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create or replace function public.is_workspace_member(target_workspace_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = target_workspace_id
      and wm.user_id = auth.uid()
  );
$$;

create or replace function public.is_workspace_owner(target_workspace_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workspaces w
    where w.id = target_workspace_id
      and w.owner_user_id = auth.uid()
  );
$$;

create or replace function public.handle_new_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do update
    set email = excluded.email,
        display_name = excluded.display_name,
        avatar_url = excluded.avatar_url,
        updated_at = timezone('utc', now());
  return new;
end;
$$;

create or replace function public.handle_new_workspace()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.workspace_members (workspace_id, user_id, role)
  values (new.id, new.owner_user_id, 'owner')
  on conflict (workspace_id, user_id) do update
    set role = excluded.role,
        updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists workspaces (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  description text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  archived_at timestamptz
);

create table if not exists workspace_members (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role text not null default 'member'
    check (role in ('owner', 'admin', 'member', 'viewer')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (workspace_id, user_id)
);

create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces (id) on delete cascade,
  created_by_user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  goal text not null,
  status text not null default 'draft'
    check (status in ('draft', 'planning', 'running', 'review', 'done', 'archived', 'failed')),
  execution_plan jsonb not null default '{}'::jsonb,
  summary text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  archived_at timestamptz
);

create table if not exists agents (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces (id) on delete cascade,
  project_id uuid not null references projects (id) on delete cascade,
  created_by_user_id uuid not null references auth.users (id) on delete cascade,
  agent_key text not null
    check (agent_key in ('orchestrator', 'pm', 'system_designer', 'flutter', 'qa')),
  name text not null,
  role text not null,
  model text not null default 'gpt-5.1',
  instructions text not null default '',
  status text not null default 'active'
    check (status in ('active', 'paused', 'blocked', 'completed', 'failed')),
  sort_order int not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  archived_at timestamptz,
  unique (project_id, agent_key)
);

create table if not exists agent_skills (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces (id) on delete cascade,
  agent_id uuid not null references agents (id) on delete cascade,
  created_by_user_id uuid not null references auth.users (id) on delete cascade,
  skill_key text not null,
  name text not null,
  description text not null default '',
  scope text not null default '',
  version int not null default 1,
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (agent_id, skill_key)
);

create table if not exists conversations (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces (id) on delete cascade,
  project_id uuid not null references projects (id) on delete cascade,
  created_by_user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  mode text not null default 'workflow'
    check (mode in ('workflow', 'support', 'review')),
  context jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  archived_at timestamptz
);

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces (id) on delete cascade,
  project_id uuid not null references projects (id) on delete cascade,
  conversation_id uuid not null references conversations (id) on delete cascade,
  sender_user_id uuid references auth.users (id) on delete set null,
  agent_id uuid references agents (id) on delete set null,
  role text not null
    check (role in ('user', 'assistant', 'system', 'tool')),
  content text not null default '',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces (id) on delete cascade,
  project_id uuid not null references projects (id) on delete cascade,
  agent_id uuid references agents (id) on delete set null,
  created_by_user_id uuid not null references auth.users (id) on delete cascade,
  parent_task_id uuid references tasks (id) on delete set null,
  task_key text not null,
  title text not null,
  type text not null
    check (type in ('plan', 'spec', 'schema', 'ui', 'code', 'qa', 'review', 'sync')),
  status text not null default 'queued'
    check (status in ('queued', 'claimed', 'running', 'blocked', 'completed', 'failed', 'cancelled')),
  priority int not null default 3 check (priority between 1 and 5),
  input jsonb not null default '{}'::jsonb,
  output jsonb not null default '{}'::jsonb,
  error_message text not null default '',
  queued_at timestamptz not null default timezone('utc', now()),
  started_at timestamptz,
  finished_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  archived_at timestamptz,
  unique (project_id, task_key)
);

create table if not exists artifacts (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces (id) on delete cascade,
  project_id uuid not null references projects (id) on delete cascade,
  task_id uuid references tasks (id) on delete set null,
  created_by_user_id uuid not null references auth.users (id) on delete cascade,
  artifact_type text not null
    check (artifact_type in ('execution_plan', 'prd', 'schema', 'ui', 'code', 'qa', 'decision', 'log')),
  title text not null,
  body text not null default '',
  data jsonb not null default '{}'::jsonb,
  storage_path text,
  version int not null default 1,
  checksum text not null default '',
  status text not null default 'draft'
    check (status in ('draft', 'generated', 'reviewed', 'approved', 'rejected')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  archived_at timestamptz,
  unique (project_id, artifact_type, version)
);

create table if not exists tool_runs (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces (id) on delete cascade,
  project_id uuid not null references projects (id) on delete cascade,
  task_id uuid references tasks (id) on delete set null,
  agent_id uuid references agents (id) on delete set null,
  created_by_user_id uuid not null references auth.users (id) on delete cascade,
  tool_name text not null,
  status text not null default 'running'
    check (status in ('queued', 'running', 'succeeded', 'failed', 'cancelled')),
  input jsonb not null default '{}'::jsonb,
  output jsonb not null default '{}'::jsonb,
  error_message text not null default '',
  started_at timestamptz not null default timezone('utc', now()),
  finished_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

drop trigger if exists set_profiles_updated_at on profiles;
create trigger set_profiles_updated_at
before update on profiles
for each row execute function public.set_updated_at();

drop trigger if exists set_workspaces_updated_at on workspaces;
create trigger set_workspaces_updated_at
before update on workspaces
for each row execute function public.set_updated_at();

drop trigger if exists set_workspace_members_updated_at on workspace_members;
create trigger set_workspace_members_updated_at
before update on workspace_members
for each row execute function public.set_updated_at();

drop trigger if exists set_projects_updated_at on projects;
create trigger set_projects_updated_at
before update on projects
for each row execute function public.set_updated_at();

drop trigger if exists set_agents_updated_at on agents;
create trigger set_agents_updated_at
before update on agents
for each row execute function public.set_updated_at();

drop trigger if exists set_agent_skills_updated_at on agent_skills;
create trigger set_agent_skills_updated_at
before update on agent_skills
for each row execute function public.set_updated_at();

drop trigger if exists set_conversations_updated_at on conversations;
create trigger set_conversations_updated_at
before update on conversations
for each row execute function public.set_updated_at();

drop trigger if exists set_messages_updated_at on messages;
create trigger set_messages_updated_at
before update on messages
for each row execute function public.set_updated_at();

drop trigger if exists set_tasks_updated_at on tasks;
create trigger set_tasks_updated_at
before update on tasks
for each row execute function public.set_updated_at();

drop trigger if exists set_artifacts_updated_at on artifacts;
create trigger set_artifacts_updated_at
before update on artifacts
for each row execute function public.set_updated_at();

drop trigger if exists set_tool_runs_updated_at on tool_runs;
create trigger set_tool_runs_updated_at
before update on tool_runs
for each row execute function public.set_updated_at();

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_profile();

drop trigger if exists on_workspace_created on workspaces;
create trigger on_workspace_created
after insert on workspaces
for each row execute function public.handle_new_workspace();

alter table profiles enable row level security;
alter table workspaces enable row level security;
alter table workspace_members enable row level security;
alter table projects enable row level security;
alter table agents enable row level security;
alter table agent_skills enable row level security;
alter table conversations enable row level security;
alter table messages enable row level security;
alter table tasks enable row level security;
alter table artifacts enable row level security;
alter table tool_runs enable row level security;

alter table profiles force row level security;
alter table workspaces force row level security;
alter table workspace_members force row level security;
alter table projects force row level security;
alter table agents force row level security;
alter table agent_skills force row level security;
alter table conversations force row level security;
alter table messages force row level security;
alter table tasks force row level security;
alter table artifacts force row level security;
alter table tool_runs force row level security;

drop policy if exists "profiles select own" on profiles;
drop policy if exists "profiles insert own" on profiles;
drop policy if exists "profiles update own" on profiles;
create policy "profiles select own"
on profiles
for select
using (id = auth.uid());

create policy "profiles insert own"
on profiles
for insert
with check (id = auth.uid());

create policy "profiles update own"
on profiles
for update
using (id = auth.uid())
with check (id = auth.uid());

drop policy if exists "workspaces select member" on workspaces;
drop policy if exists "workspaces insert owner" on workspaces;
drop policy if exists "workspaces update owner" on workspaces;
drop policy if exists "workspaces delete owner" on workspaces;
create policy "workspaces select member"
on workspaces
for select
using (owner_user_id = auth.uid() or public.is_workspace_member(id));

create policy "workspaces insert owner"
on workspaces
for insert
with check (owner_user_id = auth.uid());

create policy "workspaces update owner"
on workspaces
for update
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());

create policy "workspaces delete owner"
on workspaces
for delete
using (owner_user_id = auth.uid());

drop policy if exists "workspace_members select member or self" on workspace_members;
drop policy if exists "workspace_members insert owner" on workspace_members;
drop policy if exists "workspace_members update owner" on workspace_members;
drop policy if exists "workspace_members delete owner" on workspace_members;
create policy "workspace_members select member or self"
on workspace_members
for select
using (
  user_id = auth.uid() or public.is_workspace_member(workspace_id)
);

create policy "workspace_members insert owner"
on workspace_members
for insert
with check (public.is_workspace_owner(workspace_id));

create policy "workspace_members update owner"
on workspace_members
for update
using (public.is_workspace_owner(workspace_id))
with check (public.is_workspace_owner(workspace_id));

create policy "workspace_members delete owner"
on workspace_members
for delete
using (public.is_workspace_owner(workspace_id));

drop policy if exists "projects select member" on projects;
drop policy if exists "projects insert member" on projects;
drop policy if exists "projects update owner or creator" on projects;
drop policy if exists "projects delete owner or creator" on projects;
create policy "projects select member"
on projects
for select
using (public.is_workspace_member(workspace_id));

create policy "projects insert member"
on projects
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "projects update owner or creator"
on projects
for update
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
)
with check (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

create policy "projects delete owner or creator"
on projects
for delete
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

drop policy if exists "agents select member" on agents;
drop policy if exists "agents insert creator" on agents;
drop policy if exists "agents update creator or owner" on agents;
drop policy if exists "agents delete creator or owner" on agents;
create policy "agents select member"
on agents
for select
using (public.is_workspace_member(workspace_id));

create policy "agents insert creator"
on agents
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "agents update creator or owner"
on agents
for update
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
)
with check (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

create policy "agents delete creator or owner"
on agents
for delete
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

drop policy if exists "agent_skills select member" on agent_skills;
drop policy if exists "agent_skills insert creator" on agent_skills;
drop policy if exists "agent_skills update creator or owner" on agent_skills;
drop policy if exists "agent_skills delete creator or owner" on agent_skills;
create policy "agent_skills select member"
on agent_skills
for select
using (public.is_workspace_member(workspace_id));

create policy "agent_skills insert creator"
on agent_skills
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "agent_skills update creator or owner"
on agent_skills
for update
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
)
with check (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

create policy "agent_skills delete creator or owner"
on agent_skills
for delete
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

drop policy if exists "conversations select member" on conversations;
drop policy if exists "conversations insert member" on conversations;
drop policy if exists "conversations update creator or owner" on conversations;
drop policy if exists "conversations delete creator or owner" on conversations;
create policy "conversations select member"
on conversations
for select
using (public.is_workspace_member(workspace_id));

create policy "conversations insert member"
on conversations
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "conversations update creator or owner"
on conversations
for update
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
)
with check (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

create policy "conversations delete creator or owner"
on conversations
for delete
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

drop policy if exists "messages select member" on messages;
drop policy if exists "messages insert member" on messages;
drop policy if exists "messages update creator or owner" on messages;
drop policy if exists "messages delete creator or owner" on messages;
create policy "messages select member"
on messages
for select
using (public.is_workspace_member(workspace_id));

create policy "messages insert member"
on messages
for insert
with check (
  public.is_workspace_member(workspace_id)
  and (
    sender_user_id = auth.uid()
    or sender_user_id is null
  )
);

create policy "messages update creator or owner"
on messages
for update
using (
  sender_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
)
with check (
  sender_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

create policy "messages delete creator or owner"
on messages
for delete
using (
  sender_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

drop policy if exists "tasks select member" on tasks;
drop policy if exists "tasks insert member" on tasks;
drop policy if exists "tasks update creator or owner" on tasks;
drop policy if exists "tasks delete creator or owner" on tasks;
create policy "tasks select member"
on tasks
for select
using (public.is_workspace_member(workspace_id));

create policy "tasks insert member"
on tasks
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "tasks update creator or owner"
on tasks
for update
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
)
with check (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

create policy "tasks delete creator or owner"
on tasks
for delete
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

drop policy if exists "artifacts select member" on artifacts;
drop policy if exists "artifacts insert member" on artifacts;
drop policy if exists "artifacts update creator or owner" on artifacts;
drop policy if exists "artifacts delete creator or owner" on artifacts;
create policy "artifacts select member"
on artifacts
for select
using (public.is_workspace_member(workspace_id));

create policy "artifacts insert member"
on artifacts
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "artifacts update creator or owner"
on artifacts
for update
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
)
with check (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

create policy "artifacts delete creator or owner"
on artifacts
for delete
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

drop policy if exists "tool_runs select member" on tool_runs;
drop policy if exists "tool_runs insert member" on tool_runs;
drop policy if exists "tool_runs update creator or owner" on tool_runs;
drop policy if exists "tool_runs delete creator or owner" on tool_runs;
create policy "tool_runs select member"
on tool_runs
for select
using (public.is_workspace_member(workspace_id));

create policy "tool_runs insert member"
on tool_runs
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "tool_runs update creator or owner"
on tool_runs
for update
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
)
with check (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

create policy "tool_runs delete creator or owner"
on tool_runs
for delete
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_owner(workspace_id)
);

create index if not exists idx_workspaces_owner_user_id on workspaces (owner_user_id);
create index if not exists idx_workspace_members_workspace_id on workspace_members (workspace_id);
create index if not exists idx_workspace_members_user_id on workspace_members (user_id);
create index if not exists idx_projects_workspace_id on projects (workspace_id);
create index if not exists idx_agents_workspace_id on agents (workspace_id);
create index if not exists idx_agents_project_id on agents (project_id);
create index if not exists idx_agent_skills_agent_id on agent_skills (agent_id);
create index if not exists idx_conversations_project_id on conversations (project_id);
create index if not exists idx_messages_conversation_id on messages (conversation_id);
create index if not exists idx_messages_project_id on messages (project_id);
create index if not exists idx_tasks_project_id on tasks (project_id);
create index if not exists idx_tasks_agent_id on tasks (agent_id);
create index if not exists idx_artifacts_project_id on artifacts (project_id);
create index if not exists idx_artifacts_task_id on artifacts (task_id);
create index if not exists idx_tool_runs_project_id on tool_runs (project_id);
create index if not exists idx_tool_runs_task_id on tool_runs (task_id);

revoke all on table profiles from anon;
revoke all on table workspaces from anon;
revoke all on table workspace_members from anon;
revoke all on table projects from anon;
revoke all on table agents from anon;
revoke all on table agent_skills from anon;
revoke all on table conversations from anon;
revoke all on table messages from anon;
revoke all on table tasks from anon;
revoke all on table artifacts from anon;
revoke all on table tool_runs from anon;

grant usage on schema public to authenticated;
grant select, insert, update, delete on table profiles to authenticated;
grant select, insert, update, delete on table workspaces to authenticated;
grant select, insert, update, delete on table workspace_members to authenticated;
grant select, insert, update, delete on table projects to authenticated;
grant select, insert, update, delete on table agents to authenticated;
grant select, insert, update, delete on table agent_skills to authenticated;
grant select, insert, update, delete on table conversations to authenticated;
grant select, insert, update, delete on table messages to authenticated;
grant select, insert, update, delete on table tasks to authenticated;
grant select, insert, update, delete on table artifacts to authenticated;
grant select, insert, update, delete on table tool_runs to authenticated;

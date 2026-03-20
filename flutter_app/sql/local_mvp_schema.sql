PRAGMA foreign_keys = ON;

create table if not exists profiles (
  id text primary key,
  display_name text not null default '',
  email text not null default '',
  auth_mode text not null default 'local_only'
    check (auth_mode in ('local_only', 'cloud_connected')),
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP
);

create table if not exists workspaces (
  id text primary key,
  owner_profile_id text not null references profiles (id) on delete cascade,
  name text not null,
  description text not null default '',
  sync_mode text not null default 'local_only'
    check (sync_mode in ('local_only', 'premium_sync')),
  remote_workspace_id text,
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP,
  archived_at text
);

create table if not exists workspace_members (
  id text primary key,
  workspace_id text not null references workspaces (id) on delete cascade,
  profile_id text not null references profiles (id) on delete cascade,
  role text not null default 'owner'
    check (role in ('owner', 'admin', 'member', 'viewer')),
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP,
  unique (workspace_id, profile_id)
);

create table if not exists projects (
  id text primary key,
  workspace_id text not null references workspaces (id) on delete cascade,
  created_by_profile_id text not null references profiles (id) on delete cascade,
  title text not null,
  goal text not null,
  status text not null default 'draft'
    check (status in ('draft', 'planning', 'running', 'review', 'done', 'archived', 'failed')),
  execution_plan_json text not null default '[]',
  summary text not null default '',
  remote_project_id text,
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP,
  archived_at text
);

create table if not exists agents (
  id text primary key,
  workspace_id text not null references workspaces (id) on delete cascade,
  project_id text not null references projects (id) on delete cascade,
  created_by_profile_id text not null references profiles (id) on delete cascade,
  agent_key text not null
    check (agent_key in ('orchestrator', 'pm', 'system_designer', 'flutter', 'qa')),
  name text not null,
  role text not null,
  model text not null default 'gpt-5.4',
  instructions text not null default '',
  status text not null default 'active'
    check (status in ('active', 'paused', 'blocked', 'completed', 'failed')),
  sort_order integer not null default 0,
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP,
  unique (project_id, agent_key)
);

create table if not exists agent_skills (
  id text primary key,
  workspace_id text not null references workspaces (id) on delete cascade,
  agent_id text not null references agents (id) on delete cascade,
  created_by_profile_id text not null references profiles (id) on delete cascade,
  skill_key text not null,
  name text not null,
  description text not null default '',
  config_json text not null default '{}',
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP,
  unique (agent_id, skill_key)
);

create table if not exists conversations (
  id text primary key,
  workspace_id text not null references workspaces (id) on delete cascade,
  project_id text not null references projects (id) on delete cascade,
  created_by_profile_id text not null references profiles (id) on delete cascade,
  title text not null,
  mode text not null default 'workflow'
    check (mode in ('workflow', 'support', 'review')),
  context_json text not null default '{}',
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP,
  archived_at text
);

create table if not exists messages (
  id text primary key,
  workspace_id text not null references workspaces (id) on delete cascade,
  project_id text not null references projects (id) on delete cascade,
  conversation_id text not null references conversations (id) on delete cascade,
  sender_profile_id text references profiles (id) on delete set null,
  agent_id text references agents (id) on delete set null,
  role text not null check (role in ('user', 'assistant', 'system', 'tool')),
  content text not null default '',
  metadata_json text not null default '{}',
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP
);

create table if not exists tasks (
  id text primary key,
  workspace_id text not null references workspaces (id) on delete cascade,
  project_id text not null references projects (id) on delete cascade,
  agent_id text references agents (id) on delete set null,
  created_by_profile_id text not null references profiles (id) on delete cascade,
  parent_task_id text references tasks (id) on delete set null,
  task_key text not null,
  title text not null,
  type text not null
    check (type in ('plan', 'spec', 'schema', 'ui', 'code', 'qa', 'review', 'sync')),
  status text not null default 'queued'
    check (status in ('queued', 'claimed', 'running', 'blocked', 'completed', 'failed', 'cancelled')),
  priority integer not null default 3 check (priority between 1 and 5),
  input_json text not null default '{}',
  output_json text not null default '{}',
  error_message text not null default '',
  queued_at text not null default CURRENT_TIMESTAMP,
  started_at text,
  finished_at text,
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP,
  archived_at text,
  unique (project_id, task_key)
);

create table if not exists artifacts (
  id text primary key,
  workspace_id text not null references workspaces (id) on delete cascade,
  project_id text not null references projects (id) on delete cascade,
  task_id text references tasks (id) on delete set null,
  created_by_profile_id text not null references profiles (id) on delete cascade,
  artifact_type text not null
    check (artifact_type in ('execution_plan', 'prd', 'schema', 'ui', 'code', 'qa', 'decision', 'log')),
  title text not null,
  body text not null default '',
  data_json text not null default '{}',
  storage_path text,
  version integer not null default 1,
  checksum text not null default '',
  status text not null default 'draft'
    check (status in ('draft', 'generated', 'reviewed', 'approved', 'rejected')),
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP,
  archived_at text,
  unique (project_id, artifact_type, version)
);

create table if not exists tool_runs (
  id text primary key,
  workspace_id text not null references workspaces (id) on delete cascade,
  project_id text not null references projects (id) on delete cascade,
  task_id text references tasks (id) on delete set null,
  agent_id text references agents (id) on delete set null,
  created_by_profile_id text not null references profiles (id) on delete cascade,
  tool_name text not null,
  status text not null default 'running'
    check (status in ('queued', 'running', 'succeeded', 'failed', 'cancelled')),
  input_json text not null default '{}',
  output_json text not null default '{}',
  error_message text not null default '',
  started_at text not null default CURRENT_TIMESTAMP,
  finished_at text,
  created_at text not null default CURRENT_TIMESTAMP,
  updated_at text not null default CURRENT_TIMESTAMP
);

create index if not exists idx_workspace_members_workspace on workspace_members (workspace_id);
create index if not exists idx_projects_workspace on projects (workspace_id);
create index if not exists idx_agents_project on agents (project_id);
create index if not exists idx_tasks_project on tasks (project_id);
create index if not exists idx_artifacts_project on artifacts (project_id);
create index if not exists idx_tool_runs_project on tool_runs (project_id);

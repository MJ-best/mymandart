# Workflow Platform Architecture

## 목표

Flutter web-first + local SQL 기반의 multi-agent workflow MVP를 제공한다. 사용자는 `project_goal`을 입력하고, 시스템은 실행 계획과 산출물(PRD, schema, UI, code, QA)을 순차적으로 생성한다. Supabase 기반 서버 관리와 동기화는 추후 유료 구독 기능으로 분리한다.

## 핵심 UX

- chat-first가 아니라 pipeline-first
- 로그인 없이도 로컬 workspace로 바로 진입 가능
- dashboard에서 목표 입력
- orchestrator가 execution plan 생성
- specialist agents가 task를 완료하며 artifact를 생성
- project detail에서 workflow, artifact, execution log를 함께 검토
- 핵심 플로우는 edit -> execute -> progress -> complete가 직관적으로 이어져야 함

## 라우트

- `/`
- `/login`
- `/dashboard`
- `/projects`
- `/projects/:projectId`
- `/projects/:projectId/artifacts/:artifactId`
- `/settings`

## 핵심 도메인

- `Workspace`
- `Project`
- `ExecutionPlanStep`
- `ProjectTask`
- `ProjectArtifact`
- `ExecutionConversation`
- `ExecutionMessage`
- `ToolRun`
- `PlatformAgent`
- `AgentSkill`

## 코드 트리

- `lib/core`
  - `providers`
  - `supabase`
  - `router`
  - `layout`
  - `theme`
- `lib/features/auth`
  - 로그인 화면, 세션 상태, Auth repository
- `lib/features/workspace`
  - workspace seed, active workspace 상태, dashboard
- `lib/features/projects`
  - project/task 모델, workflow 저장소, 목록/상세
- `lib/features/agents`
  - agent catalog, workflow step UI
- `lib/features/chat`
  - execution log와 tool run 읽기 모델
- `lib/features/artifacts`
  - artifact 읽기와 viewer
- `lib/features/settings`
  - auth status, workspace 정보, theme 설정

## 데이터 원칙

- MVP의 canonical 저장 원칙은 local SQL이다.
- 원격 정식 소스는 추후 premium sync 계층으로 분리한다.
- 모든 핵심 기능은 오프라인 또는 비로그인 상태에서도 동작해야 한다.
- local schema는 future sync migration이 가능한 형태로 설계한다.

## 디자인 원칙

- 웹 우선으로 디자인하고 모바일은 후속 적응 범위로 다룬다.
- 불필요한 탭을 줄이고 inline interaction을 우선한다.
- 시각 방향은 soft paper surface, rounded blue/yellow cards, playful iconography를 따른다.
- Figma source가 있으면 design context + screenshot을 받은 뒤 구현한다.

## 에이전트 경계

- `orchestrator`
  - execution plan, task graph, assignment 담당
- `pm`
  - PRD, feature list, user flow 담당
- `system_designer`
  - local SQL schema, premium sync upgrade path, data model 담당
- `flutter`
  - web-first UI 구조와 Flutter 코드 담당
- `qa`
  - edge case, validation, gap review 담당

## 현재 구현 상태

- Flutter 앱 셸과 workflow UI 구현 완료
- demo mode 기반 end-to-end 로컬 플로우 구현 완료
- Supabase SQL schema와 RLS 정책 초안은 premium sync 준비 자산으로 보관
- local SQL schema 초안을 [flutter_app/sql/local_mvp_schema.sql](/Users/mj/Documents/mandara-2026/flutter_app/sql/local_mvp_schema.sql)에 추가
- Google OAuth는 추후 premium cloud sync 경로에서만 사용

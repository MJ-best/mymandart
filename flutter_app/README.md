# VibeFlow MVP

Flutter web-first multi-agent workflow platform MVP입니다. 이 앱은 채팅 앱이 아니라, 사용자의 `project_goal`을 받아 실행 계획과 구조화된 산출물(PRD, schema, UI, code, QA)을 단계적으로 생성하는 파이프라인 UI를 제공합니다.

현재 제품 방향:

- 기본 저장은 local-first
- 핵심 워크플로우는 비로그인 상태에서도 동작
- 웹 버전을 먼저 완성하고 모바일은 후속 적응
- cloud sync/Supabase 관리 기능은 추후 유료 구독 기능으로 분리

## MVP 범위

- Google login 스캐폴딩 + demo mode
- workspace 시스템
- project 생성과 실행 계획 생성
- agent workflow 시각화
- artifact 목록/상세 보기
- execution log와 tool run 확인

## 앱 구조

- `lib/core`
  - 앱 부트스트랩, Supabase 설정, `go_router`, 공통 레이아웃, 테마
- `lib/features/auth`
  - 세션 상태, 로그인 화면, Supabase Auth 저장소
- `lib/features/workspace`
  - workspace 도메인, 로컬 저장소, 대시보드, 전환 UI
- `lib/features/projects`
  - project/task 모델, 로컬 workflow 저장소, 프로젝트 목록/상세
- `lib/features/agents`
  - agent 정의 로드, workflow 시각화
- `lib/features/chat`
  - execution log와 tool run 모델/조회
- `lib/features/artifacts`
  - artifact 모델, 목록/상세 조회
- `lib/features/settings`
  - 인증 상태, workspace, theme 설정
- `sql/local_mvp_schema.sql`
  - local-first canonical schema draft

## 에이전트 정의

Codex 에이전트 계약은 아래에 있습니다.

- `../codex/agents.json`
- `../codex/agents/*.md`

## 실행

```bash
flutter pub get
flutter run -d chrome
```

Supabase를 연결해서 실행:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

Supabase를 연결하지 않아도 로컬 모드로 바로 MVP를 확인할 수 있습니다.

## 데이터 저장

- 기본 런타임: 로컬 저장
- canonical 방향: local SQL
- 원격 동기화: 추후 premium sync 계층
- 주요 로컬 키
  - `platform.theme_mode`
  - `platform.demo_mode`
  - `platform.workspaces`
  - `platform.active_workspace_id`
  - `platform.project_bundles`

## Supabase 스키마

- `supabase/migrations/20260320_v2_init.sql`

포함 테이블:

- `profiles`
- `workspaces`
- `workspace_members`
- `projects`
- `agents`
- `agent_skills`
- `conversations`
- `messages`
- `tasks`
- `artifacts`
- `tool_runs`

## Local SQL 스키마

- `sql/local_mvp_schema.sql`

이 파일은 web-first local MVP의 canonical schema 초안입니다. Supabase 스키마는 premium sync 단계로 올릴 때 매핑 기준으로 사용합니다.

## 검증

```bash
flutter analyze
flutter test
```

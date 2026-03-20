# Mandarat Architecture

## 목표

초기 만다라트 앱의 기능은 유지하고, 화면 무드와 사용성을 web-first 기준으로 정리한다. 앱은 로컬 우선으로 동작하며, 서버 동기화나 계정 기반 기능은 현재 범위가 아니다.

## 핵심 UX

- 첫 진입은 랜딩 화면에서 시작한다.
- 사용자는 새 만다라트를 만들거나 저장된 만다라트를 연다.
- 메인 앱은 3단계 흐름으로 구성된다.
- `만다라트` 뷰에서 전체 구조를 보고, `실행`/`편집`에서 목표와 액션을 다듬고, `기록`/`캘린더`에서 진행 상태를 확인한다.
- 편집과 실행은 화면을 자주 넘기지 않도록 같은 맥락에서 이어진다.
- 모바일보다 웹을 먼저 기준으로 잡되, 모바일도 같은 정보 구조를 유지한다.

## 라우트

- `/` - 랜딩
- `/start` - 새 만다라트 시작
- `/app` - 메인 만다라트 작업 화면
- `/create` - `/app` 호환 경로
- `/saved-mandalarts` - 저장된 만다라트 목록
- `/example` - 오타니 예시 만다라트

## 핵심 도메인

- `MandalartStateModel`
- `ThemeModel`
- `ActionItemModel`
- `ActionStatus`
- `GoalPriority`
- `SavedMandalartMeta`
- `StreakState`

## 코드 트리

활성 코드는 다음 영역에 있다.

- `lib/main.dart`
  - 라우터와 테마 연결
- `lib/screens`
  - 랜딩, 시작, 메인 앱, 저장 목록, 예시 화면
- `lib/providers`
  - 만다라트 상태, 테마, streak 상태
- `lib/widgets`
  - 만다라트 그리드, 단계 UI, 달력, 진행 표시, 공통 위젯
- `lib/models`
  - 상태와 도메인 모델
- `lib/services`
  - export/import, 이미지 저장
- `lib/utils`
  - 앱 테마, 그리드, 웹 다운로드
- `lib/data`
  - 예시 데이터, 키워드
- `lib/l10n`
  - 로컬라이제이션 문자열

## 저장 원칙

- 기본 저장소는 `SharedPreferences`다.
- 앱이 사용하는 핵심 상태는 로컬에 유지한다.
- JSON 내보내기와 불러오기는 사용자가 기기 간에 데이터를 옮길 때 쓰는 보조 수단이다.
- 이미지 저장은 공유용 산출물 생성에 한정한다.

## 디자인 원칙

- web-first로 시작하고, 모바일은 같은 계층 구조를 유지한다.
- 입력 횟수를 줄이고, 한 번의 탭으로 다음 동작이 이어지게 만든다.
- 시각 톤은 soft paper surface, rounded blue/yellow cards, playful but not noisy한 아이콘 표현을 따른다.
- 스타일 변경은 기능을 바꾸지 않는 범위에서만 적용한다.

## 기능 경계

- `landing`
  - 최초 진입과 시작 진입점
- `mandalart viewer`
  - 3x3 구조 확인, 중심 목표 확인, 카드형 탐색
- `combined edit`
  - 테마와 액션 편집
- `calendar`
  - 진행 기록 확인
- `saved mandalarts`
  - 저장된 상태 목록과 재진입
- `example`
  - 샘플 만다라트 확인
- `export/import`
  - JSON 기반 데이터 이동
- `image export`
  - 만다라트 이미지를 PNG로 저장하거나 웹에서 다운로드

## 현재 구현 상태

- 기존 만다라트 앱 흐름은 유지되고 있다.
- 스타일은 웹 우선 기준으로 계속 다듬고 있다.
- 로컬 저장, 저장 목록, 예시 보기, export/import, 이미지 저장이 동작한다.
- 클라우드 동기화와 서버 관리 기능은 아직 구현 범위가 아니다.

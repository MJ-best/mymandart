# Mandarat Journey

Flutter 기반 만다라트 앱입니다. 초기 제품의 핵심 기능은 유지하고, 화면 분위기와 사용성을 web-first 기준으로 다듬는 것이 현재 방향입니다.

## 현재 방향

- 기존 만다라트 흐름은 유지합니다.
- 스타일은 부드러운 종이 질감, 크림/블루/옐로우 톤, 둥근 카드 중심으로 정리합니다.
- 기본 저장은 local-first입니다.
- 웹 버전을 먼저 다듬고, 모바일은 동일한 구조를 유지하는 범위에서 맞춥니다.
- 클라우드 동기화나 서버 관리 기능은 현재 범위가 아닙니다.

## 주요 기능

- 첫 진입 랜딩과 시작 화면
- 만다라트 메인 뷰와 단계별 편집 흐름
- 저장된 만다라트 목록
- 오타니 예시 만다라트 보기
- 달력 기록과 진행 상태 확인
- JSON 내보내기/불러오기
- 만다라트 이미지 저장 및 웹 다운로드

## 라우트

- `/` - 랜딩
- `/start` - 새 만다라트 시작
- `/app` - 메인 만다라트 화면
- `/create` - `/app`으로의 호환 라우트
- `/saved-mandalarts` - 저장된 만다라트
- `/example` - 예시 만다라트

## 코드 구조

현재 활성 런타임은 다음 영역에 있습니다.

- `lib/main.dart`
  - 앱 진입점, 라우터, 테마 연결
- `lib/screens`
  - `landing_screen`, `start_screen`, `mandalart_app`, `saved_mandalarts_screen`, `example_mandalart_screen`
- `lib/providers`
  - 만다라트 상태, 테마 상태, streak 상태
- `lib/widgets`
  - 만다라트 뷰어, 단계 편집, 달력, 진행 표시, 공통 UI
- `lib/models`
  - 만다라트 상태와 도메인 모델
- `lib/services`
  - JSON export/import, 이미지 저장
- `lib/utils`
  - 앱 테마, 그리드, 웹 다운로드
- `lib/data`
  - 예시 데이터와 키워드
- `lib/l10n`
  - 한국어/영어 로컬라이제이션

## 로컬 저장

핵심 상태는 `SharedPreferences` 기반으로 저장합니다.

- `has_started`
- `theme_mode`
- `color_theme`
- `mandalart-goal`
- `mandalart-themes`
- `mandalart-actions`
- `mandalart-current-step`
- `mandalart-display-name`
- `saved-mandalart-ids`
- `current-mandalart-id`
- `current-mandalart-created-at`
- `mandalart-calendar-log`

## 실행

```bash
flutter pub get
flutter run -d chrome
```

검증:

```bash
flutter analyze
flutter test
```

## 참고

- 앱 분위기는 `blue/yellow` 계열의 부드러운 카드 스타일을 따릅니다.
- 예시와 저장/내보내기 기능은 보조 기능이며, 핵심은 만다라트 작성과 진행 기록입니다.

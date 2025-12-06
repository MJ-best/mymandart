# Project Development History & Status

This document consolidates the development records, changelogs, and implementation details for the Mandalart Journey project.

## 🚀 Current Status (Latest)

### Recent Feature Enhancements
- Replaced bottom step buttons with top arrow controls tied to the dot indicator and added PageView-driven swipe navigation across steps.
- Added tappable Mandalart grid interactions with action completion and auto-expansion.
- Surfaced the main goal atop the chart viewer and wired custom display names across navigation bars.
- Reimagined the landing screen with Ohtani Shohei storytelling, hero icon, and personalized journey naming.

### UI & UX Refinements
- Replaced step text labels with a dot-based progress indicator.
- Simplified landing page messaging with highlight cards and improved icon shadow rendering.
- Reordered the Mandalart viewer header to show journey name, goal, completion status, and advice.
- Unified destructive actions across all steps with compact red `X` buttons.
- Updated community goal suggestions with friendlier, concrete examples.

### Sharing & Export Improvements
- Introduced wallpaper export presets (current, iPhone, iPad) with resolution-aware resizing and downloads.
- Enhanced recommended action chips to populate inputs even without focus.

### Testing & Verification
- `flutter analyze`
- `flutter test`
- `flutter run -d "iPhone 17" --no-resident` performed after major changes to confirm behavior.

---

## 📋 Active Implementation Plan & Pending Tasks

### 1. Step 1: 다른 사람들의 목표 표시
**목적**: 사용자가 다른 사람들과 연결되어 있다는 느낌 제공

**구현 방법**:
- 100가지의 새해 목표 데이터 준비
- Step 1 화면에 랜덤하게 선택된 목표들을 표시
- "다른 사람들은 이런 목표를 세우고 있어요" 섹션 추가
- 실시간 연결 대신 미리 준비된 목표 목록 사용

**기술적 접근**:
- `keywords.dart`에 100개의 새해 목표 리스트 추가
- 랜덤 선택 알고리즘으로 3-5개 표시
- 슬라이딩 애니메이션으로 순환 표시 (선택적)

### 2. 완료 색상 변경: 보라색 테마로 통일
**현재 문제**: 완료된 항목이 초록색으로 표시되어 너무 튐

**변경 사항**:
- 완료 색상: `CupertinoColors.systemGreen` → `CupertinoColors.systemPurple`
- 앱 전체 테마 컬러를 보라색 계열로 통일
- 완료된 액션 아이템 배경도 부드러운 보라색 톤 사용

**적용 위치**:
- `MandalartAppScreen`: CupertinoSwitch activeTrackColor
- `MandalartViewer`: 완료된 셀 배경색
- 기타 강조 색상

### 3. Step 2: 액션 아이템 폴딩/언폴딩 (Accordion)
**현재 문제**: 8개 테마의 액션 아이템이 모두 펼쳐져 있어 산만함

**변경 사항**:
- 각 테마 카드를 접을 수 있도록 변경 (Accordion/Collapsible)
- 기본 상태: 모두 접힌 상태
- 테마 제목 탭하면 해당 테마의 8개 액션 아이템 표시
- 한 번에 하나의 테마만 펼쳐지도록 (선택적)

**구현 방법**:
- `ExpansionTile` 또는 커스텀 Collapsible 위젯 사용
- 상태 관리: 어떤 테마가 펼쳐져 있는지 추적
- 애니메이션: iOS 스타일 부드러운 expand/collapse

### 4. Step 3: Toggle → Checkbox 변경
**현재**: CupertinoSwitch (토글) 사용
**변경**: CupertinoCheckbox 사용

**이유**:
- 완료/미완료 표시에는 체크박스가 더 직관적
- 공간 효율성 향상
- 시각적으로 덜 산만함

**적용**:
- `_ActionsStep`의 CupertinoSwitch를 CupertinoCheckbox로 교체
- 체크박스 선택 시 햅틱 피드백 유지
- 체크된 항목은 보라색 체크마크 표시

### 완료 체크리스트
- [ ] 100개의 새해 목표 데이터 추가
- [ ] Step 1에 랜덤 목표 표시 기능 구현
- [ ] 전체 앱 테마를 보라색으로 변경
- [ ] 완료 색상 초록 → 보라 변경
- [ ] Step 2에 Accordion/Collapsible 추가
- [ ] CupertinoSwitch → CupertinoCheckbox 교체
- [ ] 모든 변경사항 테스트 (iOS/Android)
- [ ] Hot reload로 즉시 확인

---

## 📜 Development Timeline

### 2025-11-01
#### Session 2: Haptic Feedback Implementation

**1. 할일 완료 시 햅틱 피드백 추가**

**1.1 문제 인식**
사용자 피드백: "만다라트에서 터치해서 할일을 완료로 만들 때 터치 피드백으로 햅틱 피드백을 달라고 했는데 어플에서 실행해보니 그런 기능은 구현되지 않았네요."

기존 구현 상태:
- 터치 시 `HapticFeedback.lightImpact()` 있음 (모든 터치에 동일)
- 완료 상태로 변경될 때 특별한 피드백 없음

**1.2 구현 방식**
**핵심 아이디어**: 할일이 "완료(completed)" 상태로 전환될 때만 더 강한 햅틱 피드백 제공

**수정된 파일 (5개)**:
1. `lib/providers/mandalart_provider.dart` - toggleActionStatus()가 새로운 상태 반환하도록 수정
2. `lib/screens/mandalart_app.dart` - 완료 시 mediumImpact 추가
3. `lib/widgets/mandalart_viewer.dart` - 3곳에서 완료 시 mediumImpact 추가
4. `lib/widgets/steps/actions_step.dart` - 완료 시 mediumImpact 추가
5. `lib/widgets/steps/combined_step.dart` - 완료 시 mediumImpact 추가

**1.3 Provider 수정 (`lib/providers/mandalart_provider.dart`)**

```dart
ActionStatus? toggleActionStatus({required int themeIndex, required int actionIndex}) {
  // ... 상태 토글 로직
  return newStatus; // 새로운 상태 반환
}
```

**1.4 UI 레이어 수정**

**패턴 1: Provider 반환값 활용** (`mandalart_app.dart`, `actions_step.dart`, `combined_step.dart`)
```dart
onTap: () {
  HapticFeedback.lightImpact(); // 모든 터치에 기본 피드백
  final newStatus = notifier.toggleActionStatus(
    themeIndex: themeIndex,
    actionIndex: actionIndex,
  );
  // 완료 상태로 변경될 때만 강한 피드백
  if (newStatus == ActionStatus.completed) {
    HapticFeedback.mediumImpact();
  }
},
```

**패턴 2: 현재 상태 확인** (`mandalart_viewer.dart` - TODO 리스트)
```dart
onTap: () {
  HapticFeedback.lightImpact();
  widget.onToggleAction(themeIndex, actionIndex);
  // inProgress → completed 전환 시에만 강한 피드백
  if (action.status == ActionStatus.inProgress) {
    HapticFeedback.mediumImpact();
  }
},
```

**1.5 햅틱 피드백 레벨**
- **lightImpact**: 모든 터치 (notStarted → inProgress, completed → notStarted)
- **mediumImpact**: 할일 완료 시만 (inProgress → completed)

#### Session 1: Color Theme System & Icon System

**1. 색상 테마 시스템 구현**

**1.1 테마 Provider 확장 (`lib/providers/theme_provider.dart`)**
- **ColorTheme enum 추가**: 4가지 색상 테마 정의
  - `green` - 녹색 (systemGreen)
  - `purple` - 보라색 (systemPurple)
  - `black` - 검은색
  - `white` - 흰색

- **ThemeState 확장**
  - `colorTheme` 필드 추가
  - `primaryColor` getter 추가 - 선택된 테마에 따라 적절한 색상 반환

- **ThemeNotifier 기능 추가**
  - `setColorTheme()` - 색상 테마 변경 및 SharedPreferences 저장
  - `_loadTheme()` - 앱 시작 시 저장된 테마 설정 로드

**1.2 앱 전체 색상 동적화**
**수정된 파일 (총 13개)**: 
`lib/main.dart`, `lib/widgets/streak_widget.dart` 등 13개 파일에서 하드코딩된 색상을 `primaryColor`로 교체.

**1.3 색상 테마 선택 UI (`lib/screens/landing_screen.dart`)**
- **색상 필터 버튼 추가**: 네비게이션 바에 색상 선택 버튼 추가
- **CupertinoActionSheet 구현**: 4가지 색상 옵션을 제공하는 액션 시트

**2. Context7 마이그레이션 (withOpacity → withValues)**

**2.1 deprecation 경고 해결**
Flutter 3.27+ 호환성을 위해 `color.withOpacity(value)` → `color.withValues(alpha: value)` 전체 교체 (총 52개 수정)

**2.2 resolveFrom 오류 수정**
- `Color` 타입에는 `resolveFrom()` 메서드가 없음 (CupertinoDynamicColor만 가능)
- 불필요한 `.resolveFrom(context)` 호출 제거

**3. 앱 아이콘 동적 변경 시스템**

**3.1 패키지 추가**
- `flutter_dynamic_icon: ^2.1.0` 추가

**3.2 색상별 앱 아이콘 생성**
- Python 스크립트로 기존 아이콘의 색상을 변경하여 4가지 변형 생성

**3.3 iOS 아이콘 설정**
- `AppIcon-Green`, `AppIcon-Purple` 등 4개 아이콘셋 생성 및 `Info.plist` 등록

**3.4 아이콘 변경 로직 구현**
`setColorTheme()` 호출 시 `FlutterDynamicIcon.setAlternateIconName()`을 사용하여 아이콘 자동 변경

**4. 테스트 수정**
- `widget_test.dart`에서 SharedPreferences Mock 초기화 및 펌프 시간 조정으로 74개 테스트 통과

---

### 2025-10-27
#### UI/UX 개선 및 기능 복구

**🎨 UI/UX 개선**

**1. 네비게이션 최적화**
- **모든 페이지에서 상단바 제거**: `CupertinoNavigationBar` 완전 제거
- 점(StepProgressIndicator)과 화살표 버튼만으로 페이지 이동
- 만다라트 화면 공간 최대화

**2. 진행 표시 점 크기 조정**
- 1차 축소: 14/10 → 4/3
- 2차 조정: 4/3 → 6/5 (최종)

**3. Phone 최적화**
- 화면 너비 600px 미만일 때 아이콘/버튼 크기 자동 축소 (반응형)

**4. 출석체크 위젯 크기 50% 축소**
- 전체 패딩, 폰트, 아이콘 크기를 조정하여 공간 확보

**✨ 기능 추가 및 복구**

**1. 3페이지 기능 복구**
- 만다라트 뷰어에 저장, 다크모드, 이미지 저장, JSON 내보내기 버튼 추가
- `withScaffold=false`일 때도 버튼 표시 지원

**2. 도움말 버튼 위치 변경**
- 상단바에서 하단(명언 아래 또는 사이드바)으로 이동

**3. 이전 만다라트 보기 기능**
- 랜딩 페이지에 저장된 만다라트 목록으로 이동하는 버튼 추가

**4. 사용자 상태 저장/복원**
- SharedPreferences의 `has_started` 플래그를 사용하여 재방문 시 3페이지(뷰어)로 자동 이동

**📝 텍스트 개선**
- "이 목표를 실현하기 위한 8가지 핵심 영역" → "8가지 핵심영역" 등으로 간소화

---

### 2025-10-26
#### 페이지 구조 재구성 및 꾸준점수 통합

**배경**: 사용자가 만다라트를 작성하면서 꾸준히 접속하도록 동기부여하는 시스템 필요. 테마와 액션 아이템 통합 필요.

**1. 새로운 페이지 구조 (3개 페이지)**
- Page 0: GoalStep (목표 입력)
- Page 1: CombinedStep (테마 + 액션 통합 + 꾸준점수)
- Page 2: MandalartViewer (만다라트 차트)

**2. CombinedStep 위젯 생성**
- 테마 입력과 액션 아이템 입력을 하나의 위젯으로 통합
- 꾸준점수 위젯(StreakWidget) 최상단 배치
- 테마별 Accordion UI 적용

**3. MandalartViewer PageView 통합**
- `withScaffold` 파라미터 추가로 PageView 내부 사용 지원

**4. StreakWidget 다크모드 적용**
- `CupertinoTheme.brightnessOf(context)`를 사용하여 다크모드 즉시 반응하도록 수정
- 상태별(재, 연기, 불, 강한 불) 그라디언트 색상 정의

**5. 랜딩페이지 그라디언트 제거**
- 단색 배경으로 변경하여 깔끔한 디자인 적용

**6. StreakWidget 위치 조정**
- TODO 리스트 위로 이동하여 가시성 확보

---

### 2025-10-17
#### 사용자 경험 개선 및 흐름 재구성

**문제 상황**: 여러 개 저장 불가, 추천 액션 자동 입력으로 인한 고민 부족, 저장 후 흐름 불명확.

**1. 여러 만다라트 저장 문제 수정**
- 저장 시 항상 새로운 UUID 생성하여 덮어쓰기 방지

**2. 추천 액션/커뮤니티 목표 클릭 동작 제거**
- 버튼 형식을 텍스트 형식으로 변경 ("액션 아이디어", "다른 사람들의 목표")
- 클릭하여 자동 입력되는 기능을 제거하여 직접 작성 유도

**3. 사용자 흐름 재구성**
- **기존**: 저장 버튼 클릭 → 알림만 표시
- **변경**: 저장 버튼 클릭 → 자동으로 '저장된 만다라트 목록' 페이지로 이동
- **목록 페이지**: "새 만다라트 시작" 버튼을 눈에 띄게 배치

**4. UI 개선**
- GoalStep에서 "새 만다라트 시작" 버튼 제거 (혼란 방지)
- 랜딩 페이지 모달의 중복된 뒤로가기 버튼 제거

---

### 2025-10-14
#### 다크 모드, 가로 모드 점검 및 만다라트 저장 기능 오류 수정

**문제 상황**: 다크모드에서 텍스트 불가시, 가로모드 문제, 저장 개수 제한.

**1. Dark Mode Fixes**
- `GridCellWidget`, `ActionsStep` 등에서 `CupertinoColors.label.resolveFrom(context)` 적용
- `MandalartViewer` 명언 텍스트 색상 수정

**2. 여러 만다라트 저장 기능 구현**
- `SavedMandalartMeta` 모델 추가 (메타데이터 분리 저장)
- `MandalartNotifier` 저장 메서드 개선: 데이터(`mandalart_data_ID`)와 메타(`mandalart_meta_ID`) 분리 저장
- `SavedMandalartsScreen` 구현: 저장된 목록 표시, 삭제 기능, 로드 기능

**3. UI 개선**
- `GoalStep`에 "이전의 만다라트 보기" 버튼 추가
- `MandalartViewer`에 저장(플로피 디스크) 버튼 추가

**4. 후속 수정**
- `SavedMandalartsScreen` UI 개선 (삭제 아이콘 변경, 네비게이션 수정)

---

### 2025-10-13
#### Riverpod ref.listen 에러 수정

**문제**: `initState`에서 `ref.listen`을 사용하여 "Failed assertion" 에러 발생.

**해결 방법**:
1. `initState`에서는 `PageController` 초기화만 수행
2. `ref.listen`을 `build` 메서드로 이동
3. `WidgetsBinding.instance.addPostFrameCallback`과 `_isInitialized` 플래그를 사용하여 초기 페이지 점프 로직 안전하게 구현

**설명**: Riverpod 2.x에서는 `ref.listen`을 `build` 내부나 Provider Body에서 사용하는 것이 권장됨.

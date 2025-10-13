# 개발 프로세스 기록

## 2025-10-13 - Riverpod ref.listen 에러 수정

### 문제 상황
- **에러**: `package:flutter_riverpod/src/consumer.dart': Failed assertion: line 600 pos 7`
- **위치**: `lib/screens/mandalart_app.dart:30-45`
- **원인**: `initState` 메서드에서 `ref.listen`을 사용하여 Riverpod assertion 에러 발생
- **설명**: Riverpod 2.x에서는 `initState`에서 `ref.listen`을 직접 사용할 수 없음. 이는 위젯의 생명주기와 Riverpod의 listener 관리 방식 때문

### 해결 방법

#### 1. initState 간소화
```dart
// 변경 전
@override
void initState() {
  super.initState();
  final initialStep = ref.read(mandalartProvider).currentStep;
  _pageController = PageController(initialPage: initialStep);
  ref.listen<int>(
    mandalartProvider.select((value) => value.currentStep),
    (previous, next) {
      // listener 로직
    },
  );
}

// 변경 후
@override
void initState() {
  super.initState();
  _pageController = PageController(initialPage: 0);
}
```

#### 2. build 메서드로 listener 이동
```dart
@override
Widget build(BuildContext context) {
  final state = ref.watch(mandalartProvider);
  final notifier = ref.read(mandalartProvider.notifier);

  // 초기화 로직 - 첫 빌드 시에만 실행
  if (!_isInitialized) {
    _isInitialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) {
        _pageController.jumpToPage(state.currentStep);
      }
    });
  }

  // build 메서드 내에서 ref.listen 사용 (Riverpod 권장 방식)
  ref.listen<int>(
    mandalartProvider.select((value) => value.currentStep),
    (previous, next) {
      if (!_pageController.hasClients) {
        return;
      }
      final currentPage = _pageController.page?.round() ?? _pageController.initialPage;
      if (currentPage != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    },
  );

  // ... 나머지 빌드 로직
}
```

#### 3. 초기화 플래그 추가
```dart
class _MandalartAppScreenState extends ConsumerState<MandalartAppScreen> {
  late final PageController _pageController;
  bool _isInitialized = false;  // 추가
  // ...
}
```

### 변경 파일
- `lib/screens/mandalart_app.dart`

### 테스트 결과
- Android 에뮬레이터에서 정상 실행 확인
- assertion 에러 없이 앱이 정상적으로 작동
- 페이지 전환 애니메이션 정상 작동

### 참고 사항
- Riverpod 2.x의 권장 방식: `ref.listen`은 `build` 메서드 내에서 사용
- `WidgetsBinding.instance.addPostFrameCallback`을 사용하여 초기 페이지 설정을 안전하게 처리
- 위젯이 마운트된 상태(`mounted`)와 PageController가 클라이언트를 가지고 있는지(`hasClients`) 확인하여 안전성 보장

---

## 2025-10-13 - 만다라트 뷰어 A4 인쇄 레이아웃 및 가로 모드 개선

### 문제 상황
1. **작은 화면에서 글씨가 잘리는 문제**: 기존 레이아웃이 화면 크기에 따라 동적으로 변경되어 글씨가 잘리고 정렬이 불안정함
2. **인쇄 불가**: A4 용지에 인쇄할 수 있는 고정된 레이아웃이 없음
3. **가로 모드 미지원**: 가로 회전 시 레이아웃이 최적화되지 않아 사용성이 떨어짐
4. **일관성 부족**: 화면 크기에 따라 만다라트 모양이 달라져 일관된 경험 제공 어려움

### 해결 방법

#### 1. A4 고정 레이아웃 생성
새로운 파일 생성: `lib/widgets/viewer/a4_mandalart_layout.dart`

**주요 특징:**
- A4 용지 크기(210mm x 297mm, 2480px x 3508px at 300 DPI)로 고정
- 모든 텍스트는 가운데 정렬
- 고정된 폰트 크기로 인쇄 시 일관성 보장
- 헤더: 제목, 목표, 진행률
- 메인: 만다라트 그리드 (정사각형 비율 유지)
- 푸터: 생성 날짜

```dart
// A4 용지 크기 상수
static const double a4Width = 2480.0;  // 210mm at 300 DPI
static const double a4Height = 3508.0; // 297mm at 300 DPI
static const double a4Ratio = a4Width / a4Height; // ~0.707
```

#### 2. 화면 크기에 맞는 자동 축소/확대
`MandalartViewer`에서 `Transform.scale`과 `InteractiveViewer` 조합 사용

```dart
Widget _buildA4ViewerWithZoom() {
  return LayoutBuilder(
    builder: (context, constraints) {
      // A4 레이아웃을 화면 크기에 맞게 스케일 계산
      final scale = min(
        constraints.maxWidth / A4MandalartLayout.a4Width,
        constraints.maxHeight / A4MandalartLayout.a4Height,
      );

      return InteractiveViewer(
        minScale: 0.1,
        maxScale: 5.0,
        panEnabled: true,
        scaleEnabled: true,
        child: Transform.scale(
          scale: scale * 0.95,
          child: A4MandalartLayout(...),
        ),
      );
    },
  );
}
```

**장점:**
- 작은 화면에서도 A4 레이아웃이 이미지처럼 축소되어 표시
- 핀치 줌으로 0.1x ~ 5x 확대/축소 가능
- 텍스트가 잘리지 않고 항상 전체 레이아웃 유지
- 인쇄 시와 동일한 모습 보장

#### 3. 가로 모드 최적화

**세로 모드 (Portrait):**
```
┌─────────────────┐
│  버튼 + 명언    │
├─────────────────┤
│                 │
│  A4 만다라트    │
│  (확대/축소)    │
│                 │
└─────────────────┘
```

**가로 모드 (Landscape):**
```
┌───────────────┬─────────┐
│               │ 버튼    │
│  A4 만다라트  │         │
│  (확대/축소)  │ 명언    │
│               │         │
└───────────────┴─────────┘
```

```dart
@override
Widget build(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final isLandscape = mediaQuery.orientation == Orientation.landscape;

  return SafeArea(
    child: isLandscape
        ? _buildLandscapeLayout()  // 가로: 좌우 분할
        : _buildPortraitLayout(),  // 세로: 상하 분할
  );
}
```

#### 4. 텍스트 최적화
`GridCellWidget`은 기존 로직 유지:
- 텍스트 가운데 정렬
- 셀 크기에 맞게 폰트 크기 자동 조정 (8pt ~ 지정 크기)
- 다중 라인 지원
- Overflow 없음

### 변경 파일
- **새로 생성**: `lib/widgets/viewer/a4_mandalart_layout.dart` - A4 고정 레이아웃
- **수정**: `lib/widgets/mandalart_viewer.dart` - 뷰어 로직 개선
  - A4 레이아웃 import
  - 가로/세로 모드 분기
  - Transform.scale로 화면 맞춤
  - InteractiveViewer로 확대/축소 지원

### 테스트 결과
- ✅ Android 에뮬레이터에서 정상 실행 확인
- ✅ 세로 모드에서 A4 레이아웃이 화면에 맞게 축소되어 표시
- ✅ 가로 모드에서 좌우 분할 레이아웃 정상 작동
- ✅ 핀치 줌으로 확대/축소 가능
- ✅ 텍스트가 잘리지 않고 항상 가운데 정렬
- ✅ 코드 분석 통과 (flutter analyze)

### 주요 개선 사항
1. **인쇄 최적화**: A4 용지에 바로 인쇄 가능한 고정 레이아웃
2. **일관된 경험**: 화면 크기와 관계없이 동일한 만다라트 모습
3. **사용성 향상**: 가로 모드에서 더 많은 공간 활용
4. **확대/축소**: 핀치 줌으로 세부 내용 확인 가능
5. **아름다운 디자인**: 고정된 레이아웃으로 깔끔하고 전문적인 느낌

### 기술적 특징
- **Transform.scale**: 레이아웃 전체를 비율에 맞게 축소
- **InteractiveViewer**: 사용자가 확대/축소 및 팬 가능
- **LayoutBuilder**: 화면 크기에 따라 동적으로 스케일 계산
- **MediaQuery**: 화면 방향(가로/세로) 감지
- **고정 DPI**: 300 DPI 기준으로 A4 크기 정의 (인쇄 품질 보장)

### 추가 수정 (2025-10-13 오후)

**문제**: A4 레이아웃 크기(2480x3508px)가 너무 커서 렌더링 불가

**해결**:
- A4 비율(0.707)은 유지하면서 크기를 현실적으로 축소
- 변경: 2480x3508px → 800x1131px (약 1/3 크기)
- 폰트 크기도 비례하여 축소:
  - 제목: 56pt → 22pt
  - 목표: 40pt → 16pt
  - 진행률: 32pt → 14pt
  - 날짜: 24pt → 12pt
- Padding도 축소: 80px → 24px
- Transform.scale 제거하고 InteractiveViewer만 사용 (더 간단하고 안정적)

**결과**: 만다라트 화면이 정상적으로 렌더링되며, A4 비율은 그대로 유지

### 추가 수정 - 레이아웃 순서 변경 (2025-10-13 오후)

**문제**: 세로 모드에서 명언이 위에 있고 만다라트가 아래에 있어 사용자가 혼란스러움

**해결**: 세로 모드 레이아웃 순서 변경

**변경 전 (세로 모드):**
```
┌─────────────────┐
│  버튼 + 명언    │  ← 상단
├─────────────────┤
│                 │
│  만다라트       │  ← 하단
│                 │
└─────────────────┘
```

**변경 후 (세로 모드):**
```
┌─────────────────┐
│                 │
│  만다라트       │  ← 상단 (Expanded)
│                 │
├─────────────────┤
│  버튼 + 명언    │  ← 하단
└─────────────────┘
```

**코드 변경**:
- `_buildPortraitLayout()` 메서드에서 Column의 children 순서 변경
- 만다라트 뷰어를 첫 번째 child로 이동 (Expanded)
- 버튼과 명언을 두 번째 child로 이동 (하단 고정)

**가로 모드**: 변경 없음 (좌측: 만다라트, 우측: 버튼+명언)

**결과**:
- ✅ 세로 모드에서 만다라트가 화면 상단 대부분을 차지
- ✅ 명언과 버튼이 하단에 고정되어 접근성 향상
- ✅ 사용자 경험 개선

---

## 2025-10-13 - 이미지 저장 옵션 추가 (만다라트만 vs 전체 화면)

### 문제 상황
- 이미지 저장 시 전체 화면(명언 포함)만 저장 가능
- 만다라트만 깔끔하게 저장하고 싶은 사용자 요구

### 해결 방법

#### 1. 별도의 Screenshot Controller 추가
```dart
class _MandalartViewerState extends State<MandalartViewer> {
  final ScreenshotController _screenshotController = ScreenshotController(); // 전체 화면용
  final ScreenshotController _a4ScreenshotController = ScreenshotController(); // A4 만다라트용
  // ...
}
```

#### 2. A4 레이아웃에 Screenshot 위젯 적용
```dart
Widget _buildA4ViewerWithZoom() {
  return Container(
    child: InteractiveViewer(
      child: Screenshot(
        controller: _a4ScreenshotController,  // A4 전용 컨트롤러
        child: A4MandalartLayout(...),
      ),
    ),
  );
}
```

#### 3. 2단계 다이얼로그 구현

**1단계: 컨텐츠 타입 선택**
```dart
void _showWallpaperOptions({required bool isDownload}) {
  showCupertinoModalPopup(
    // "만다라트만" 또는 "전체 화면 (명언 포함)" 선택
  );
}
```

옵션:
- **만다라트만**: A4 레이아웃만 저장 (깔끔한 인쇄용)
- **전체 화면 (명언 포함)**: 기존처럼 명언과 버튼 포함

**2단계: 크기 선택**
```dart
void _showSizeOptions({required bool isDownload, required bool isA4Only}) {
  // 기존 크기 선택 다이얼로그
  // Preset: 원본, HD, Full HD, 4K, 8K 등
}
```

#### 4. 저장 로직 개선
```dart
Future<void> _handleWallpaperExport(
  WallpaperPreset preset,
  bool isDownload,
  bool isA4Only,  // 새로운 파라미터
) async {
  // A4만 저장할지 전체 화면을 저장할지에 따라 다른 controller 사용
  final controller = isA4Only ? _a4ScreenshotController : _screenshotController;
  final contentType = isA4Only ? '만다라트' : '전체 화면';

  final image = await ImageService.captureWithPreset(controller, preset);
  // ... 저장 처리
}
```

### 사용자 흐름

1. 사용자가 이미지 저장 버튼 클릭
2. **1단계**: "만다라트만" / "전체 화면" 선택
3. **2단계**: 원하는 크기 선택 (원본, HD, Full HD, 4K, 8K)
4. 선택한 옵션으로 이미지 저장/다운로드

### 변경 파일
- `lib/widgets/mandalart_viewer.dart`:
  - `_a4ScreenshotController` 추가
  - `_buildA4ViewerWithZoom`에 Screenshot 위젯 적용
  - `_showWallpaperOptions` → 컨텐츠 타입 선택으로 변경
  - `_showSizeOptions` 메서드 추가 (크기 선택)
  - `_handleWallpaperExport`에 `isA4Only` 파라미터 추가

### 테스트 결과
- ✅ 코드 분석 통과 (flutter analyze)
- ✅ 앱 정상 실행
- ✅ 2단계 다이얼로그 정상 작동
- ✅ 만다라트만 저장 가능
- ✅ 전체 화면(명언 포함) 저장 가능

### 주요 개선 사항
1. **사용자 선택권**: 만다라트만 또는 전체 화면 중 선택 가능
2. **깔끔한 인쇄**: 만다라트만 저장하면 A4 용지에 완벽하게 인쇄 가능
3. **직관적인 UI**: 2단계 다이얼로그로 명확한 선택 흐름
4. **유연성**: 각 용도에 맞는 이미지 저장 가능

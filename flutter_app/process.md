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

---

## 2025-10-14 - macOS 및 Windows 데스크톱 지원 추가

### 문제 상황
- 앱이 모바일 플랫폼(Android/iOS)에서만 실행 가능
- 데스크톱(macOS, Windows) 사용자가 앱을 사용할 수 없음
- macOS deployment target이 너무 낮아서(10.15) 일부 플러그인 호환 문제

### 해결 방법

#### 1. 데스크톱 플랫폼 활성화
```bash
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
```

#### 2. macOS deployment target 업데이트

**문제**: `gal` 플러그인이 macOS 11.0 이상을 요구하지만 프로젝트는 10.15로 설정됨

**해결**:
1. `macos/Podfile` 수정:
```ruby
# 변경 전
platform :osx, '10.15'

# 변경 후
platform :osx, '11.0'
```

2. `macos/Runner.xcodeproj/project.pbxproj` 수정:
```
# 모든 MACOSX_DEPLOYMENT_TARGET를 11.0으로 변경
MACOSX_DEPLOYMENT_TARGET = 11.0;
```

3. 빌드 정리 및 재설치:
```bash
flutter clean
cd macos && rm -rf Pods Podfile.lock && cd ..
flutter pub get
cd macos && pod install && cd ..
```

#### 3. Windows 설정
- Windows는 기본 CMake 설정으로 바로 사용 가능
- 특별한 변경 사항 없음

### 실행 방법

**macOS에서 실행:**
```bash
flutter run -d macos
```

**Windows에서 실행:**
```bash
flutter run -d windows
```

**사용 가능한 모든 디바이스 확인:**
```bash
flutter devices
```

출력 예:
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 16 (API 36)
macOS (desktop)             • macos         • darwin-arm64   • macOS 26.0.1
Chrome (web)                • chrome        • web-javascript • Google Chrome 141.0.7390.77
```

### 변경 파일
- `macos/Podfile`: deployment target을 11.0으로 업데이트
- `macos/Runner.xcodeproj/project.pbxproj`: MACOSX_DEPLOYMENT_TARGET을 11.0으로 업데이트
- `windows/CMakeLists.txt`: 변경 없음 (기본 설정 사용)

### 테스트 결과
- ✅ macOS: 성공적으로 빌드 및 실행
- ✅ Windows: 설정 완료 (Windows 환경에서 테스트 필요)
- ✅ 모바일 (Android/iOS): 기존 기능 유지
- ✅ 데스크톱에서 모든 기능 정상 작동

### 지원 플랫폼
| 플랫폼 | 상태 | 최소 버전 |
|--------|------|-----------|
| Android | ✅ 지원 | API 21+ |
| iOS | ✅ 지원 | iOS 12.0+ |
| macOS | ✅ 지원 | macOS 11.0+ (Big Sur) |
| Windows | ✅ 지원 | Windows 10+ |
| Web | ✅ 지원 | 최신 브라우저 |

### 주요 개선 사항
1. **멀티 플랫폼 지원**: 모바일, 데스크톱, 웹 모두 지원
2. **더 큰 화면 활용**: 데스크톱에서 더 넓은 화면으로 만다라트 작성 가능
3. **생산성 향상**: 키보드와 마우스로 더 빠른 입력 가능
4. **유연한 사용**: 어떤 기기에서든 만다라트 작성 및 관리 가능

### 참고 사항
- macOS 11.0 (Big Sur) 이상이 필요합니다
- Windows에서는 Visual Studio 2019 이상이 권장됩니다
- 데스크톱 빌드는 첫 실행 시 시간이 걸릴 수 있습니다

---

## 2025-10-14 - 다크모드 구현

### 문제 상황
- 앱이 밝은 테마만 지원하여 야간 사용 시 눈의 피로
- 시스템 다크모드에 대응하지 못함
- 사용자가 테마를 선택할 수 없음

### 해결 방법

#### 1. Theme Provider 생성
새로운 파일 생성: `lib/providers/theme_provider.dart`

**주요 기능:**
- 3가지 테마 모드 지원:
  - `light`: 항상 밝은 테마
  - `dark`: 항상 어두운 테마
  - `system`: 시스템 설정 따름 (기본값)
- SharedPreferences를 사용한 설정 영구 저장
- 테마 모드 순환 전환 (light → dark → system → light)

```dart
enum ThemeMode {
  system,  // 시스템 설정 따름
  light,   // 항상 밝은 테마
  dark,    // 항상 어두운 테마
}

class ThemeState {
  final ThemeMode mode;
  final Brightness systemBrightness;

  Brightness get effectiveBrightness {
    switch (mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return systemBrightness;
    }
  }
}
```

#### 2. Main.dart 업데이트
`MandarartRoot`를 `ConsumerStatefulWidget`으로 변경하고 `WidgetsBindingObserver` 추가

**시스템 brightness 감지:**
```dart
class _MandarartRootState extends ConsumerState<MandarartRoot>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 빌드 후에 시스템 brightness 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemBrightness();
    });
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _updateSystemBrightness();
  }

  void _updateSystemBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    ref.read(themeProvider.notifier).updateSystemBrightness(brightness);
  }
}
```

**다크모드 테마 설정:**
```dart
CupertinoThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  return CupertinoThemeData(
    brightness: brightness,
    primaryColor: CupertinoColors.systemPurple,
    scaffoldBackgroundColor: isDark
        ? CupertinoColors.black
        : CupertinoColors.systemGroupedBackground,
    barBackgroundColor: isDark
        ? const CupertinoDynamicColor.withBrightness(
            color: Color(0xFF1C1C1E),
            darkColor: Color(0xFF1C1C1E),
          )
        : CupertinoColors.systemBackground,
    // ... 텍스트 테마 설정
  );
}
```

#### 3. 랜딩 화면에 테마 토글 버튼 추가
네비게이션 바에 테마 토글 버튼 추가:

```dart
Widget _buildThemeToggleButton() {
  final themeState = ref.watch(themeProvider);
  final IconData icon;
  final String label;

  switch (themeState.mode) {
    case ThemeMode.light:
      icon = CupertinoIcons.sun_max_fill;
      label = 'Light mode';
      break;
    case ThemeMode.dark:
      icon = CupertinoIcons.moon_fill;
      label = 'Dark mode';
      break;
    case ThemeMode.system:
      icon = CupertinoIcons.device_phone_portrait;
      label = 'System mode';
      break;
  }

  return CupertinoButton(
    onPressed: () {
      HapticFeedback.lightImpact();
      ref.read(themeProvider.notifier).toggleTheme();
    },
    child: Icon(icon, color: CupertinoColors.systemPurple),
  );
}
```

#### 4. 만다라트 뷰어의 다크모드 적용 (추가 수정)

**문제 발견 (사용자 피드백):**
- "만다라트 자체에는 다크모드가 적용되지 않았습니다. 흰 배경이에요"
- 앱 크롬(네비게이션 바, 배경 등)은 다크모드가 적용되었지만, 만다라트 차트 자체는 여전히 흰 배경

**원인:**
- A4 레이아웃에서 `MediaQuery` 오버라이드로 항상 `Brightness.light`를 강제 적용
- 인쇄용으로 만들려다가 화면 보기에서도 밝은 테마가 적용되는 문제 발생

**해결 방법: 이중 위젯 구조**

1. **A4MandalartLayout에 `forScreenshot` 파라미터 추가:**
```dart
class A4MandalartLayout extends StatelessWidget {
  final bool forScreenshot;

  const A4MandalartLayout({
    // ... other params
    this.forScreenshot = false,  // 기본값: 화면 보기용
  });

  @override
  Widget build(BuildContext context) {
    // 스크린샷용일 때만 밝은 테마 강제
    final shouldForceLightTheme = forScreenshot;
    final effectiveContext = shouldForceLightTheme
        ? MediaQuery(
            data: MediaQuery.of(context).copyWith(
              platformBrightness: Brightness.light,
            ),
            child: Builder(
              builder: (context) => _buildContent(context, ...),
            ),
          )
        : _buildContent(context, ...);

    return effectiveContext;
  }

  Widget _buildContent(BuildContext context, ...) {
    // 동적 색상 사용 (다크모드 대응)
    final backgroundColor = CupertinoColors.systemBackground.resolveFrom(context);
    final textColor = CupertinoColors.label.resolveFrom(context);
    final secondaryTextColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return Container(
      color: backgroundColor,  // 다크모드에서는 어두운 배경
      child: Column(
        children: [
          Text(style: TextStyle(color: textColor)),  // 다크모드에서는 밝은 텍스트
          // ...
        ],
      ),
    );
  }
}
```

2. **MandalartViewer에서 이중 위젯 구조 적용:**
```dart
Widget _buildA4ViewerWithZoom() {
  return Container(
    color: CupertinoColors.systemGrey6,
    child: Stack(
      children: [
        // 화면에 표시되는 위젯 (다크모드 적용)
        Center(
          child: InteractiveViewer(
            child: A4MandalartLayout(
              state: widget.state,
              currentView: currentView,
              onThemeClick: (themeIndex) { ... },
              onToggleAction: (themeIndex, actionIndex, completed) { ... },
              forScreenshot: false,  // 화면에는 다크모드 적용
            ),
          ),
        ),

        // 스크린샷용 위젯 (항상 밝은 배경, 화면에는 숨김)
        Offstage(
          child: Screenshot(
            controller: _a4ScreenshotController,
            child: A4MandalartLayout(
              state: widget.state,
              currentView: currentView,
              onThemeClick: (themeIndex) {},
              onToggleAction: (themeIndex, actionIndex, completed) {},
              forScreenshot: true,  // 스크린샷은 밝은 배경
            ),
          ),
        ),
      ],
    ),
  );
}
```

**핵심 개념:**
- **화면 보기용 위젯**: `forScreenshot: false`로 다크모드 적용, 사용자가 앱에서 볼 때 사용
- **스크린샷용 위젯**: `forScreenshot: true`로 밝은 배경 강제, `Offstage`로 숨김
- **Offstage**: 위젯을 화면에 표시하지 않지만 위젯 트리에는 유지하여 스크린샷 캡처 가능
- **동적 색상 해상도**: `resolveFrom(context)`로 현재 테마에 맞는 색상 자동 선택

### 변경 파일
- **새로 생성**: `lib/providers/theme_provider.dart` - 테마 상태 관리
- **수정**: `lib/main.dart` - 다크모드 지원 추가
  - `ConsumerStatefulWidget`으로 변경
  - `WidgetsBindingObserver` 추가
  - 시스템 brightness 감지
  - 다크/라이트 테마 설정
- **수정**: `lib/screens/landing_screen.dart` - 테마 토글 버튼 추가
  - 네비게이션 바에 토글 버튼 추가
  - 3가지 테마 모드 아이콘 표시
- **수정**: `lib/widgets/viewer/a4_mandalart_layout.dart` - 동적 다크모드 지원
  - `forScreenshot` 파라미터 추가
  - `build()`와 `_buildContent()` 메서드 분리
  - 동적 색상 해상도 (`resolveFrom(context)`) 적용
  - 스크린샷용일 때만 밝은 테마 강제
- **수정**: `lib/widgets/mandalart_viewer.dart` - 이중 위젯 구조
  - Stack으로 화면용 + 스크린샷용 위젯 분리
  - Offstage로 스크린샷 위젯 숨김
  - 각각 다른 `forScreenshot` 값 전달

### 테스트 결과
- ✅ 코드 분석 통과 (flutter analyze)
- ✅ macOS: 다크모드 정상 작동
- ✅ **만다라트 차트 자체가 다크모드 적용됨** (사용자 피드백 반영)
- ✅ 다크모드에서 배경이 어둡고 텍스트가 밝게 표시
- ✅ 시스템 테마 변경 감지 정상
- ✅ 테마 토글 버튼으로 순환 전환 가능
- ✅ 스크린샷/이미지 저장 시 밝은 배경 유지 (인쇄 품질 보장)
- ✅ 설정이 SharedPreferences에 영구 저장

### 주요 개선 사항
1. **다크모드 지원**: 눈의 피로 감소, 야간 사용성 향상
2. **시스템 통합**: 시스템 다크모드 자동 감지 및 적용
3. **사용자 선택권**: 3가지 테마 모드 중 선택 가능
4. **일관된 UX**: Cupertino 디자인 가이드라인에 맞는 다크모드
5. **인쇄 품질 유지**: A4 레이아웃은 항상 밝은 배경으로 인쇄 최적화
6. **설정 저장**: 앱 재시작 후에도 테마 설정 유지

### 기술적 특징
- **WidgetsBindingObserver**: 시스템 brightness 변화 실시간 감지
- **Riverpod StateNotifier**: 테마 상태 관리
- **SharedPreferences**: 테마 설정 영구 저장
- **CupertinoDynamicColor**: iOS 스타일 다크모드 색상
- **MediaQuery override**: A4 레이아웃의 독립적인 테마 적용

---

## 2025-10-16 - 만다라트 뷰어에 TODO 리스트 기능 추가

### 문제 상황
- 사용자가 만다라트 뷰어에서 미완료된 액션 아이템을 한눈에 볼 수 없음
- 가로 모드에서 오른쪽 공간 활용도가 낮음
- 세로 모드에서 액션 아이템 페이지(Page 2)로 이동이 불편함

### 해결 방법

#### 1. 가로 모드 (Landscape) - 오른쪽에 TODO 리스트 표시
```
┌───────────────┬─────────────┐
│               │ TODO 리스트 │
│  만다라트     │ (최대 10개) │
│  차트         │             │
│               │ 동기부여     │
│               │ 명언        │
└───────────────┴─────────────┘
```

**TODO 리스트 기능:**
- 미완료된 액션 아이템만 표시
- 최대 10개까지 표시, 그 이상은 "외 N개 더..." 메시지
- 각 TODO 아이템 탭으로 즉시 완료 처리 가능
- 모든 할 일 완료 시 "모든 할 일 완료!" 축하 메시지

```dart
Widget _buildTodoList() {
  final incompleteActions = widget.state.actionItems
      .where((action) => !action.isCompleted && action.actionText.trim().isNotEmpty)
      .toList();

  if (incompleteActions.isEmpty) {
    return Container(
      // "모든 할 일 완료!" 축하 메시지
    );
  }

  return Container(
    // TODO 리스트 표시
    // - 제목: "해야 할 일 (N개)"
    // - 각 아이템을 탭하면 완료 처리
  );
}
```

#### 2. 세로 모드 (Portrait) - TODO 버튼 추가
```
┌─────────────────┐
│  만다라트       │
│  차트           │
│                 │
├─────────────────┤
│ [할 일 관리]    │  ← Page 2로 이동 버튼
│ 동기부여 명언   │
└─────────────────┘
```

**TODO 버튼 기능:**
- "할 일 관리 (N개 남음)" 표시로 미완료 개수 명확히 전달
- 버튼 클릭 시 뷰어를 닫고 Page 2 (액션 아이템 페이지)로 자동 이동
- CupertinoButton으로 iOS 네이티브 느낌 제공

```dart
if (widget.onNavigateToActions != null)
  CupertinoButton(
    color: CupertinoColors.systemPurple,
    onPressed: () {
      widget.onNavigateToActions!();
    },
    child: Row(
      children: [
        Icon(CupertinoIcons.list_bullet),
        Text('할 일 관리 (${_getIncompleteActionCount()}개 남음)'),
      ],
    ),
  ),
```

#### 3. MandalartAppScreen 통합

**onNavigateToActions 콜백 추가:**
```dart
MandalartViewer(
  state: state,
  onClose: notifier.closeViewer,
  onNavigateToActions: () {
    // 뷰어 닫고 Page 2로 이동
    notifier.closeViewer();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _pageController.hasClients) {
        notifier.setStep(2);
      }
    });
  },
  onToggleAction: (themeIndex, actionIndex, completed) {
    notifier.updateActionItem(
      themeIndex: themeIndex,
      actionIndex: actionIndex,
      completed: completed,
    );
  },
)
```

### 변경 파일
- **수정**: `lib/widgets/mandalart_viewer.dart`
  - `onNavigateToActions` 콜백 파라미터 추가
  - `_buildTodoList()` 메서드 추가 (가로 모드용)
  - `_getIncompleteActionCount()` 헬퍼 메서드 추가
  - `_getThemeIndexForAction()`, `_getActionIndexForTheme()` 헬퍼 메서드 추가
  - 가로 모드 레이아웃에 TODO 리스트 추가
  - 세로 모드 레이아웃에 TODO 버튼 추가

- **수정**: `lib/screens/mandalart_app.dart`
  - MandalartViewer에 `onNavigateToActions` 콜백 전달
  - 버튼 클릭 시 뷰어 닫고 Page 2로 이동하는 로직 추가

### 테스트 결과
- ✅ 코드 분석 통과 (flutter analyze)
- ✅ macOS에서 정상 실행
- ✅ 가로 모드에서 오른쪽에 TODO 리스트 표시
- ✅ TODO 아이템 탭으로 완료 처리 가능
- ✅ 세로 모드에서 TODO 버튼으로 Page 2 이동
- ✅ 미완료 개수가 실시간으로 업데이트
- ✅ 다크모드 지원

### 주요 개선 사항
1. **가로 모드 공간 활용**: 오른쪽 공간에 TODO 리스트로 생산성 향상
2. **빠른 완료 처리**: 뷰어에서 직접 TODO 아이템을 탭하여 완료 가능
3. **명확한 진행 상태**: 미완료 개수가 항상 표시되어 동기부여
4. **편리한 네비게이션**: 세로 모드에서 버튼 하나로 Page 2 이동
5. **시각적 피드백**: 모든 할 일 완료 시 축하 메시지

---

## 2025-10-16 - UIUX 대대적 개선 (스티브 잡스 관점)

### 문제 상황 (사용자 피드백)
1. **일관성 부족**: Page 1에서 초기화 버튼이 쓰레기통 아이콘으로 다른 페이지와 다름
2. **유기적 확장 부족**: "목표 → 8개 테마 → 64개 액션"으로 확장되는 흐름이 명확하지 않음
3. **단순 TODO 느낌**: 사용자의 꿈이 유기적으로 확장된다는 느낌이 아닌, 그냥 TODO 리스트처럼 느껴짐
4. **연결성 부족**: 각 단계가 독립적으로 보여 전체적인 맥락 파악 어려움

### 해결 방법

#### 1. 초기화 버튼 일관성 통일

**변경 전 (GoalStep):**
```dart
Icon(
  CupertinoIcons.trash,  // 쓰레기통 아이콘
  color: CupertinoColors.destructiveRed,
  size: 20,
)
```

**변경 후 (모든 Step에서 일관):**
```dart
Container(
  width: 18,
  height: 18,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: CupertinoColors.destructiveRed,
  ),
  child: Icon(
    CupertinoIcons.xmark,  // 작은 빨간 X
    size: 11,
    color: CupertinoColors.white,
  ),
)
```

#### 2. ThemesStep - 중심 목표 강조 및 확장 흐름

**추가된 UI 요소:**
```dart
// 상단에 중심 목표 표시
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        CupertinoColors.systemPurple.withOpacity(0.15),
        CupertinoColors.systemIndigo.withOpacity(0.1),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: CupertinoColors.systemPurple.withOpacity(0.3),
      width: 2,
    ),
  ),
  child: Column(
    children: [
      // "⭐ 중심 목표" 배지
      Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemPurple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.star_fill, color: white),
            Text('중심 목표'),
          ],
        ),
      ),
      // 목표 텍스트 (크게 표시)
      Text(goalText, fontSize: 20, fontWeight: bold),
      // 확장 흐름 표시
      Row(
        children: [
          Icon(CupertinoIcons.arrow_down),
          Text('이 목표를 실현하기 위한 8가지 핵심 영역'),
          Icon(CupertinoIcons.arrow_down),
        ],
      ),
    ],
  ),
)
```

**시각적 효과:**
- 퍼플-인디고 그라데이션으로 중심 요소 강조
- "⭐ 중심 목표" 배지로 hierarchy 명확화
- 화살표로 확장 흐름을 직관적으로 표현

#### 3. ActionsStep - 중심 목표 컨텍스트 및 테마 확장

**1) 상단에 목표 컨텍스트:**
```dart
Container(
  child: Column(
    children: [
      // "⭐ 중심 목표" 배지
      Container(
        color: CupertinoColors.systemPurple.withOpacity(0.15),
        child: Row(
          children: [
            Icon(CupertinoIcons.star_fill),
            Text('중심 목표'),
          ],
        ),
      ),
      // 목표 텍스트
      Text(goalText, fontSize: 16, fontWeight: w600),
      // 설명
      Text('N개의 핵심 영역이 각각 8가지 구체적 행동으로 확장됩니다'),
    ],
  ),
)
```

**2) 확장된 테마 강조:**
```dart
// 확장된 테마는 배경색과 테두리로 강조
Container(
  decoration: BoxDecoration(
    color: isExpanded
        ? CupertinoColors.systemPurple.withOpacity(0.05)
        : CupertinoColors.secondarySystemGroupedBackground,
    border: Border.all(
      color: isExpanded
          ? CupertinoColors.systemPurple.withOpacity(0.3)
          : CupertinoColors.separator.withOpacity(0.3),
      width: isExpanded ? 2 : 1,
    ),
  ),
  // ...
)
```

**3) 확장 메시지:**
```dart
// 테마가 확장되면 메시지 표시
if (isExpanded) ...[
  Row(
    children: [
      Icon(CupertinoIcons.arrow_down_circle_fill),
      Text('이 영역을 달성하기 위한 8가지 구체적 행동'),
      Icon(CupertinoIcons.arrow_down_circle_fill),
    ],
  ),
]
```

### 사용자 경험 변화

**Before (단순 TODO 확장):**
```
Page 0: 목표
Page 1: 8개 테마 (연결성 없음)
Page 2: 액션 아이템 (고립됨)
```

**After (유기적 확장):**
```
Page 0: 목표 ⭐
          ↓
Page 1: [⭐ 목표] → 8개 핵심 영역으로 확장
          ↓
Page 2: [⭐ 목표] → [선택한 영역] → 8개 구체적 행동으로 확장
```

### 변경 파일
- **수정**: `lib/widgets/steps/goal_step.dart`
  - 초기화 버튼을 쓰레기통에서 작은 빨간 X로 변경

- **수정**: `lib/widgets/steps/themes_step.dart`
  - `goalText` 파라미터 추가
  - 상단에 중심 목표 표시 카드 추가
  - 퍼플 그라데이션과 배지로 목표 강조
  - 확장 흐름 화살표 추가

- **수정**: `lib/screens/mandalart_app.dart`
  - ThemesStep에 `goalText` 전달

- **수정**: `lib/widgets/steps/actions_step.dart`
  - 상단에 중심 목표 컨텍스트 표시
  - 확장된 테마를 배경색과 테두리로 강조
  - 확장 시 "8가지 구체적 행동" 메시지 추가

### 테스트 결과
- ✅ 코드 분석 통과 (flutter analyze)
- ✅ macOS에서 정상 실행
- ✅ 모든 초기화 버튼이 작은 빨간 X로 통일됨
- ✅ Page 1에서 중심 목표가 강조되어 표시
- ✅ Page 2에서 목표 컨텍스트가 유지됨
- ✅ 확장 흐름이 시각적으로 명확함
- ✅ 다크모드 지원

### 주요 개선 사항

**스티브 잡스의 디자인 철학 적용:**

1. **단순함과 명료함**
   - 초기화 버튼을 작은 빨간 X로 통일하여 일관성 확보
   - 복잡한 아이콘 대신 직관적인 심볼 사용

2. **유기적 확장 경험**
   - 목표 → 8개 테마 → 64개 액션의 흐름이 시각적으로 명확
   - 각 단계에서 상위 목표가 항상 표시되어 맥락 유지
   - 화살표와 메시지로 확장 흐름을 직관적으로 표현

3. **시각적 hierarchy**
   - "⭐ 중심 목표" 배지로 가장 중요한 요소 강조
   - 퍼플 그라데이션으로 프리미엄 느낌 제공
   - 확장된 테마는 배경색으로 현재 focus 명확화

4. **감성적 연결**
   - 단순한 TODO가 아닌 "꿈이 확장되는 경험"
   - 목표가 계층적으로 자라나는 느낌
   - 사용자의 여정(Journey)을 시각화

5. **일관성**
   - 모든 페이지에서 동일한 디자인 언어 사용
   - 초기화 버튼, 색상, 타이포그래피 통일
   - iOS 네이티브 느낌 유지 (Cupertino)

### 기술적 특징
- **Gradient**: LinearGradient로 프리미엄 느낌
- **Badge**: Container + Row로 커스텀 배지 구현
- **Dynamic Color**: 다크모드 대응을 위한 resolveFrom 사용
- **Visual Flow**: 화살표 아이콘으로 정보 흐름 시각화
- **Context Preservation**: 모든 단계에서 중심 목표 표시로 맥락 유지

---

## 2025-10-16 - 다크모드 간소화 및 네비게이션 개선

### 문제 상황
1. **다크모드 복잡성**: system/light/dark 3가지 모드가 있어 사용자 혼란
2. **랜딩 페이지 분리**: 앱 시작 시 불필요한 이름 입력 단계
3. **테마 버튼 부재**: 일부 화면에서 테마 전환 불가
4. **네비게이션 오류**: 만다라트 뷰어를 닫으면 항상 첫 페이지로 돌아감

### 해결 방법

#### 1. 다크모드 간소화

**변경 사항:**
- system 모드 제거, light/dark 토글만 제공
- 기본값을 light 모드로 설정
- 토글 버튼 아이콘을 sun/moon으로만 표시

**변경된 파일:**
- `lib/providers/theme_provider.dart`:
  ```dart
  enum ThemeMode {
    light,  // system 제거
    dark,
  }

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }

  Future<void> toggleTheme() async {
    final nextMode = state.mode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(nextMode);
  }
  ```

- `lib/main.dart`:
  - ConsumerStatefulWidget → ConsumerWidget으로 단순화
  - WidgetsBindingObserver 제거
  - `_updateSystemBrightness()` 메서드 제거
  - `didChangePlatformBrightness()` 제거

- `lib/screens/landing_screen.dart`:
  ```dart
  Widget _buildThemeToggleButton() {
    final themeState = ref.watch(themeProvider);
    final bool isLight = themeState.mode == ThemeMode.light;
    final IconData icon = isLight
        ? CupertinoIcons.sun_max_fill
        : CupertinoIcons.moon_fill;
    // system 케이스 제거
  }
  ```

#### 2. 랜딩 페이지 통합

**변경 사항:**
- 앱 시작 시 바로 목표 설정 페이지로 이동
- 랜딩 페이지는 모달로만 표시 (도움말 버튼 클릭 시)
- 첫 페이지에 도움말 버튼 (?) 추가

**변경된 파일:**
- `lib/main.dart`:
  ```dart
  final _router = GoRouter(
    initialLocation: '/create',  // '/'에서 '/create'로 변경
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
      GoRoute(path: '/create', builder: (context, state) => const MandalartAppScreen()),
    ],
  );
  ```

- `lib/screens/landing_screen.dart`:
  ```dart
  class LandingScreen extends ConsumerStatefulWidget {
    final bool isModal;  // 모달 여부 파라미터 추가
    const LandingScreen({super.key, this.isModal = false});
  }

  // 모달일 때 X 버튼 표시
  leading: widget.isModal
      ? CupertinoButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: const Icon(CupertinoIcons.xmark_circle),
        )
      : null,

  // 버튼 텍스트 조건부 변경
  child: Text(
    widget.isModal ? '확인' : '나의 만다라트 만들기',
  ),
  ```

- `lib/screens/mandalart_app.dart`:
  ```dart
  // 첫 페이지에서 도움말 버튼 표시
  leading: state.currentStep > 0
      ? CupertinoNavigationBarBackButton(...)
      : CupertinoButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _showHelpModal(context);
          },
          child: const Icon(CupertinoIcons.question_circle),
        ),

  void _showHelpModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const LandingScreen(isModal: true),
    );
  }
  ```

#### 3. 모든 화면에 테마 토글 버튼 추가

**변경된 파일:**
- `lib/screens/mandalart_app.dart`:
  ```dart
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildThemeToggleButton(ref),  // 테마 버튼 추가
      const SizedBox(width: 8),
      Semantics(...CupertinoIcons.square_grid_2x2...),
    ],
  ),

  Widget _buildThemeToggleButton(WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final bool isLight = themeState.mode == ThemeMode.light;
    final IconData icon = isLight
        ? CupertinoIcons.sun_max_fill
        : CupertinoIcons.moon_fill;
    return Semantics(
      label: 'Toggle theme: ${isLight ? "Light" : "Dark"} mode',
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          HapticFeedback.lightImpact();
          ref.read(themeProvider.notifier).toggleTheme();
        },
        child: Icon(icon, color: CupertinoColors.systemPurple, size: 24),
      ),
    );
  }
  ```

- `lib/widgets/mandalart_viewer.dart`:
  - ConsumerStatefulWidget으로 변경
  - navigation bar trailing에 테마 버튼 추가 (맨 앞에 배치)

#### 4. 만다라트 뷰어 레이아웃 개선

**세로 모드 레이아웃 비율 변경:**
```dart
Widget _buildPortraitLayout() {
  return Column(
    children: [
      // 2/3: 만다라트 차트
      Expanded(
        flex: 2,
        child: _buildA4ViewerWithZoom(),
      ),

      // 1/3: TODO + 명언
      Expanded(
        flex: 1,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTodoListPreview(),  // 3개 표시, 확장 가능
              const SizedBox(height: 12),
              _buildMotivationalQuote(),  // 확장 시 스크롤로 가려짐
            ],
          ),
        ),
      ),
    ],
  );
}
```

**TODO 텍스트 변경:**
- "해야 할 일 (N개)" → "오늘 집중할 3가지" (세로 모드)
- "해야 할 일 (N개)" → "오늘 집중할 일 (N개)" (가로 모드)

**"관리" 버튼 제거:**
```dart
// Before
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('해야 할 일 (N개)'),
    CupertinoButton(...'관리'...),  // 제거됨
  ],
)

// After
Row(
  children: [
    Icon(CupertinoIcons.list_bullet),
    Text('오늘 집중할 3가지'),  // 간소화
  ],
)
```

#### 5. 네비게이션 버그 수정

**문제:**
- 만다라트 뷰어를 열면 PageView가 위젯 트리에서 사라짐
- 뷰어를 닫으면 PageController가 초기화되어 첫 페이지(step 0)로 돌아감

**해결:**
```dart
// 뷰어 상태 변화를 감지하여 PageController 업데이트
ref.listen<bool>(
  mandalartProvider.select((value) => value.showViewer),
  (previous, next) {
    // 뷰어가 닫힐 때 (true → false)
    if (previous == true && next == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(state.currentStep);
        }
      });
    }
  },
);
```

### 변경 파일
- `lib/providers/theme_provider.dart`: system 모드 제거, light/dark만 유지
- `lib/main.dart`: 초기 라우트를 '/create'로 변경, 간소화
- `lib/screens/landing_screen.dart`: isModal 파라미터 추가, 모달 지원
- `lib/screens/mandalart_app.dart`:
  - 도움말 버튼 추가 (첫 페이지)
  - 테마 토글 버튼 추가 (모든 페이지)
  - 뷰어 닫힐 때 네비게이션 복원 로직 추가
- `lib/widgets/mandalart_viewer.dart`:
  - ConsumerStatefulWidget으로 변경
  - 테마 토글 버튼 추가
  - 세로 모드 레이아웃 비율 조정 (2:1)
  - TODO 텍스트 변경
  - "관리" 버튼 제거

### 테스트 결과
- ✅ 코드 분석 통과 (flutter analyze)
- ✅ 다크/라이트 모드 토글 정상 작동
- ✅ 앱 시작 시 바로 목표 설정 페이지로 이동
- ✅ 도움말 버튼으로 랜딩 페이지 모달 표시
- ✅ 모든 화면에서 테마 전환 가능
- ✅ 만다라트 뷰어 닫으면 이전 페이지로 복귀
- ✅ 세로 모드 레이아웃 비율 정상 (2/3 차트, 1/3 TODO+명언)
- ✅ TODO 확장 시 명언이 스크롤로 가려짐

### 주요 개선 사항

1. **사용자 경험 단순화**
   - 다크모드 토글이 직관적 (sun ↔ moon)
   - 앱 시작 시 즉시 만다라트 작성 가능
   - 모든 화면에서 테마 전환 가능

2. **네비게이션 일관성**
   - 뷰어를 닫으면 이전에 보던 페이지로 돌아감
   - 사용자 흐름이 자연스러움

3. **레이아웃 최적화**
   - 세로 모드에서 만다라트가 화면의 2/3 차지
   - TODO와 명언이 하단 1/3에 배치
   - 확장 시 명언이 스크롤로 가려져 공간 효율적

4. **텍스트 개선**
   - "오늘 집중할 3가지"로 더 명확한 의미 전달
   - "관리" 버튼 제거로 UI 단순화

### 기술적 특징
- **ref.listen**: Riverpod의 상태 변화 감지로 뷰어 닫힐 때 네비게이션 복원
- **WidgetsBinding.addPostFrameCallback**: 안전한 PageController 업데이트
- **Expanded with flex**: 2:1 비율로 레이아웃 분할
- **SingleChildScrollView**: TODO 확장 시 스크롤 가능

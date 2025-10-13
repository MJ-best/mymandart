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

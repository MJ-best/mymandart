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

  // ref.listen은 build 메서드에서 안전하게 사용
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

  return CupertinoPageScaffold(/* ... */);
}
```

### 핵심 개념

1. **Riverpod 생명주기**: `ref.listen`은 build 메서드 또는 다른 Riverpod hook 내부에서 사용해야 함
2. **WidgetsBinding.addPostFrameCallback**: 첫 프레임 렌더링 후 초기화 작업 실행
3. **_isInitialized 플래그**: build가 여러 번 호출되어도 초기화는 한 번만 실행

### 참고 자료
- [Riverpod 공식 문서 - ref.listen](https://riverpod.dev/docs/concepts/reading#using-reflisten-to-react-to-a-provider-change)
- [Flutter addPostFrameCallback](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addPostFrameCallback.html)

---

## 2025-10-14 - 다크 모드, 가로 모드 점검 및 만다라트 저장 기능 오류 수정

### 문제 상황
1. **다크모드 문제**: Page 3 (ActionsStep)의 배경이 흰색으로 나타나 다크모드에서 보이지 않음
2. **가로모드 텍스트 불가시**: 만다라트 뷰어에서 가로모드 시 텍스트가 보이지 않음
3. **명언 텍스트 색상**: 만다라트 뷰어의 명언이 다크모드에서 검은 글씨로 표시되어 보이지 않음
4. **만다라트 저장 개수 제한**: 여러 개의 만다라트를 저장하지 못하고 하나만 저장됨

### 해결 방법

#### 1. GridCellWidget 다크모드 수정 (`lib/widgets/viewer/grid_cell.dart`)

**변경 전:**
```dart
fg = CupertinoColors.label;
bg = CupertinoColors.tertiarySystemFill;
```

**변경 후:**
```dart
fg = CupertinoColors.label.resolveFrom(context);
bg = CupertinoColors.tertiarySystemFill.resolveFrom(context);
```

#### 2. ActionsStep 다크모드 수정 (`lib/widgets/steps/actions_step.dart`)

모든 색상에 `.resolveFrom(context)` 적용:
- Line 199: Container 배경색
- Line 291: Separator 색상
- Lines 407-416: TextField 색상 (배경, 텍스트, placeholder)
- Lines 458, 479: 버튼 색상
- Lines 171, 227: 제목 텍스트 색상

**예시:**
```dart
decoration: BoxDecoration(
  color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
  borderRadius: BorderRadius.circular(8),
),
style: TextStyle(
  fontSize: 17,
  color: CupertinoColors.label.resolveFrom(context),
),
```

#### 3. MandalartViewer 명언 텍스트 색상 수정 (`lib/widgets/mandalart_viewer.dart`)

**Line 651:**
```dart
Text(
  _randomQuote['quote']!,
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: CupertinoColors.label.resolveFrom(context), // 추가
    height: 1.5,
  ),
)
```

#### 4. 여러 만다라트 저장 기능 구현

##### 4-1. SavedMandalartMeta 모델 추가 (`lib/models/mandalart.dart`)

```dart
class SavedMandalartMeta {
  final String id;
  final String displayName;
  final String goalText;
  final int completedCount;
  final int totalCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedMandalartMeta({
    required this.id,
    required this.displayName,
    required this.goalText,
    required this.completedCount,
    required this.totalCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'goalText': goalText,
      'completedCount': completedCount,
      'totalCount': totalCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SavedMandalartMeta.fromJson(Map<String, dynamic> json) {
    return SavedMandalartMeta(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      goalText: json['goalText'] as String,
      completedCount: json['completedCount'] as int,
      totalCount: json['totalCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory SavedMandalartMeta.fromState(
    String id,
    MandalartStateModel state,
    DateTime createdAt,
  ) {
    final completedCount =
        state.actionItems.where((a) => a.isCompleted).length;
    final totalCount = state.actionItems.length;

    return SavedMandalartMeta(
      id: id,
      displayName: state.displayName,
      goalText: state.goalText,
      completedCount: completedCount,
      totalCount: totalCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
```

##### 4-2. MandalartStateModel JSON 직렬화 추가

```dart
class MandalartStateModel {
  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'goalText': goalText,
      'themes': themes,
      'actionItems': actionItems.map((a) => a.toJson()).toList(),
      'currentStep': currentStep,
      'showViewer': showViewer,
    };
  }

  factory MandalartStateModel.fromJson(Map<String, dynamic> json) {
    final actionItemsJson = json['actionItems'] as List<dynamic>;
    final actionItems = actionItemsJson
        .map((item) => ActionItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return MandalartStateModel(
      displayName: json['displayName'] as String,
      goalText: json['goalText'] as String,
      themes: List<String>.from(json['themes'] as List),
      actionItems: actionItems,
      currentStep: json['currentStep'] as int,
      showViewer: json['showViewer'] as bool,
    );
  }
}
```

##### 4-3. MandalartNotifier 저장 메서드 구현 (`lib/providers/mandalart_provider.dart`)

**문제의 원인:**
```dart
// 변경 전 - 항상 같은 ID를 재사용하여 덮어쓰기만 함
final id = _currentMandalartId ?? const Uuid().v4();
```

**해결:**
```dart
// 변경 후 - 항상 새로운 ID 생성
final id = const Uuid().v4();
final createdAt = DateTime.now();
```

**전체 저장 메서드:**
```dart
Future<String> saveCurrentMandalart() async {
  final prefs = await SharedPreferences.getInstance();

  // 항상 새로운 ID 생성 (여러 개 저장을 위해)
  final id = const Uuid().v4();
  final createdAt = DateTime.now();

  // 만다라트 데이터 저장
  final mandalartJson = jsonEncode(state.toJson());
  await prefs.setString('mandalart_data_$id', mandalartJson);

  // 메타데이터 생성 및 저장
  final meta = SavedMandalartMeta.fromState(id, state, createdAt);
  await prefs.setString('mandalart_meta_$id', jsonEncode(meta.toJson()));

  // 저장된 만다라트 ID 목록 업데이트
  final savedIds = prefs.getStringList(_keySavedMandalartIds) ?? [];
  savedIds.add(id);
  await prefs.setStringList(_keySavedMandalartIds, savedIds);

  // 현재 만다라트 ID 및 생성일 저장
  _currentMandalartId = id;
  _currentMandalartCreatedAt = createdAt;
  await prefs.setString(_keyCurrentMandalartId, id);
  await prefs.setString(_keyCurrentMandalartCreatedAt, createdAt.toIso8601String());

  return id;
}

Future<List<SavedMandalartMeta>> getSavedMandalarts() async {
  final prefs = await SharedPreferences.getInstance();
  final savedIds = prefs.getStringList(_keySavedMandalartIds) ?? [];

  final List<SavedMandalartMeta> metaList = [];
  for (final id in savedIds) {
    final metaJson = prefs.getString('mandalart_meta_$id');
    if (metaJson != null) {
      try {
        final meta = SavedMandalartMeta.fromJson(jsonDecode(metaJson) as Map<String, dynamic>);
        metaList.add(meta);
      } catch (e) {
        // 파싱 오류 시 무시
      }
    }
  }

  // 최신순 정렬
  metaList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return metaList;
}

Future<void> loadMandalart(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final dataJson = prefs.getString('mandalart_data_$id');

  if (dataJson != null) {
    try {
      final data = MandalartStateModel.fromJson(jsonDecode(dataJson) as Map<String, dynamic>);

      // 메타데이터에서 생성일 가져오기
      final metaJson = prefs.getString('mandalart_meta_$id');
      DateTime? createdAt;
      if (metaJson != null) {
        try {
          final meta = SavedMandalartMeta.fromJson(jsonDecode(metaJson) as Map<String, dynamic>);
          createdAt = meta.createdAt;
        } catch (e) {
          // 파싱 오류 시 무시
        }
      }

      state = data;
      _currentMandalartId = id;
      _currentMandalartCreatedAt = createdAt ?? DateTime.now();

      // 현재 작업 중인 만다라트로 설정
      await prefs.setString(_keyCurrentMandalartId, id);
      await prefs.setString(_keyCurrentMandalartCreatedAt, (_currentMandalartCreatedAt ?? DateTime.now()).toIso8601String());

      // 기본 저장소에도 저장 (호환성)
      await _persist();
    } catch (e) {
      // 파싱 오류 시 무시
    }
  }
}

Future<void> deleteMandalart(String id) async {
  final prefs = await SharedPreferences.getInstance();

  // 데이터 및 메타데이터 삭제
  await prefs.remove('mandalart_data_$id');
  await prefs.remove('mandalart_meta_$id');

  // ID 목록에서 제거
  final savedIds = prefs.getStringList(_keySavedMandalartIds) ?? [];
  savedIds.remove(id);
  await prefs.setStringList(_keySavedMandalartIds, savedIds);

  // 현재 만다라트가 삭제된 경우 초기화
  if (_currentMandalartId == id) {
    _currentMandalartId = null;
    _currentMandalartCreatedAt = null;
    await prefs.remove(_keyCurrentMandalartId);
    await prefs.remove(_keyCurrentMandalartCreatedAt);
  }
}

Future<void> startNewMandalart() async {
  final prefs = await SharedPreferences.getInstance();

  // 현재 상태 초기화
  state = MandalartStateModel.initial();
  _currentMandalartId = null;
  _currentMandalartCreatedAt = null;

  // 저장소 초기화
  await prefs.remove(_keyCurrentMandalartId);
  await prefs.remove(_keyCurrentMandalartCreatedAt);
  await _persist();
}
```

##### 4-4. SavedMandalartsScreen 생성 (`lib/screens/saved_mandalarts_screen.dart`)

저장된 만다라트 목록을 표시하는 화면:

**주요 기능:**
- 저장된 만다라트 카드 리스트 표시
- 각 카드에 제목, 목표, 진행률, 완료 개수, 날짜 표시
- 카드 탭 시 해당 만다라트 로드
- 빨간 X 버튼으로 삭제
- 뒤로가기 버튼 (chevron_left)

**카드 UI:**
```dart
Widget _buildMandalartCard(SavedMandalartMeta meta) {
  final progressPercent = meta.totalCount > 0
      ? (meta.completedCount / meta.totalCount * 100).toInt()
      : 0;

  return GestureDetector(
    onTap: () => _loadMandalart(meta.id),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [/*...*/],
      ),
      child: Column(
        children: [
          // 제목과 삭제 버튼
          Row(
            children: [
              Expanded(child: Text(meta.displayName)),
              CupertinoButton(
                onPressed: () => _showDeleteDialog(meta),
                child: Container(
                  // 빨간 X 원형 버튼
                ),
              ),
            ],
          ),
          // 목표 텍스트
          if (meta.goalText.trim().isNotEmpty) Text(meta.goalText),
          // 진행률 바
          Container(
            child: FractionallySizedBox(
              widthFactor: meta.completedCount / meta.totalCount,
              child: Container(color: CupertinoColors.systemPurple),
            ),
          ),
          // 완료 개수와 날짜
          Row(
            children: [
              Text('${meta.completedCount}/${meta.totalCount} 완료'),
              Text(_formatDate(meta.updatedAt)),
            ],
          ),
        ],
      ),
    ),
  );
}
```

##### 4-5. GoalStep에 버튼 추가 (`lib/widgets/steps/goal_step.dart`)

"이전의 만다라트 보기" 버튼 추가:
```dart
GestureDetector(
  onTap: () {
    HapticFeedback.lightImpact();
    context.push('/saved-mandalarts');
  },
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CupertinoColors.systemGrey6,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(CupertinoIcons.folder),
        SizedBox(width: 8),
        Text('이전의 만다라트 보기'),
      ],
    ),
  ),
)
```

##### 4-6. MandalartViewer에 저장 버튼 추가 (`lib/widgets/mandalart_viewer.dart`)

네비게이션 바에 플로피 디스크 버튼 추가:
```dart
Semantics(
  label: 'Save mandalart',
  button: true,
  child: CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: () {
      HapticFeedback.lightImpact();
      _saveMandalart();
    },
    child: const Icon(CupertinoIcons.floppy_disk),
  ),
),

Future<void> _saveMandalart() async {
  try {
    await ref.read(mandalartProvider.notifier).saveCurrentMandalart();
    if (mounted) {
      HapticFeedback.mediumImpact();
      _showCupertinoAlert('만다라트가 저장되었습니다.');
    }
  } catch (error) {
    if (mounted) {
      _showCupertinoAlert('저장 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }
}
```

##### 4-7. 라우팅 추가 (`lib/main.dart`)

```dart
final _router = GoRouter(
  initialLocation: '/create',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
    GoRoute(path: '/create', builder: (context, state) => const MandalartAppScreen()),
    GoRoute(path: '/saved-mandalarts', builder: (context, state) => const SavedMandalartsScreen()),
  ],
);
```

### 후속 수정사항

#### SavedMandalartsScreen UI 개선

**문제:**
1. TextStyle interpolation 에러
2. 뒤로가기 버튼이 보이지 않음
3. 삭제 버튼 아이콘이 일관성 없음 (휴지통 vs X)

**해결:**

1. **TextStyle 수정** (Line 215-218):
```dart
// 변경 전 (const 사용)
style: const TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: CupertinoColors.systemPurple,
)

// 변경 후 (.resolveFrom 사용)
style: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: CupertinoColors.systemPurple.resolveFrom(context),
)
```

2. **네비게이션 바 수정** (Lines 42-48):
```dart
// 변경 전 (trailing에 X 버튼)
trailing: CupertinoButton(
  padding: EdgeInsets.zero,
  onPressed: () => context.pop(),
  child: const Icon(CupertinoIcons.xmark_circle),
)

// 변경 후 (leading에 chevron_left)
leading: CupertinoButton(
  padding: EdgeInsets.zero,
  onPressed: () {
    HapticFeedback.lightImpact();
    context.pop();
  },
  child: const Icon(CupertinoIcons.chevron_left),
),
```

3. **삭제 버튼 아이콘 통일** (Lines 168-181):
```dart
// 변경 전
child: const Icon(CupertinoIcons.trash, size: 16)

// 변경 후 (작은 빨간 X 원형)
child: Container(
  width: 20,
  height: 20,
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
    color: CupertinoColors.destructiveRed,
  ),
  alignment: Alignment.center,
  child: const Icon(
    CupertinoIcons.xmark,
    size: 12,
    color: CupertinoColors.white,
  ),
),
```

4. **네비게이션 에러 수정** (Lines 277-278):
```dart
// 변경 전 (에러 발생)
context.pop(); // 로딩 다이얼로그 닫기
context.go('/create'); // 네비게이션 스택 교체 → 뒤로가기 불가

// 변경 후
context.pop(); // 로딩 다이얼로그 닫기
context.pop(); // 저장된 만다라트 화면 닫기 → 이전 화면으로
```

### 테스트 결과
- **Flutter analyze**: No issues found!
- **iOS 빌드**: 성공
- **다크모드**: 모든 화면에서 정상 작동
- **가로모드**: 텍스트 정상 표시
- **만다라트 저장**: 여러 개 저장 및 불러오기 정상 작동
- **삭제 기능**: 정상 작동
- **UI 일관성**: 모든 화면에서 통일된 디자인

### 사용자 흐름

1. **만다라트 작성**: Page 0 → Page 1 → Page 2
2. **저장**: 뷰어에서 플로피 디스크 버튼 탭
3. **불러오기**: Page 0에서 "이전의 만다라트 보기" → 카드 탭
4. **삭제**: 카드의 빨간 X 버튼 탭
5. **새 만다라트**: 첫 페이지에서 새로 작성

---

## 2025-10-17 - 사용자 경험 개선 및 흐름 재구성

### 문제 상황

사용자 피드백:
1. **여러 개 저장 불가**: 저장 버튼을 눌러도 하나의 만다라트만 저장되고 덮어쓰기됨
2. **추천 액션 자동 입력**: 사용자가 클릭만으로 쉽게 채울 수 있어 고민 없이 목표를 설정하게 됨
3. **커뮤니티 목표 자동 입력**: 다른 사람들의 목표를 클릭으로 채울 수 있어 자기 고민이 부족함
4. **혼란스러운 "새 만다라트 시작" 버튼**: 목표를 입력하면 나타나서 사용자가 혼란스러움
5. **중복된 뒤로가기 버튼**: 랜딩 페이지 모달에 뒤로가기 버튼이 2개 있음
6. **불명확한 사용자 흐름**: 저장 후 다음 행동이 명확하지 않음

### 해결 방법

#### 1. 여러 만다라트 저장 문제 수정

**문제 원인** (`lib/providers/mandalart_provider.dart:178`):
```dart
// 문제: _currentMandalartId가 있으면 같은 ID 재사용 → 덮어쓰기
final id = _currentMandalartId ?? const Uuid().v4();
```

**해결책**:
```dart
// 항상 새로운 ID 생성
final id = const Uuid().v4();
final createdAt = DateTime.now();
```

**효과**: 매번 저장할 때마다 새로운 만다라트로 저장됨

#### 2. 추천 액션 클릭 동작 제거 (`lib/widgets/steps/actions_step.dart`)

**변경 전**: 클릭 가능한 버튼들
```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: themeKeywords.map((keyword) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: CupertinoColors.systemGrey5.resolveFrom(context),
      onPressed: () {
        HapticFeedback.selectionClick();
        final targetKey = _focusedKey != null && _focusedKey!.startsWith(themeKeyPrefix)
            ? _focusedKey
            : '${themeKeyPrefix}_0';
        final controller = _controllers[targetKey];
        if (controller != null) {
          controller.text = keyword;
        }
      },
      child: Text(keyword),
    );
  }).toList(),
),
```

**변경 후**: 중간점으로 구분된 텍스트만 표시
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        Icon(
          CupertinoIcons.lightbulb,
          size: 16,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
        const SizedBox(width: 8),
        Text(
          '액션 아이디어',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ],
    ),
    const SizedBox(height: 8),
    Text(
      themeKeywords.join(' · '),
      style: TextStyle(
        fontSize: 14,
        color: CupertinoColors.tertiaryLabel.resolveFrom(context),
        height: 1.5,
      ),
    ),
  ],
),
```

**효과**:
- 키워드가 영감만 제공
- 사용자가 직접 입력해야 함
- `_focusedKey` 필드 제거 (더 이상 필요 없음)

#### 3. 커뮤니티 목표 클릭 동작 제거 (`lib/widgets/steps/goal_step.dart`)

**변경 전**: 클릭 가능한 버튼들
```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: _randomCommunityGoals.map((goal) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      minimumSize: const Size(44, 44),
      color: CupertinoColors.systemPurple.withOpacity(0.1),
      onPressed: () {
        HapticFeedback.selectionClick();
        _controller.text = goal;
      },
      child: Text(goal),
    );
  }).toList(),
),
```

**변경 후**: 중간점으로 구분된 텍스트
```dart
Text(
  _randomCommunityGoals.join(' · '),
  style: TextStyle(
    fontSize: 14,
    color: CupertinoColors.tertiaryLabel.resolveFrom(context),
    height: 1.5,
  ),
),
```

**효과**: 다른 사람들의 목표를 참고만 하고 직접 작성해야 함

#### 4. 사용자 흐름 재구성

**이전 흐름 (문제)**:
1. 랜딩 페이지 → 이름 입력
2. 목표 입력
3. 목표 입력 시 "새 만다라트 시작" 버튼 나타남 ← 혼란
4. 저장 버튼 클릭 → 알림만 표시 ← 다음 행동 불명확

**새로운 흐름 (개선)**:
1. **랜딩 페이지** → 이름 입력
2. **목표/테마/액션 작성**
3. **저장 버튼 클릭** → 자동으로 **저장된 만다라트 목록 페이지**로 이동
4. **저장된 만다라트 목록 페이지**:
   - 상단에 **"새 만다라트 시작"** 버튼 (눈에 띄는 위치)
   - 저장된 만다라트 목록
   - 기존 만다라트 선택 또는 새로 시작 선택 가능

##### 4-1. GoalStep에서 버튼 제거

```dart
// 변경 전 - onStartNew 파라미터와 "새 만다라트 시작" 버튼
class GoalStep extends StatefulWidget {
  final String value;
  final void Function(String) onChange;
  final VoidCallback? onStartNew; // 제거
  // ...
}

// 변경 후
class GoalStep extends StatefulWidget {
  final String value;
  final void Function(String) onChange;
  // ...
}
```

##### 4-2. MandalartViewer 저장 후 이동 (`lib/widgets/mandalart_viewer.dart`)

```dart
// 변경 전
Future<void> _saveMandalart() async {
  try {
    await ref.read(mandalartProvider.notifier).saveCurrentMandalart();
    if (mounted) {
      HapticFeedback.mediumImpact();
      _showCupertinoAlert('만다라트가 저장되었습니다.');
    }
  } catch (error) {
    // ...
  }
}

// 변경 후
Future<void> _saveMandalart() async {
  try {
    await ref.read(mandalartProvider.notifier).saveCurrentMandalart();
    if (mounted) {
      HapticFeedback.mediumImpact();
      // 저장 후 저장된 만다라트 페이지로 이동
      widget.onClose(); // 먼저 뷰어 닫기
      context.push('/saved-mandalarts');
    }
  } catch (error) {
    // ...
  }
}
```

##### 4-3. SavedMandalartsScreen 상단 버튼 추가 (`lib/screens/saved_mandalarts_screen.dart`)

```dart
Widget _buildMandalartList() {
  return CustomScrollView(
    slivers: [
      const SliverPadding(padding: EdgeInsets.only(top: 16)),
      // 새 만다라트 시작 버튼
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              showCupertinoModalPopup(
                context: context,
                builder: (dialogContext) => LandingScreen(
                  isModal: true,
                  onComplete: () async {
                    await ref.read(mandalartProvider.notifier).startNewMandalart();
                    if (mounted && context.mounted) {
                      context.pop(); // 저장된 만다라트 화면 닫기
                    }
                  },
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemPurple.withOpacity(0.15),
                    CupertinoColors.systemIndigo.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.systemPurple.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: CupertinoColors.systemPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.add,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '새 만다라트 시작',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // 저장된 만다라트 목록
      SliverList(/* ... */),
    ],
  );
}
```

**버튼 디자인**:
- 보라색 그라데이션 배경
- 원형 보라색 아이콘 (+)
- 두꺼운 보더
- 눈에 잘 띄는 위치

##### 4-4. 랜딩 페이지 모달 뒤로가기 버튼 제거 (`lib/screens/landing_screen.dart`)

```dart
// 변경 전
navigationBar: CupertinoNavigationBar(
  middle: Text(title),
  backgroundColor: CupertinoColors.systemBackground,
  border: null,
  leading: widget.isModal
      ? CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: const Icon(CupertinoIcons.xmark_circle),
        )
      : null,
  trailing: _buildThemeToggleButton(),
),

// 변경 후
navigationBar: CupertinoNavigationBar(
  middle: Text(title),
  backgroundColor: CupertinoColors.systemBackground,
  border: null,
  leading: widget.isModal ? const SizedBox.shrink() : null,
  trailing: _buildThemeToggleButton(),
),
```

**효과**:
- 상단 X 버튼 제거
- 사용자는 "확인" 버튼을 눌러야 모달 닫힘
- iOS 제스처(아래로 스와이프)로도 닫을 수 있음

### 파일 변경 요약

1. **lib/providers/mandalart_provider.dart** (Line 178)
   - 항상 새로운 UUID 생성

2. **lib/widgets/steps/actions_step.dart** (Lines 19, 65-67, 441-471)
   - `_focusedKey` 필드 제거
   - 추천 액션 버튼을 텍스트로 변경
   - "추천 액션" → "액션 아이디어"로 변경
   - 전구 아이콘 추가

3. **lib/widgets/steps/goal_step.dart** (Lines 8-18, 161-162)
   - `onStartNew` 파라미터 제거
   - "새 만다라트 시작" 버튼 및 관련 코드 제거
   - import 정리

4. **lib/screens/mandalart_app.dart** (Lines 241-244)
   - GoalStep에서 `onStartNew` 콜백 제거

5. **lib/widgets/mandalart_viewer.dart** (Lines 7, 826-840)
   - go_router import 추가
   - 저장 후 저장된 만다라트 페이지로 이동

6. **lib/screens/saved_mandalarts_screen.dart** (Lines 8, 103-168)
   - landing_screen import 추가
   - "새 만다라트 시작" 버튼을 리스트 최상단에 추가
   - 보라색 그라데이션 디자인

7. **lib/screens/landing_screen.dart** (Lines 11-12, 53, 203-207)
   - `onComplete` 콜백 파라미터 추가
   - 모달 모드일 때 leading 버튼 제거

### 사용자 경험 개선 효과

1. **명확한 흐름**:
   - 저장 → 목록 확인 → 새로 시작 또는 기존 불러오기
   - 각 단계의 목적이 명확함

2. **혼란 제거**:
   - 목표 입력 중에 "새 만다라트 시작" 버튼이 나타나지 않음
   - 저장 후 자동으로 다음 단계로 이동

3. **중앙 집중식 관리**:
   - 모든 만다라트 관리가 한 페이지에서 이루어짐
   - 저장된 목록과 새로 시작하기가 같은 화면에 있음

4. **더 많은 고민 유도**:
   - 추천 액션과 커뮤니티 목표를 클릭으로 채울 수 없음
   - 영감만 제공하고 직접 작성해야 함
   - 더 의미있는 목표 설정 가능

5. **여러 만다라트 관리**:
   - 무제한으로 만다라트 저장 가능
   - 각각 독립적으로 관리
   - 진행률 추적

### 테스트 결과

- **Flutter analyze**: No issues found!
- **여러 개 저장**: 정상 작동
- **저장 후 이동**: 저장된 만다라트 페이지로 자동 이동
- **새 만다라트 시작**: 버튼 클릭 시 랜딩 페이지 모달 표시 후 초기화
- **추천 액션**: 클릭 불가, 텍스트로만 표시
- **커뮤니티 목표**: 클릭 불가, 텍스트로만 표시
- **모달 뒤로가기**: X 버튼 제거, 확인 버튼 또는 제스처로만 닫기

### 새로운 사용자 흐름

1. **첫 사용**:
   - 랜딩 페이지 → 이름 입력 → 목표 입력 → 테마 입력 → 액션 입력 → 저장

2. **저장 후**:
   - 자동으로 저장된 만다라트 목록 페이지로 이동
   - 저장된 만다라트 확인

3. **다음 작업 선택**:
   - **기존 만다라트 선택**: 카드 탭 → 불러와서 계속 작업
   - **새 만다라트 시작**: 상단 버튼 탭 → 랜딩 페이지 → 이름 입력 → 새로 시작

4. **작업 중**:
   - 목표/테마/액션 수정
   - 액션 완료 체크
   - 뷰어에서 진행상황 확인

5. **재저장**:
   - 뷰어에서 저장 버튼 → 다시 목록 페이지로 이동 → 새로운 항목으로 저장됨

---

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:mandarart_journey/models/mandalart.dart';

class MandalartNotifier extends StateNotifier<MandalartStateModel> {
  MandalartNotifier() : super(MandalartStateModel.initial()) {
    _load();
  }

  static const _keyGoal = 'mandalart-goal';
  static const _keyThemes = 'mandalart-themes';
  static const _keyActions = 'mandalart-actions';
  static const _keyStep = 'mandalart-current-step';
  static const _keyDisplayName = 'mandalart-display-name';
  static const _keySavedMandalartIds = 'saved-mandalart-ids';
  static const _keyCurrentMandalartId = 'current-mandalart-id';
  static const _keyCurrentMandalartCreatedAt = 'current-mandalart-created-at';
  static const _keyCalendarLog = 'mandalart-calendar-log';

  String? _currentMandalartId;
  DateTime? _currentMandalartCreatedAt;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // 현재 만다라트 ID와 생성일 로드
    _currentMandalartId = prefs.getString(_keyCurrentMandalartId);
    final createdAtStr = prefs.getString(_keyCurrentMandalartCreatedAt);
    if (createdAtStr != null) {
      _currentMandalartCreatedAt = DateTime.tryParse(createdAtStr);
    }

    final goal = prefs.getString(_keyGoal) ?? '';

    // Load themes: Try object list first, then string list (legacy)
    List<ThemeModel> themes;
    final themesObjsJson = prefs.getString('mandalart-theme-objects');
    if (themesObjsJson != null) {
      try {
        final list = jsonDecode(themesObjsJson) as List;
        themes = list.map((item) {
          final m = item as Map<String, dynamic>;
          return ThemeModel(
            id: m['id'] as String? ?? 'id',
            goalId: m['goalId'] as String? ?? 'gid',
            themeText: m['themeText'] as String? ?? '',
            order: m['order'] as int? ?? 0,
            priority: m.containsKey('priority')
                ? GoalPriority.fromJson(m['priority'] as String)
                : GoalPriority.none,
            createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
                DateTime.now(),
            updatedAt: DateTime.tryParse(m['updatedAt'] as String? ?? '') ??
                DateTime.now(),
          );
        }).toList();
      } catch (e) {
        themes = List.generate(
            8,
            (i) => ThemeModel(
                id: 'err_$i',
                goalId: 'err',
                themeText: '',
                order: i,
                priority: GoalPriority.none,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()));
      }
    } else {
      // Legacy fallback
      final themeTexts = prefs.getStringList(_keyThemes) ?? List.filled(8, '');
      themes = List.generate(8, (i) {
        final text = i < themeTexts.length ? themeTexts[i] : '';
        return ThemeModel(
          id: 'legacy_$i',
          goalId: 'legacy_goal',
          themeText: text,
          order: i,
          priority: GoalPriority.none,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    }

    final actionsRaw = prefs.getString(_keyActions);
    final step = prefs.getInt(_keyStep) ?? 0;
    final displayName = prefs.getString(_keyDisplayName) ?? '';
    final calendarLogRaw = prefs.getString(_keyCalendarLog);
    Map<String, int> calendarLog = {};
    if (calendarLogRaw != null) {
      try {
        calendarLog = Map<String, int>.from(jsonDecode(calendarLogRaw));
      } catch (e) {
        // ignore
      }
    }

    final actions = <ActionItemModel>[];
    if (actionsRaw != null) {
      for (final m in (jsonDecode(actionsRaw) as List<dynamic>)) {
        // 하위 호환성: 'isCompleted'가 있으면 status로 변환
        ActionStatus status;
        if (m.containsKey('status')) {
          status = ActionStatus.fromJson(m['status'] as String);
        } else if (m.containsKey('isCompleted')) {
          status = (m['isCompleted'] as bool)
              ? ActionStatus.completed
              : ActionStatus.notStarted;
        } else {
          status = ActionStatus.notStarted;
        }

        actions.add(ActionItemModel(
          id: m['id'] as String,
          themeId: m['themeId'] as String,
          actionText: m['actionText'] as String,
          status: status,
          order: m['order'] as int,
          createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
              DateTime.now(),
          updatedAt: DateTime.tryParse(m['updatedAt'] as String? ?? '') ??
              DateTime.now(),
        ));
      }
    }

    state = state.copyWith(
      displayName: displayName,
      goalText: goal,
      themes: themes,
      actionItems: actions,
      currentStep: step,
      calendarLog: calendarLog,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDisplayName, state.displayName);
    await prefs.setString(_keyGoal, state.goalText);

    // Save objects as JSON String list is not enough anymore,
    // but we can keep _keyThemes as simple string list for backward compatibility if needed,
    // or just rely entirely on the full JSON serialization in saveCurrentMandalart.
    // However, _load() checks _keyThemes string list.
    // Let's safe the full state to a new key or rely on persisting individual fields?
    // The current pattern mixes individual keys and full JSON.
    // Let's update _keyThemes to store just text for backward compat,
    // BUT we must rely on a new key for full theme objects if we want to persist priority between app restarts logic
    // without "saving" to saved_mandalarts.

    // Actually, _load() reconstructs state from individual keys.
    // We should probably serialize the themes to JSON string and store in a new key,
    // or just update how we store "themes".
    // For now, let's keep backward compat by storing texts in _keyThemes
    // AND store the full theme objects in a new key `mandalart-theme-objects`

    await prefs.setStringList(
        _keyThemes, state.themes.map((t) => t.themeText).toList());
    await prefs.setString(
        'mandalart-theme-objects',
        jsonEncode(state.themes
            .map((t) => {
                  'id': t.id,
                  'goalId': t.goalId,
                  'themeText': t.themeText,
                  'order': t.order,
                  'priority': t.priority.toJson(),
                  'createdAt': t.createdAt.toIso8601String(),
                  'updatedAt': t.updatedAt.toIso8601String(),
                })
            .toList()));

    await prefs.setInt(_keyStep, state.currentStep);
    await prefs.setString(
      _keyActions,
      jsonEncode(state.actionItems
          .map((a) => {
                'id': a.id,
                'themeId': a.themeId,
                'actionText': a.actionText,
                'status': a.status.toJson(),
                'order': a.order,
                'createdAt': a.createdAt.toIso8601String(),
                'updatedAt': a.updatedAt.toIso8601String(),
              })
          .toList()),
    );
    await prefs.setString(_keyCalendarLog, jsonEncode(state.calendarLog));
  }

  void updateDisplayName(String value) {
    state = state.copyWith(displayName: value);
    _persist();
  }

  void updateGoal(String value) {
    state = state.copyWith(goalText: value);
    _persist();
  }

  void updateThemes(List<String> value) {
    // Value is list of texts
    final newThemes = List<ThemeModel>.generate(8, (i) {
      final text = i < value.length ? value[i] : '';
      final existing = state.themes[i];
      return ThemeModel(
        id: existing.id,
        goalId: existing.goalId,
        themeText: text,
        order: existing.order,
        priority: existing.priority,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
    });
    state = state.copyWith(themes: newThemes);
    _persist();
  }

  void updateThemePriority(int index, GoalPriority priority) {
    final newThemes = List<ThemeModel>.from(state.themes);
    final existing = newThemes[index];
    newThemes[index] = ThemeModel(
        id: existing.id,
        goalId: existing.goalId,
        themeText: existing.themeText,
        order: existing.order,
        priority: priority,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now());
    state = state.copyWith(themes: newThemes);
    _persist();
  }

  void updateActionItem(
      {required int themeIndex,
      required int actionIndex,
      String? text,
      ActionStatus? status}) {
    final themeId = 'theme-$themeIndex';
    final List<ActionItemModel> updated =
        List<ActionItemModel>.from(state.actionItems);
    final idx = updated
        .indexWhere((a) => a.themeId == themeId && a.order == actionIndex);
    if (idx >= 0) {
      updated[idx] = updated[idx].copyWith(
        actionText: text ?? updated[idx].actionText,
        status: status ?? updated[idx].status,
      );
    } else {
      updated.add(ActionItemModel(
        id: const Uuid().v4(),
        themeId: themeId,
        actionText: text ?? '',
        status: status ?? ActionStatus.notStarted,
        order: actionIndex,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    state = state.copyWith(actionItems: updated);
    _persist();
  }

  // 액션 아이템 상태 토글 (notStarted -> inProgress -> completed -> notStarted)
  // Returns the new status for haptic feedback purposes
  ActionStatus? toggleActionStatus(
      {required int themeIndex, required int actionIndex}) {
    final themeId = 'theme-$themeIndex';
    final List<ActionItemModel> updated =
        List<ActionItemModel>.from(state.actionItems);
    final idx = updated
        .indexWhere((a) => a.themeId == themeId && a.order == actionIndex);

    if (idx >= 0) {
      final currentStatus = updated[idx].status;
      ActionStatus newStatus;

      switch (currentStatus) {
        case ActionStatus.notStarted:
          newStatus = ActionStatus.inProgress;
          break;
        case ActionStatus.inProgress:
          newStatus = ActionStatus.completed;
          break;
        case ActionStatus.completed:
          newStatus = ActionStatus.notStarted;
          break;
      }

      DateTime? startedAt = updated[idx].startedAt;
      DateTime? completedAt = updated[idx].completedAt;

      switch (newStatus) {
        case ActionStatus.inProgress:
          startedAt = DateTime.now();
          // completedAt remains null
          break;
        case ActionStatus.completed:
          // Keep startedAt if it exists, otherwise set it (if jumped straight to complete?)
          // Logic says inProgress -> completed, so startedAt should exist.
          startedAt ??= DateTime.now();
          completedAt = DateTime.now();
          break;
        case ActionStatus.notStarted:
          startedAt = null;
          completedAt = null;
          break;
      }

      updated[idx] = updated[idx].copyWith(
        status: newStatus,
        startedAt: startedAt,
        completedAt: completedAt,
      );
      state = state.copyWith(actionItems: updated);
      _persist();
      return newStatus;
    }
    return null;
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
    _persist();
  }

  void nextStep() => setStep((state.currentStep + 1).clamp(0, 2));
  void previousStep() => setStep((state.currentStep - 1).clamp(0, 2));

  void openViewer() => state = state.copyWith(showViewer: true);
  void closeViewer() => state = state.copyWith(showViewer: false);

  void initialize(String title, String goal) {
    state = MandalartStateModel.initial().copyWith(
      displayName: title,
      goalText: goal,
    );
    _persist();
  }

  // 목표 초기화
  void clearGoal() {
    state = state.copyWith(goalText: '');
    _persist();
  }

  // 특정 테마 초기화
  void clearTheme(int themeIndex) {
    final List<ThemeModel> updated = List<ThemeModel>.from(state.themes);
    final existing = updated[themeIndex];
    updated[themeIndex] = ThemeModel(
        id: existing.id,
        goalId: existing.goalId,
        themeText: '',
        order: existing.order,
        priority: GoalPriority.none,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now());
    state = state.copyWith(themes: updated);
    _persist();
  }

  // 모든 테마 초기화
  void clearAllThemes() {
    final newThemes = List<ThemeModel>.generate(8, (i) {
      final existing = state.themes[i];
      return ThemeModel(
        id: existing.id,
        goalId: existing.goalId,
        themeText: '',
        order: existing.order,
        priority: GoalPriority.none,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
    });
    state = state.copyWith(themes: newThemes);
    _persist();
  }

  // 특정 테마의 액션 아이템 모두 초기화
  void clearThemeActions(int themeIndex) {
    final themeId = 'theme-$themeIndex';
    final List<ActionItemModel> updated =
        state.actionItems.where((a) => a.themeId != themeId).toList();
    state = state.copyWith(actionItems: updated);
    _persist();
  }

  // 모든 액션 아이템 초기화
  void clearAllActions() {
    state = state.copyWith(actionItems: []);
    _persist();
  }

  // === 저장된 만다라트 관리 메서드 ===

  /// 현재 만다라트를 저장합니다
  /// 동일한 제목(displayName)이 있으면 덮어쓰기, 없으면 새로 저장
  ///
  /// Returns: (id, isOverwrite) - 저장된 ID와 덮어쓰기 여부
  Future<(String id, bool isOverwrite)> saveCurrentMandalart(
      {bool forceNew = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentDisplayName = state.displayName.trim();

    String id;
    DateTime createdAt;
    bool isOverwrite = false;

    if (!forceNew && currentDisplayName.isNotEmpty) {
      // 동일한 제목을 가진 만다라트 찾기
      final savedIds = prefs.getStringList(_keySavedMandalartIds) ?? [];
      String? existingId;

      for (final savedId in savedIds) {
        final metaJson = prefs.getString('mandalart_meta_$savedId');
        if (metaJson != null) {
          try {
            final meta = SavedMandalartMeta.fromJson(
                jsonDecode(metaJson) as Map<String, dynamic>);
            if (meta.displayName.trim() == currentDisplayName) {
              existingId = savedId;
              break;
            }
          } catch (e) {
            // 파싱 오류 시 무시
          }
        }
      }

      if (existingId != null) {
        // 기존 만다라트 덮어쓰기
        id = existingId;
        isOverwrite = true;

        // 기존 생성일 유지
        final existingMetaJson = prefs.getString('mandalart_meta_$id');
        if (existingMetaJson != null) {
          try {
            final existingMeta = SavedMandalartMeta.fromJson(
                jsonDecode(existingMetaJson) as Map<String, dynamic>);
            createdAt = existingMeta.createdAt;
          } catch (e) {
            createdAt = DateTime.now();
          }
        } else {
          createdAt = DateTime.now();
        }
      } else {
        // 새로운 만다라트 생성
        id = const Uuid().v4();
        createdAt = DateTime.now();
      }
    } else {
      // 제목이 없거나 강제 새로 만들기인 경우
      id = const Uuid().v4();
      createdAt = DateTime.now();
    }

    // 만다라트 데이터 저장
    final mandalartJson = jsonEncode(state.toJson());
    await prefs.setString('mandalart_data_$id', mandalartJson);

    // 메타데이터 생성 및 저장
    final meta = SavedMandalartMeta.fromState(id, state, createdAt);
    await prefs.setString('mandalart_meta_$id', jsonEncode(meta.toJson()));

    // 새로 생성된 경우에만 ID 목록에 추가
    if (!isOverwrite) {
      final savedIds = prefs.getStringList(_keySavedMandalartIds) ?? [];
      savedIds.add(id);
      await prefs.setStringList(_keySavedMandalartIds, savedIds);
    }

    // 현재 만다라트 ID 및 생성일 저장
    _currentMandalartId = id;
    _currentMandalartCreatedAt = createdAt;
    await prefs.setString(_keyCurrentMandalartId, id);
    await prefs.setString(
        _keyCurrentMandalartCreatedAt, createdAt.toIso8601String());

    return (id, isOverwrite);
  }

  /// 동일한 제목의 만다라트가 존재하는지 확인
  Future<bool> hasMandalartWithTitle(String title) async {
    if (title.trim().isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_keySavedMandalartIds) ?? [];

    for (final savedId in savedIds) {
      final metaJson = prefs.getString('mandalart_meta_$savedId');
      if (metaJson != null) {
        try {
          final meta = SavedMandalartMeta.fromJson(
              jsonDecode(metaJson) as Map<String, dynamic>);
          if (meta.displayName.trim() == title.trim()) {
            return true;
          }
        } catch (e) {
          // 파싱 오류 시 무시
        }
      }
    }

    return false;
  }

  /// 저장된 만다라트 목록을 가져옵니다
  Future<List<SavedMandalartMeta>> getSavedMandalarts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_keySavedMandalartIds) ?? [];

    final List<SavedMandalartMeta> metaList = [];
    for (final id in savedIds) {
      final metaJson = prefs.getString('mandalart_meta_$id');
      if (metaJson != null) {
        try {
          final meta = SavedMandalartMeta.fromJson(
              jsonDecode(metaJson) as Map<String, dynamic>);
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

  /// 특정 만다라트를 불러옵니다
  Future<void> loadMandalart(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getString('mandalart_data_$id');

    if (dataJson != null) {
      try {
        final data = MandalartStateModel.fromJson(
            jsonDecode(dataJson) as Map<String, dynamic>);

        // 메타데이터에서 생성일 가져오기
        final metaJson = prefs.getString('mandalart_meta_$id');
        DateTime? createdAt;
        if (metaJson != null) {
          try {
            final meta = SavedMandalartMeta.fromJson(
                jsonDecode(metaJson) as Map<String, dynamic>);
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
        await prefs.setString(_keyCurrentMandalartCreatedAt,
            (_currentMandalartCreatedAt ?? DateTime.now()).toIso8601String());

        // 기본 저장소에도 저장 (호환성)
        await _persist();
      } catch (e) {
        // 파싱 오류 시 무시
      }
    }
  }

  /// 저장된 만다라트를 삭제합니다
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

  /// 새 만다라트를 시작합니다
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

  /// JSON 데이터를 불러와서 현재 상태로 설정합니다
  Future<bool> importFromState(MandalartStateModel importedState) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 상태 업데이트
      state = importedState;

      // 새로운 ID 생성 (불러온 데이터는 새 만다라트로 취급)
      _currentMandalartId = null;
      _currentMandalartCreatedAt = null;

      // 저장소 초기화
      await prefs.remove(_keyCurrentMandalartId);
      await prefs.remove(_keyCurrentMandalartCreatedAt);

      // 새로운 데이터 저장
      await _persist();

      return true;
    } catch (e) {
      return false;
    }
  }
}

final mandalartProvider =
    StateNotifierProvider<MandalartNotifier, MandalartStateModel>((ref) {
  return MandalartNotifier();
});

final activeThemeIndexProvider = StateProvider<int?>((ref) => null);

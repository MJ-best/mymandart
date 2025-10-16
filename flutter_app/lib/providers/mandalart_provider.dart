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
    final themes = prefs.getStringList(_keyThemes) ?? List.filled(8, '');
    final actionsRaw = prefs.getString(_keyActions);
    final step = prefs.getInt(_keyStep) ?? 0;
    final displayName = prefs.getString(_keyDisplayName) ?? '';

    final actions = <ActionItemModel>[];
    if (actionsRaw != null) {
      for (final m in (jsonDecode(actionsRaw) as List<dynamic>)) {
        actions.add(ActionItemModel(
          id: m['id'] as String,
          themeId: m['themeId'] as String,
          actionText: m['actionText'] as String,
          isCompleted: m['isCompleted'] as bool,
          order: m['order'] as int,
          createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(m['updatedAt'] as String? ?? '') ?? DateTime.now(),
        ));
      }
    }

    state = state.copyWith(
      displayName: displayName,
      goalText: goal,
      themes: themes,
      actionItems: actions,
      currentStep: step,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDisplayName, state.displayName);
    await prefs.setString(_keyGoal, state.goalText);
    await prefs.setStringList(_keyThemes, state.themes);
    await prefs.setInt(_keyStep, state.currentStep);
    await prefs.setString(
      _keyActions,
      jsonEncode(state.actionItems
          .map((a) => {
                'id': a.id,
                'themeId': a.themeId,
                'actionText': a.actionText,
                'isCompleted': a.isCompleted,
                'order': a.order,
                'createdAt': a.createdAt.toIso8601String(),
                'updatedAt': a.updatedAt.toIso8601String(),
              })
          .toList()),
    );
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
    state = state.copyWith(themes: value);
    _persist();
  }

  void updateActionItem({required int themeIndex, required int actionIndex, String? text, bool? completed}) {
    final themeId = 'theme-$themeIndex';
    final List<ActionItemModel> updated = List<ActionItemModel>.from(state.actionItems);
    final idx = updated.indexWhere((a) => a.themeId == themeId && a.order == actionIndex);
    if (idx >= 0) {
      updated[idx] = updated[idx].copyWith(
        actionText: text ?? updated[idx].actionText,
        isCompleted: completed ?? updated[idx].isCompleted,
      );
    } else {
      updated.add(ActionItemModel(
        id: const Uuid().v4(),
        themeId: themeId,
        actionText: text ?? '',
        isCompleted: completed ?? false,
        order: actionIndex,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    state = state.copyWith(actionItems: updated);
    _persist();
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
    _persist();
  }

  void nextStep() => setStep((state.currentStep + 1).clamp(0, 2));
  void previousStep() => setStep((state.currentStep - 1).clamp(0, 2));

  void openViewer() => state = state.copyWith(showViewer: true);
  void closeViewer() => state = state.copyWith(showViewer: false);

  // 목표 초기화
  void clearGoal() {
    state = state.copyWith(goalText: '');
    _persist();
  }

  // 특정 테마 초기화
  void clearTheme(int themeIndex) {
    final List<String> updated = List<String>.from(state.themes);
    updated[themeIndex] = '';
    state = state.copyWith(themes: updated);
    _persist();
  }

  // 모든 테마 초기화
  void clearAllThemes() {
    state = state.copyWith(themes: List.filled(8, ''));
    _persist();
  }

  // 특정 테마의 액션 아이템 모두 초기화
  void clearThemeActions(int themeIndex) {
    final themeId = 'theme-$themeIndex';
    final List<ActionItemModel> updated = state.actionItems.where((a) => a.themeId != themeId).toList();
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
  Future<String> saveCurrentMandalart() async {
    final prefs = await SharedPreferences.getInstance();

    // ID가 없으면 새로 생성, 있으면 기존 ID 사용
    final id = _currentMandalartId ?? const Uuid().v4();
    final createdAt = _currentMandalartCreatedAt ?? DateTime.now();

    // 만다라트 데이터 저장
    final mandalartJson = jsonEncode(state.toJson());
    await prefs.setString('mandalart_data_$id', mandalartJson);

    // 메타데이터 생성 및 저장
    final meta = SavedMandalartMeta.fromState(id, state, createdAt);
    await prefs.setString('mandalart_meta_$id', jsonEncode(meta.toJson()));

    // 저장된 만다라트 ID 목록 업데이트
    final savedIds = prefs.getStringList(_keySavedMandalartIds) ?? [];
    if (!savedIds.contains(id)) {
      savedIds.add(id);
      await prefs.setStringList(_keySavedMandalartIds, savedIds);
    }

    // 현재 만다라트 ID 및 생성일 저장
    _currentMandalartId = id;
    _currentMandalartCreatedAt = createdAt;
    await prefs.setString(_keyCurrentMandalartId, id);
    await prefs.setString(_keyCurrentMandalartCreatedAt, createdAt.toIso8601String());

    return id;
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

  /// 특정 만다라트를 불러옵니다
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
}

final mandalartProvider = StateNotifierProvider<MandalartNotifier, MandalartStateModel>((ref) {
  return MandalartNotifier();
});

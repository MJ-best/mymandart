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

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
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
}

final mandalartProvider = StateNotifierProvider<MandalartNotifier, MandalartStateModel>((ref) {
  return MandalartNotifier();
});

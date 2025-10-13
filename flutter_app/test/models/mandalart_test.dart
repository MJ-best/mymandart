import 'package:flutter_test/flutter_test.dart';
import 'package:mandarart_journey/models/mandalart.dart';

void main() {
  group('ActionItemModel', () {
    test('creates ActionItemModel with required fields', () {
      final now = DateTime.now();
      final actionItem = ActionItemModel(
        id: 'test-id',
        themeId: 'theme-1',
        actionText: 'Test action',
        isCompleted: false,
        order: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(actionItem.id, 'test-id');
      expect(actionItem.themeId, 'theme-1');
      expect(actionItem.actionText, 'Test action');
      expect(actionItem.isCompleted, false);
      expect(actionItem.order, 0);
      expect(actionItem.createdAt, now);
      expect(actionItem.updatedAt, now);
    });

    test('copyWith updates actionText', () {
      final now = DateTime.now();
      final original = ActionItemModel(
        id: 'test-id',
        themeId: 'theme-1',
        actionText: 'Original text',
        isCompleted: false,
        order: 0,
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(actionText: 'Updated text');

      expect(updated.id, original.id);
      expect(updated.themeId, original.themeId);
      expect(updated.actionText, 'Updated text');
      expect(updated.isCompleted, original.isCompleted);
      expect(updated.order, original.order);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt.isAfter(original.updatedAt), true);
    });

    test('copyWith updates isCompleted', () {
      final now = DateTime.now();
      final original = ActionItemModel(
        id: 'test-id',
        themeId: 'theme-1',
        actionText: 'Test action',
        isCompleted: false,
        order: 0,
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(isCompleted: true);

      expect(updated.isCompleted, true);
      expect(updated.actionText, original.actionText);
    });

    test('copyWith updates both fields', () {
      final now = DateTime.now();
      final original = ActionItemModel(
        id: 'test-id',
        themeId: 'theme-1',
        actionText: 'Original text',
        isCompleted: false,
        order: 0,
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        actionText: 'Updated text',
        isCompleted: true,
      );

      expect(updated.actionText, 'Updated text');
      expect(updated.isCompleted, true);
    });
  });

  group('MandalartStateModel', () {
    test('creates initial state with factory', () {
      final state = MandalartStateModel.initial();

      expect(state.displayName, '');
      expect(state.goalText, '');
      expect(state.themes.length, 8);
      expect(state.themes.every((t) => t == ''), true);
      expect(state.actionItems, isEmpty);
      expect(state.currentStep, 0);
      expect(state.showViewer, false);
    });

    test('copyWith updates displayName', () {
      final original = MandalartStateModel.initial();
      final updated = original.copyWith(displayName: 'My Journey');

      expect(updated.displayName, 'My Journey');
      expect(updated.goalText, original.goalText);
      expect(updated.themes, original.themes);
    });

    test('copyWith updates goalText', () {
      final original = MandalartStateModel.initial();
      final updated = original.copyWith(goalText: 'Become a better developer');

      expect(updated.goalText, 'Become a better developer');
      expect(updated.displayName, original.displayName);
    });

    test('copyWith updates themes', () {
      final original = MandalartStateModel.initial();
      final newThemes = ['Theme 1', 'Theme 2', '', '', '', '', '', ''];
      final updated = original.copyWith(themes: newThemes);

      expect(updated.themes, newThemes);
      expect(updated.themes[0], 'Theme 1');
      expect(updated.themes[1], 'Theme 2');
    });

    test('copyWith updates actionItems', () {
      final original = MandalartStateModel.initial();
      final now = DateTime.now();
      final actionItems = [
        ActionItemModel(
          id: '1',
          themeId: 'theme-0',
          actionText: 'Action 1',
          isCompleted: false,
          order: 0,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final updated = original.copyWith(actionItems: actionItems);

      expect(updated.actionItems.length, 1);
      expect(updated.actionItems[0].actionText, 'Action 1');
    });

    test('copyWith updates currentStep', () {
      final original = MandalartStateModel.initial();
      final updated = original.copyWith(currentStep: 2);

      expect(updated.currentStep, 2);
      expect(original.currentStep, 0);
    });

    test('copyWith updates showViewer', () {
      final original = MandalartStateModel.initial();
      final updated = original.copyWith(showViewer: true);

      expect(updated.showViewer, true);
      expect(original.showViewer, false);
    });

    test('copyWith preserves unchanged fields', () {
      final now = DateTime.now();
      final actionItems = [
        ActionItemModel(
          id: '1',
          themeId: 'theme-0',
          actionText: 'Action 1',
          isCompleted: false,
          order: 0,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final original = MandalartStateModel(
        displayName: 'Test',
        goalText: 'Goal',
        themes: ['Theme 1', '', '', '', '', '', '', ''],
        actionItems: actionItems,
        currentStep: 1,
        showViewer: false,
      );

      final updated = original.copyWith(currentStep: 2);

      expect(updated.displayName, original.displayName);
      expect(updated.goalText, original.goalText);
      expect(updated.themes, original.themes);
      expect(updated.actionItems, original.actionItems);
      expect(updated.showViewer, original.showViewer);
      expect(updated.currentStep, 2);
    });
  });

  group('GoalModel', () {
    test('creates GoalModel with required fields', () {
      final now = DateTime.now();
      final goal = GoalModel(
        id: 'goal-1',
        centralGoal: 'Become a better developer',
        createdAt: now,
        updatedAt: now,
      );

      expect(goal.id, 'goal-1');
      expect(goal.centralGoal, 'Become a better developer');
      expect(goal.createdAt, now);
      expect(goal.updatedAt, now);
    });
  });

  group('ThemeModel', () {
    test('creates ThemeModel with required fields', () {
      final now = DateTime.now();
      final theme = ThemeModel(
        id: 'theme-1',
        goalId: 'goal-1',
        themeText: 'Study algorithms',
        order: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(theme.id, 'theme-1');
      expect(theme.goalId, 'goal-1');
      expect(theme.themeText, 'Study algorithms');
      expect(theme.order, 0);
      expect(theme.createdAt, now);
      expect(theme.updatedAt, now);
    });

    test('maintains order correctly', () {
      final now = DateTime.now();
      final themes = List.generate(
        8,
        (index) => ThemeModel(
          id: 'theme-$index',
          goalId: 'goal-1',
          themeText: 'Theme $index',
          order: index,
          createdAt: now,
          updatedAt: now,
        ),
      );

      for (var i = 0; i < themes.length; i++) {
        expect(themes[i].order, i);
      }
    });
  });
}

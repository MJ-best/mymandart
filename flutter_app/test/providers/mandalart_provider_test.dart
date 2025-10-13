import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MandalartNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      // Initialize SharedPreferences with mock
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty', () async {
      container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for _load

      final state = container.read(mandalartProvider);
      expect(state.displayName, '');
      expect(state.goalText, '');
      expect(state.themes.length, 8);
      expect(state.themes.every((t) => t == ''), true);
      expect(state.actionItems, isEmpty);
      expect(state.currentStep, 0);
      expect(state.showViewer, false);
    });

    test('updateDisplayName updates state', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.updateDisplayName('My Mandalart');
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.displayName, 'My Mandalart');
    });

    test('updateGoal updates goalText', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.updateGoal('Become a better developer');
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.goalText, 'Become a better developer');
    });

    test('updateThemes updates themes list', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      final newThemes = ['Theme 1', 'Theme 2', '', '', '', '', '', ''];
      notifier.updateThemes(newThemes);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.themes, newThemes);
      expect(state.themes[0], 'Theme 1');
      expect(state.themes[1], 'Theme 2');
    });

    test('updateActionItem creates new action item', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        text: 'Test action',
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.actionItems.length, 1);
      expect(state.actionItems[0].actionText, 'Test action');
      expect(state.actionItems[0].themeId, 'theme-0');
      expect(state.actionItems[0].order, 0);
      expect(state.actionItems[0].isCompleted, false);
    });

    test('updateActionItem updates existing action item text', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      // Create action
      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        text: 'Original text',
      );
      await Future.delayed(const Duration(milliseconds: 50));

      // Update action
      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        text: 'Updated text',
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.actionItems.length, 1);
      expect(state.actionItems[0].actionText, 'Updated text');
    });

    test('updateActionItem updates completion status', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      // Create action
      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        text: 'Test action',
      );
      await Future.delayed(const Duration(milliseconds: 50));

      // Mark as completed
      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        completed: true,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.actionItems[0].isCompleted, true);
    });

    test('setStep updates currentStep', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.setStep(2);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.currentStep, 2);
    });

    test('nextStep increments currentStep', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.nextStep();
      await Future.delayed(const Duration(milliseconds: 50));

      var state = container.read(mandalartProvider);
      expect(state.currentStep, 1);

      notifier.nextStep();
      await Future.delayed(const Duration(milliseconds: 50));

      state = container.read(mandalartProvider);
      expect(state.currentStep, 2);
    });

    test('nextStep clamps at max step', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.setStep(2);
      await Future.delayed(const Duration(milliseconds: 50));

      notifier.nextStep();
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.currentStep, 2);
    });

    test('previousStep decrements currentStep', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.setStep(2);
      await Future.delayed(const Duration(milliseconds: 50));

      notifier.previousStep();
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.currentStep, 1);
    });

    test('previousStep clamps at min step', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.previousStep();
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.currentStep, 0);
    });

    test('openViewer sets showViewer to true', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.openViewer();

      final state = container.read(mandalartProvider);
      expect(state.showViewer, true);
    });

    test('closeViewer sets showViewer to false', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.openViewer();
      notifier.closeViewer();

      final state = container.read(mandalartProvider);
      expect(state.showViewer, false);
    });

    test('clearGoal resets goalText', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.updateGoal('Test Goal');
      await Future.delayed(const Duration(milliseconds: 50));

      notifier.clearGoal();
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.goalText, '');
    });

    test('clearTheme resets specific theme', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      final themes = ['Theme 1', 'Theme 2', 'Theme 3', '', '', '', '', ''];
      notifier.updateThemes(themes);
      await Future.delayed(const Duration(milliseconds: 50));

      notifier.clearTheme(1);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.themes[0], 'Theme 1');
      expect(state.themes[1], '');
      expect(state.themes[2], 'Theme 3');
    });

    test('clearAllThemes resets all themes', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      final themes = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8'];
      notifier.updateThemes(themes);
      await Future.delayed(const Duration(milliseconds: 50));

      notifier.clearAllThemes();
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.themes.every((t) => t == ''), true);
    });

    test('clearThemeActions removes all actions for theme', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      // Add actions to theme 0
      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        text: 'Action 1',
      );
      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 1,
        text: 'Action 2',
      );
      // Add action to theme 1
      notifier.updateActionItem(
        themeIndex: 1,
        actionIndex: 0,
        text: 'Action 3',
      );
      await Future.delayed(const Duration(milliseconds: 50));

      notifier.clearThemeActions(0);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.actionItems.length, 1);
      expect(state.actionItems[0].themeId, 'theme-1');
    });

    test('clearAllActions removes all action items', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        text: 'Action 1',
      );
      notifier.updateActionItem(
        themeIndex: 1,
        actionIndex: 0,
        text: 'Action 2',
      );
      await Future.delayed(const Duration(milliseconds: 50));

      notifier.clearAllActions();
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.actionItems, isEmpty);
    });

    test('multiple action items for different themes', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        text: 'Theme 0 Action 0',
      );
      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 1,
        text: 'Theme 0 Action 1',
      );
      notifier.updateActionItem(
        themeIndex: 1,
        actionIndex: 0,
        text: 'Theme 1 Action 0',
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      expect(state.actionItems.length, 3);

      final theme0Actions =
          state.actionItems.where((a) => a.themeId == 'theme-0').toList();
      final theme1Actions =
          state.actionItems.where((a) => a.themeId == 'theme-1').toList();

      expect(theme0Actions.length, 2);
      expect(theme1Actions.length, 1);
    });

    test('action items maintain order', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      for (int i = 0; i < 8; i++) {
        notifier.updateActionItem(
          themeIndex: 0,
          actionIndex: i,
          text: 'Action $i',
        );
      }
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(mandalartProvider);
      final theme0Actions =
          state.actionItems.where((a) => a.themeId == 'theme-0').toList();

      for (int i = 0; i < theme0Actions.length; i++) {
        expect(theme0Actions[i].order, i);
      }
    });

    test('persistence saves data', () async {
      final notifier = container.read(mandalartProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.updateDisplayName('Test Journey');
      notifier.updateGoal('Test Goal');
      notifier.updateThemes(['Theme 1', '', '', '', '', '', '', '']);
      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        text: 'Test Action',
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the data is in the current state
      final state = container.read(mandalartProvider);
      expect(state.displayName, 'Test Journey');
      expect(state.goalText, 'Test Goal');
      expect(state.themes[0], 'Theme 1');
      expect(state.actionItems.length, 1);
      expect(state.actionItems[0].actionText, 'Test Action');
    });
  });
}

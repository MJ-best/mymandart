import 'package:flutter_test/flutter_test.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<MandalartNotifier> createNotifier([
    Map<String, Object> initialValues = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initialValues);
    final notifier = MandalartNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return notifier;
  }

  group('MandalartNotifier', () {
    test('cycles action status and timestamps in original order', () async {
      final notifier = await createNotifier();

      notifier.initialize('러닝 프로젝트', '하프 마라톤 완주');
      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        text: '주 3회 달리기',
      );

      expect(notifier.state.actionItems.single.status, ActionStatus.notStarted);

      final first = notifier.toggleActionStatus(themeIndex: 0, actionIndex: 0);
      final afterFirst = notifier.state.actionItems.single;
      expect(first, ActionStatus.inProgress);
      expect(afterFirst.status, ActionStatus.inProgress);
      expect(afterFirst.startedAt, isNotNull);
      expect(afterFirst.completedAt, isNull);

      final second = notifier.toggleActionStatus(themeIndex: 0, actionIndex: 0);
      final afterSecond = notifier.state.actionItems.single;
      expect(second, ActionStatus.completed);
      expect(afterSecond.status, ActionStatus.completed);
      expect(afterSecond.startedAt, isNotNull);
      expect(afterSecond.completedAt, isNotNull);

      final third = notifier.toggleActionStatus(themeIndex: 0, actionIndex: 0);
      final afterThird = notifier.state.actionItems.single;
      expect(third, ActionStatus.notStarted);
      expect(afterThird.status, ActionStatus.notStarted);
      expect(afterThird.startedAt, isNotNull);
      expect(afterThird.completedAt, isNotNull);
    });

    test('saves, lists, resets, and reloads mandalarts', () async {
      final notifier = await createNotifier();

      notifier.initialize('2026 계획', '자격증 취득');
      notifier.updateActionItem(
        themeIndex: 0,
        actionIndex: 0,
        text: '매일 한 시간 공부',
      );
      notifier.toggleActionStatus(themeIndex: 0, actionIndex: 0);
      notifier.toggleActionStatus(themeIndex: 0, actionIndex: 0);

      final saved = await notifier.saveCurrentMandalart();
      final savedList = await notifier.getSavedMandalarts();

      expect(saved.$2, isFalse);
      expect(savedList, hasLength(1));
      expect(savedList.single.displayName, '2026 계획');
      expect(savedList.single.completedCount, 1);

      await notifier.startNewMandalart();
      expect(notifier.state.goalText, isEmpty);

      await notifier.loadMandalart(saved.$1);
      expect(notifier.state.displayName, '2026 계획');
      expect(notifier.state.goalText, '자격증 취득');
      expect(notifier.state.actionItems.single.status, ActionStatus.completed);
    });
  });
}

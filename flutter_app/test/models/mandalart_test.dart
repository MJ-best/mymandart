import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';

void main() {
  test('model serialization keeps legacy theme and action formats working', () {
    final parsed = MandalartStateModel.fromJson({
      'displayName': '테스트 만다라트',
      'goalText': '테스트 목표',
      'themes': ['주제 1', '주제 2'],
      'actionItems': [
        {
          'id': 'action-1',
          'themeId': 'theme-0',
          'actionText': '실행 1',
          'status': 'inProgress',
          'order': 0,
          'createdAt': '2026-03-21T00:00:00.000Z',
          'updatedAt': '2026-03-21T00:00:00.000Z',
          'startedAt': '2026-03-21T01:00:00.000Z',
        },
        {
          'id': 'action-2',
          'themeId': 'theme-1',
          'actionText': '실행 2',
          'isCompleted': true,
          'order': 1,
          'createdAt': '2026-03-21T00:00:00.000Z',
          'updatedAt': '2026-03-21T00:00:00.000Z',
        },
      ],
      'currentStep': 2,
      'calendarLog': {'2026-03-21': 2},
    });

    expect(parsed.displayName, '테스트 만다라트');
    expect(parsed.goalText, '테스트 목표');
    expect(parsed.themes, hasLength(8));
    expect(parsed.themes.first.themeText, '주제 1');
    expect(parsed.themes[1].themeText, '주제 2');
    expect(parsed.actionItems, hasLength(2));
    expect(parsed.actionItems.first.status, ActionStatus.inProgress);
    expect(parsed.actionItems.last.status, ActionStatus.completed);
    expect(parsed.currentStep, 2);
    expect(parsed.calendarLog['2026-03-21'], 2);
  });

  test('saved mandalart meta counts completed and total items correctly', () {
    final state = MandalartStateModel.initial().copyWith(
      displayName: '카운트 테스트',
      goalText: '목표',
      actionItems: [
        ActionItemModel(
          id: '1',
          themeId: 'theme-0',
          actionText: '완료',
          status: ActionStatus.completed,
          order: 0,
          createdAt: DateTime.parse('2026-03-21T00:00:00.000Z'),
          updatedAt: DateTime.parse('2026-03-21T00:00:00.000Z'),
        ),
        ActionItemModel(
          id: '2',
          themeId: 'theme-0',
          actionText: '진행',
          status: ActionStatus.inProgress,
          order: 1,
          createdAt: DateTime.parse('2026-03-21T00:00:00.000Z'),
          updatedAt: DateTime.parse('2026-03-21T00:00:00.000Z'),
        ),
        ActionItemModel(
          id: '3',
          themeId: 'theme-1',
          actionText: '',
          status: ActionStatus.notStarted,
          order: 2,
          createdAt: DateTime.parse('2026-03-21T00:00:00.000Z'),
          updatedAt: DateTime.parse('2026-03-21T00:00:00.000Z'),
        ),
      ],
    );

    final meta = SavedMandalartMeta.fromState(
      'saved-id',
      state,
      DateTime.parse('2026-03-21T00:00:00.000Z'),
    );

    expect(meta.id, 'saved-id');
    expect(meta.completedCount, 1);
    expect(meta.totalCount, 2);
    expect(meta.displayName, '카운트 테스트');
  });

  test('notifier toggles action status through the expected cycle', () async {
    SharedPreferences.setMockInitialValues({});

    final notifier = MandalartNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    notifier.state = MandalartStateModel.initial().copyWith(
      displayName: '사이클 테스트',
      goalText: '목표',
      actionItems: [
        ActionItemModel(
          id: 'action-1',
          themeId: 'theme-0',
          actionText: '실행',
          status: ActionStatus.notStarted,
          order: 0,
          createdAt: DateTime.parse('2026-03-21T00:00:00.000Z'),
          updatedAt: DateTime.parse('2026-03-21T00:00:00.000Z'),
        ),
      ],
    );

    expect(
      notifier.toggleActionStatus(themeIndex: 0, actionIndex: 0),
      ActionStatus.inProgress,
    );
    expect(notifier.state.actionItems.single.status, ActionStatus.inProgress);
    expect(notifier.state.actionItems.single.startedAt, isNotNull);
    expect(notifier.state.actionItems.single.completedAt, isNull);

    expect(
      notifier.toggleActionStatus(themeIndex: 0, actionIndex: 0),
      ActionStatus.completed,
    );
    expect(notifier.state.actionItems.single.status, ActionStatus.completed);
    expect(notifier.state.actionItems.single.startedAt, isNotNull);
    expect(notifier.state.actionItems.single.completedAt, isNotNull);

    expect(
      notifier.toggleActionStatus(themeIndex: 0, actionIndex: 0),
      ActionStatus.notStarted,
    );
    expect(notifier.state.actionItems.single.status, ActionStatus.notStarted);
    expect(notifier.state.actionItems.single.startedAt, isNotNull);
    expect(notifier.state.actionItems.single.completedAt, isNotNull);
  });
}

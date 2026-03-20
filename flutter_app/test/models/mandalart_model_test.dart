import 'package:flutter_test/flutter_test.dart';
import 'package:mandarart_journey/models/mandalart.dart';

void main() {
  group('MandalartStateModel', () {
    test('round-trips serialized state with priorities and calendar log', () {
      final now = DateTime.parse('2026-03-21T10:00:00.000Z');
      final state = MandalartStateModel(
        displayName: '2026 목표',
        goalText: '풀코스 완주',
        themes: List.generate(
          8,
          (index) => ThemeModel(
            id: 'theme-$index',
            goalId: 'goal-1',
            themeText: '테마 $index',
            order: index,
            priority: index == 0 ? GoalPriority.high : GoalPriority.none,
            createdAt: now,
            updatedAt: now,
          ),
        ),
        actionItems: [
          ActionItemModel(
            id: 'action-1',
            themeId: 'theme-0',
            actionText: '주 3회 달리기',
            status: ActionStatus.completed,
            order: 0,
            createdAt: now,
            updatedAt: now,
            startedAt: now,
            completedAt: now.add(const Duration(days: 1)),
          ),
        ],
        currentStep: 2,
        showViewer: false,
        calendarLog: const {'2026-03-21': 2},
      );

      final restored = MandalartStateModel.fromJson(state.toJson());

      expect(restored.displayName, '2026 목표');
      expect(restored.goalText, '풀코스 완주');
      expect(restored.themes, hasLength(8));
      expect(restored.themes.first.priority, GoalPriority.high);
      expect(restored.actionItems.single.status, ActionStatus.completed);
      expect(restored.actionItems.single.startedAt, isNotNull);
      expect(restored.actionItems.single.completedAt, isNotNull);
      expect(restored.currentStep, 2);
      expect(restored.calendarLog['2026-03-21'], 2);
    });

    test('supports legacy string-based theme payloads', () {
      final restored = MandalartStateModel.fromJson({
        'displayName': '레거시',
        'goalText': '테스트',
        'themes': ['건강', '관계', '학습'],
        'actionItems': [],
        'currentStep': 1,
      });

      expect(restored.themes, hasLength(8));
      expect(restored.themes[0].themeText, '건강');
      expect(restored.themes[1].themeText, '관계');
      expect(restored.themes[2].themeText, '학습');
      expect(restored.themes[3].themeText, isEmpty);
      expect(restored.currentStep, 1);
    });
  });

  group('SavedMandalartMeta', () {
    test('derives completion counts from populated actions', () {
      final now = DateTime.parse('2026-03-21T10:00:00.000Z');
      final state = MandalartStateModel(
        displayName: '저장 테스트',
        goalText: '핵심 목표',
        themes: List.generate(
          8,
          (index) => ThemeModel(
            id: 'theme-$index',
            goalId: 'goal-1',
            themeText: '',
            order: index,
            createdAt: now,
            updatedAt: now,
          ),
        ),
        actionItems: [
          ActionItemModel(
            id: 'done',
            themeId: 'theme-0',
            actionText: '완료한 액션',
            status: ActionStatus.completed,
            order: 0,
            createdAt: now,
            updatedAt: now,
          ),
          ActionItemModel(
            id: 'empty',
            themeId: 'theme-0',
            actionText: '',
            status: ActionStatus.notStarted,
            order: 1,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        currentStep: 0,
        showViewer: false,
        calendarLog: const {},
      );

      final meta = SavedMandalartMeta.fromState('id-1', state, now);

      expect(meta.displayName, '저장 테스트');
      expect(meta.completedCount, 1);
      expect(meta.totalCount, 1);
      expect(meta.createdAt, now);
    });
  });
}


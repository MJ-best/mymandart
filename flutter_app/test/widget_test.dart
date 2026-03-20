import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mandarart_journey/main.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/screens/mandalart_app.dart';
import 'package:mandarart_journey/widgets/step_progress_indicator.dart';

class _SeededMandalartNotifier extends MandalartNotifier {
  _SeededMandalartNotifier(MandalartStateModel initial) : super() {
    state = initial;
  }
}

Future<void> _pumpRoot(
  WidgetTester tester, {
  required Map<String, Object> prefs,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  await tester.pumpWidget(const ProviderScope(child: MandarartRoot()));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _pumpSeededApp(
  WidgetTester tester,
  MandalartStateModel state,
) async {
  SharedPreferences.setMockInitialValues({
    'has_started': true,
    'mandalart-display-name': state.displayName,
    'mandalart-goal': state.goalText,
    'mandalart-themes':
        state.themes.map((theme) => theme.themeText).toList(growable: false),
    'mandalart-actions': jsonEncode(
      state.actionItems.map((action) => action.toJson()).toList(),
    ),
    'mandalart-current-step': state.currentStep,
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mandalartProvider.overrideWith(
          (ref) => _SeededMandalartNotifier(state),
        ),
      ],
      child: const MaterialApp(home: MandalartAppScreen()),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  testWidgets('first launch shows the landing screen', (tester) async {
    await _pumpRoot(
      tester,
      prefs: {'has_started': false},
    );

    expect(find.text('Mandarat'), findsOneWidget);
    expect(find.text('나의 만다라트 만들기'), findsOneWidget);
    expect(find.text('만다라트 예시보기'), findsOneWidget);
  });

  testWidgets('started user without goal is sent to the start screen', (
    tester,
  ) async {
    await _pumpRoot(
      tester,
      prefs: {'has_started': true},
    );

    expect(find.text('만다라트 만들기'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.textContaining('어떤 목표를'), findsOneWidget);
  });

  testWidgets('seeded mandalart app screen keeps the main flow visible', (
    tester,
  ) async {
    final seededState = MandalartStateModel.initial().copyWith(
      displayName: '러닝 프로젝트',
      goalText: '하프 마라톤 완주',
      currentStep: 0,
    );

    await _pumpSeededApp(tester, seededState);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MandalartAppScreen)),
    );

    expect(container.read(mandalartProvider).displayName, '러닝 프로젝트');
    expect(container.read(mandalartProvider).goalText, '하프 마라톤 완주');
    expect(find.byType(StepProgressIndicator), findsOneWidget);
    expect(find.text('뷰어'), findsWidgets);
  });
}

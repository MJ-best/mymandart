// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MandarartRoot()));
    await tester.pumpAndSettle();

    // Verify that the landing screen loads with the expected hero title
    expect(find.text('만다라트로 여정을 디자인하세요'), findsOneWidget);
  });
}

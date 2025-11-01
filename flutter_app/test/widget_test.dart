// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mandarart_journey/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // SharedPreferences 초기화 (has_started를 false로 설정하여 랜딩 페이지가 표시되도록 함)
    SharedPreferences.setMockInitialValues({'has_started': false});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MandarartRoot()));

    // 라우팅이 완료될 때까지 대기 (비동기 redirect 처리)
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify that the landing screen loads with expected content
    // 앱 제목을 찾거나 "Mandarat" 텍스트를 찾음
    expect(
      find.textContaining('만다라트', findRichText: true),
      findsWidgets,
    );
  });
}

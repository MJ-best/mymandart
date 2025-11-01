import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mandarart_journey/screens/mandalart_app.dart';
import 'package:mandarart_journey/screens/landing_screen.dart';
import 'package:mandarart_journey/screens/saved_mandalarts_screen.dart';
import 'package:mandarart_journey/screens/example_mandalart_screen.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';
import 'package:mandarart_journey/l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: MandarartRoot()));
}

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    // 앱 시작 시에만 체크 (루트 경로에서만)
    if (state.matchedLocation == '/') {
      final prefs = await SharedPreferences.getInstance();
      final hasStarted = prefs.getBool('has_started') ?? false;

      // 사용자가 이미 시작했다면 /create로 리다이렉트
      if (hasStarted) {
        return '/create';
      }
    }
    return null; // 리다이렉트 없음
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const MandalartAppScreen(),
    ),
    GoRoute(
      path: '/saved-mandalarts',
      builder: (context, state) => const SavedMandalartsScreen(),
    ),
    GoRoute(
      path: '/example',
      builder: (context, state) => const ExampleMandalartScreen(),
    ),
  ],
);

class MandarartRoot extends ConsumerWidget {
  const MandarartRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 테마 상태 가져오기
    final themeState = ref.watch(themeProvider);
    final brightness = themeState.effectiveBrightness;

    return CupertinoApp.router(
      routerConfig: _router,
      title: 'Mandarat',
      theme: _buildTheme(brightness),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  /// Brightness에 따라 적절한 테마 데이터 생성
  CupertinoThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: CupertinoColors.systemGreen,
      scaffoldBackgroundColor: isDark
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      barBackgroundColor: isDark
          ? const CupertinoDynamicColor.withBrightness(
              color: Color(0xFF1C1C1E),
              darkColor: Color(0xFF1C1C1E),
            )
          : CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.systemGreen,
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
        ),
        textStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
        ),
      ),
    );
  }
}

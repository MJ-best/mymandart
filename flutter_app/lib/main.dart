import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarart_journey/screens/mandalart_app.dart';
import 'package:mandarart_journey/screens/landing_screen.dart';
import 'package:mandarart_journey/screens/saved_mandalarts_screen.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MandarartRoot()));
}

final _router = GoRouter(
  initialLocation: '/',
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
    );
  }

  /// Brightness에 따라 적절한 테마 데이터 생성
  CupertinoThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: CupertinoColors.systemPurple,
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
        primaryColor: CupertinoColors.systemPurple,
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

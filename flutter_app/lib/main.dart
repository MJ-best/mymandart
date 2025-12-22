import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mandarart_journey/screens/mandalart_app.dart';
import 'package:mandarart_journey/screens/start_screen.dart';
import 'package:mandarart_journey/screens/landing_screen.dart';
import 'package:mandarart_journey/screens/saved_mandalarts_screen.dart';
import 'package:mandarart_journey/screens/example_mandalart_screen.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';
import 'package:mandarart_journey/l10n/app_localizations.dart';
import 'package:mandarart_journey/utils/app_theme.dart';

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
        return '/app';
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
      path: '/start',
      builder: (context, state) => const StartScreen(),
    ),
    GoRoute(
      path: '/app',
      builder: (context, state) => const MandalartAppScreen(),
    ),
    GoRoute(
      path: '/create', // Legacy redirect or keep for safety
      redirect: (_, __) => '/app', 
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

    return MaterialApp.router(
      routerConfig: _router,
      title: 'Mandarat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        // Ensure Cupertino widgets inside MaterialApp follow the Material Theme
        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: brightness,
            primaryColor: brightness == Brightness.dark 
                ? AppTheme.darkTheme.colorScheme.primary 
                : AppTheme.lightTheme.colorScheme.primary,
            scaffoldBackgroundColor: brightness == Brightness.dark 
                ? AppTheme.darkTheme.scaffoldBackgroundColor 
                : AppTheme.lightTheme.scaffoldBackgroundColor,
            barBackgroundColor: brightness == Brightness.dark 
                ? AppTheme.darkTheme.appBarTheme.backgroundColor 
                : AppTheme.lightTheme.appBarTheme.backgroundColor,
          ),
          child: child!,
        );
      },
    );
  }
}

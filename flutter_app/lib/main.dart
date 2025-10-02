import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarart_journey/screens/mandalart_app.dart';
import 'package:mandarart_journey/screens/landing_screen.dart';

void main() {
  runApp(const ProviderScope(child: MandarartRoot()));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const MandalartAppScreen(),
    ),
  ],
);

class MandarartRoot extends StatelessWidget {
  const MandarartRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      routerConfig: _router,
      title: 'Mandalart Journey',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemPurple,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        barBackgroundColor: CupertinoColors.systemBackground,
        textTheme: CupertinoTextThemeData(
          navLargeTitleTextStyle: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.5,
            color: CupertinoColors.label,
          ),
          navTitleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
          textStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: CupertinoColors.label,
          ),
        ),
      ),
    );
  }
}

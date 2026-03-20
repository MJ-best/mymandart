import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/core/router/app_router.dart';
import 'package:mandarart_journey/core/theme/app_theme.dart';
import 'package:mandarart_journey/features/auth/presentation/session_controller.dart';

class WorkflowPlatformApp extends ConsumerWidget {
  const WorkflowPlatformApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final session = ref.watch(sessionControllerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'VibeFlow',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: session.themeMode,
      routerConfig: router,
    );
  }
}

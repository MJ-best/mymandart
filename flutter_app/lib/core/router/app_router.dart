import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mandarart_journey/core/layout/app_shell.dart';
import 'package:mandarart_journey/features/artifacts/presentation/artifact_viewer_screen.dart';
import 'package:mandarart_journey/features/auth/presentation/login_screen.dart';
import 'package:mandarart_journey/features/auth/presentation/session_controller.dart';
import 'package:mandarart_journey/features/projects/presentation/project_detail_screen.dart';
import 'package:mandarart_journey/features/projects/presentation/project_list_screen.dart';
import 'package:mandarart_journey/features/settings/presentation/settings_screen.dart';
import 'package:mandarart_journey/features/workspace/presentation/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (!session.isReady) {
        return location == '/' ? null : '/';
      }

      if (!session.canAccessApp) {
        return location == '/login' ? null : '/login';
      }

      if (location == '/' || location == '/login') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AppShell(
          currentIndex: 0,
          child: DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const AppShell(
          currentIndex: 1,
          child: ProjectListScreen(),
        ),
        routes: [
          GoRoute(
            path: ':projectId',
            builder: (context, state) {
              final projectId = state.pathParameters['projectId']!;
              return AppShell(
                currentIndex: 1,
                child: ProjectDetailScreen(projectId: projectId),
              );
            },
            routes: [
              GoRoute(
                path: 'artifacts/:artifactId',
                builder: (context, state) {
                  final projectId = state.pathParameters['projectId']!;
                  final artifactId = state.pathParameters['artifactId']!;
                  return AppShell(
                    currentIndex: 1,
                    child: ArtifactViewerScreen(
                      projectId: projectId,
                      artifactId: artifactId,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const AppShell(
          currentIndex: 2,
          child: SettingsScreen(),
        ),
      ),
    ],
  );
});

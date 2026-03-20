import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mandarart_journey/core/theme/app_theme.dart';
import 'package:mandarart_journey/features/auth/presentation/session_controller.dart';
import 'package:mandarart_journey/features/workspace/presentation/workspace_controller.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final workspace = ref.watch(activeWorkspaceProvider);
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    void onDestinationSelected(int index) {
      switch (index) {
        case 0:
          context.go('/dashboard');
          return;
        case 1:
          context.go('/projects');
          return;
        case 2:
          context.go('/settings');
          return;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 960;

        if (useRail) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        right: BorderSide(
                            color: Theme.of(context).colorScheme.outline),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VibeFlow',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                workspace?.name ?? 'Workflow Platform',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: colors.muted),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                session.user?.label ??
                                    (session.isSupabaseConfigured
                                        ? 'Local workspace'
                                        : 'Local-first mode'),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: NavigationRail(
                            selectedIndex: currentIndex,
                            onDestinationSelected: onDestinationSelected,
                            labelType: NavigationRailLabelType.all,
                            destinations: const [
                              NavigationRailDestination(
                                icon: Icon(Icons.space_dashboard_rounded),
                                label: Text('Dashboard'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.account_tree_rounded),
                                label: Text('Projects'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.settings_rounded),
                                label: Text('Settings'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: SafeArea(child: child)),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(workspace?.name ?? 'Workflow Platform'),
          ),
          body: SafeArea(child: child),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_tree_rounded),
                label: 'Projects',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

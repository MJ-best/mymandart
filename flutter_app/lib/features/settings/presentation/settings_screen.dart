import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/core/theme/app_theme.dart';
import 'package:mandarart_journey/features/auth/presentation/session_controller.dart';
import 'package:mandarart_journey/features/workspace/presentation/workspace_controller.dart';
import 'package:mandarart_journey/features/workspace/presentation/workspace_switcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final workspace = ref.watch(activeWorkspaceProvider);
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Text(
          'Settings',
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage and Sync',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(session.user?.label ??
                    (session.isDemoMode
                        ? 'Local-only workspace'
                        : 'Signed out')),
                const SizedBox(height: 8),
                Text(
                  session.isSupabaseConfigured
                      ? 'Local mode is default. Google cloud sync is available as an optional premium path.'
                      : 'The app is currently running in local-first mode. Cloud sync is deferred.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => ref
                          .read(sessionControllerProvider.notifier)
                          .continueInDemoMode(),
                      icon: const Icon(Icons.computer_rounded),
                      label: const Text('Use local workspace'),
                    ),
                    if (session.isSupabaseConfigured)
                      OutlinedButton.icon(
                        onPressed: session.user == null
                            ? () => ref
                                .read(sessionControllerProvider.notifier)
                                .signInWithGoogle()
                            : null,
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Connect Google sync'),
                      ),
                    OutlinedButton.icon(
                      onPressed: session.user != null
                          ? () => ref
                              .read(sessionControllerProvider.notifier)
                              .signOut()
                          : null,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Disconnect cloud'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const WorkspaceSwitcher(),
                if (workspace != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${workspace.name} • ${workspace.plan}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colors.muted),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme mode',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {session.themeMode},
                  onSelectionChanged: (values) {
                    ref
                        .read(sessionControllerProvider.notifier)
                        .setThemeMode(values.first);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

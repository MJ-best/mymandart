import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/core/theme/app_theme.dart';
import 'package:mandarart_journey/features/auth/presentation/session_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 840;
                final hero = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VibeFlow',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Goal in. Structured artifacts out.',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This MVP is a workflow-based artifact system. The orchestrator plans, specialist agents execute, and users review pipeline outputs instead of chatting.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: colors.muted, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                );
                final actions = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Local-first studio',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => ref
                                .read(sessionControllerProvider.notifier)
                                .continueInDemoMode(),
                            icon: const Icon(Icons.rocket_launch_rounded),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('Continue locally'),
                            ),
                          ),
                        ),
                        if (session.isSupabaseConfigured) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: session.isSigningIn
                                  ? null
                                  : () => ref
                                      .read(sessionControllerProvider.notifier)
                                      .signInWithGoogle(),
                              icon: session.isSigningIn
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('Connect Google for cloud sync'),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
                          Text(
                            'Cloud sync with Supabase is reserved for a future premium workspace tier.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: colors.muted, height: 1.5),
                          ),
                        ],
                        if (session.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            session.errorMessage!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                );

                if (wide) {
                  return Row(
                    children: [
                      Expanded(child: hero),
                      const SizedBox(width: 24),
                      Expanded(child: actions),
                    ],
                  );
                }

                return ListView(
                  shrinkWrap: true,
                  children: [
                    hero,
                    const SizedBox(height: 20),
                    actions,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

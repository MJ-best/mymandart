import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mandarart_journey/core/theme/app_theme.dart';
import 'package:mandarart_journey/features/agents/data/agent_repository.dart';
import 'package:mandarart_journey/features/projects/presentation/project_controller.dart';
import 'package:mandarart_journey/features/workspace/presentation/workspace_switcher.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _goalController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final composer = ref.watch(projectComposerControllerProvider);
    final agentsAsync = ref.watch(agentCatalogProvider);
    final projectsAsync = ref.watch(projectBundlesProvider);
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Text(
          'Build with agent pipelines',
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'Start locally on web. Enter one product goal and the agents move it through plan, execution, progress, and review without extra setup.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: colors.muted, height: 1.5),
        ),
        const SizedBox(height: 20),
        const WorkspaceSwitcher(),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start with one goal',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _goalController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'project_goal',
                    hintText:
                        'Build a multi-agent platform that turns product goals into PRD, schema, UI, code, and QA artifacts.',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: composer.isSubmitting ? null : _createProject,
                    icon: composer.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Generate execution plan'),
                    ),
                  ),
                ),
                if (composer.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    composer.errorMessage!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        agentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text(error.toString()),
          data: (agents) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final agent in agents)
                SizedBox(
                  width: 220,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agent.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            agent.boundary,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colors.muted, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Recent projects',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        projectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text(error.toString()),
          data: (projects) {
            if (projects.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No projects yet. Start with one goal above.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colors.muted),
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (final bundle in projects.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        onTap: () =>
                            context.go('/projects/${bundle.project.id}'),
                        title: Text(bundle.project.title),
                        subtitle: Text(bundle.project.projectGoal),
                        trailing: Text(
                          '${bundle.completedTaskCount}/${bundle.tasks.length}',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _createProject() async {
    final project = await ref
        .read(projectComposerControllerProvider.notifier)
        .createProjectFromGoal(_goalController.text);
    if (project == null || !mounted) {
      return;
    }
    _goalController.clear();
    context.go('/projects/${project.project.id}');
  }
}

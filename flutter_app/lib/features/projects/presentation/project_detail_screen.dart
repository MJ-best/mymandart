import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mandarart_journey/core/theme/app_theme.dart';
import 'package:mandarart_journey/core/widgets/responsive_scaffold.dart';
import 'package:mandarart_journey/features/agents/data/agent_repository.dart';
import 'package:mandarart_journey/features/agents/presentation/workflow_view.dart';
import 'package:mandarart_journey/features/artifacts/data/artifact_repository.dart';
import 'package:mandarart_journey/features/chat/data/conversation_repository.dart';
import 'package:mandarart_journey/features/chat/presentation/execution_log_panel.dart';
import 'package:mandarart_journey/features/projects/presentation/project_controller.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundleAsync = ref.watch(projectBundleProvider(projectId));
    final agentsAsync = ref.watch(agentCatalogProvider);
    final artifactsAsync = ref.watch(projectArtifactsProvider(projectId));
    final executionLogAsync = ref.watch(executionLogProvider(projectId));
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return bundleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      data: (bundle) {
        if (bundle == null) {
          return const Center(child: Text('Project not found.'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: [
            Text(
              bundle.project.title,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              bundle.project.projectGoal,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: colors.muted, height: 1.5),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(label: Text(bundle.project.status.name)),
                Chip(label: Text('${bundle.tasks.length} tasks')),
                Chip(label: Text('${bundle.artifacts.length} artifacts')),
                Chip(label: Text('${bundle.toolRuns.length} tool runs')),
              ],
            ),
            const SizedBox(height: 24),
            ResponsiveScaffold(
              primary: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workflow',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  agentsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Text(error.toString()),
                    data: (agents) =>
                        WorkflowView(agents: agents, tasks: bundle.tasks),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Artifacts',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  artifactsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Text(error.toString()),
                    data: (artifacts) => Column(
                      children: [
                        for (final artifact in artifacts)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              child: ListTile(
                                onTap: () => context.go(
                                  '/projects/${bundle.project.id}/artifacts/${artifact.id}',
                                ),
                                leading: const Icon(Icons.description_outlined),
                                title: Text(artifact.title),
                                subtitle: Text(
                                    '${artifact.type.name} • ${artifact.format}'),
                                trailing:
                                    Chip(label: Text(artifact.status.name)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              secondary: executionLogAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text(error.toString()),
                data: (log) {
                  if (log == null) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No execution log found.'),
                      ),
                    );
                  }
                  return ExecutionLogPanel(executionLog: log);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

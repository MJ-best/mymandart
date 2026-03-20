import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/core/theme/app_theme.dart';
import 'package:mandarart_journey/features/artifacts/data/artifact_repository.dart';

class ArtifactViewerScreen extends ConsumerWidget {
  const ArtifactViewerScreen({
    super.key,
    required this.projectId,
    required this.artifactId,
  });

  final String projectId;
  final String artifactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artifactAsync = ref.watch(
      artifactProvider(
        ArtifactRequest(projectId: projectId, artifactId: artifactId),
      ),
    );
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return artifactAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      data: (artifact) {
        if (artifact == null) {
          return const Center(child: Text('Artifact not found.'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: [
            Text(
              artifact.title,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(label: Text(artifact.type.name)),
                Chip(label: Text(artifact.format)),
                Chip(label: Text(artifact.status.name)),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectableText(
                  artifact.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.muted.withValues(alpha: 0.95),
                        height: 1.6,
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'package:mandarart_journey/core/theme/app_theme.dart';
import 'package:mandarart_journey/features/agents/domain/agent_models.dart';
import 'package:mandarart_journey/features/projects/domain/project_models.dart';

class AgentStepCard extends StatelessWidget {
  const AgentStepCard({
    super.key,
    required this.agent,
    required this.task,
    required this.index,
  });

  final PlatformAgent agent;
  final ProjectTask task;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final statusColor = switch (task.status) {
      TaskStatus.completed => Colors.green.shade600,
      TaskStatus.failed => Theme.of(context).colorScheme.error,
      TaskStatus.running => colors.accent,
      _ => colors.muted,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.brand.withValues(alpha: 0.12),
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        task.title,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(task.status.name),
                  side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              agent.boundary,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

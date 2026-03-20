import 'package:flutter/material.dart';

import 'package:mandarart_journey/core/theme/app_theme.dart';
import 'package:mandarart_journey/features/chat/data/conversation_repository.dart';

class ExecutionLogPanel extends StatelessWidget {
  const ExecutionLogPanel({
    super.key,
    required this.executionLog,
  });

  final ExecutionLog executionLog;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Execution Logs',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  executionLog.conversation.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                for (final message in executionLog.messages) ...[
                  Text(
                    message.agentKey ?? message.role.name.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.brand, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.content,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Tool Runs',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (final run in executionLog.toolRuns)
          Card(
            child: ListTile(
              leading: const Icon(Icons.build_circle_outlined),
              title: Text(run.toolName),
              subtitle: Text(run.agentKey ?? 'system'),
              trailing: Chip(label: Text(run.status.name)),
            ),
          ),
      ],
    );
  }
}

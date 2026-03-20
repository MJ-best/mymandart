import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/features/workspace/presentation/workspace_controller.dart';

class WorkspaceSwitcher extends ConsumerWidget {
  const WorkspaceSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceState = ref.watch(workspaceControllerProvider);
    if (workspaceState.workspaces.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<String>(
      initialValue: workspaceState.activeWorkspaceId,
      decoration: const InputDecoration(labelText: 'Workspace'),
      items: [
        for (final workspace in workspaceState.workspaces)
          DropdownMenuItem(
            value: workspace.id,
            child: Text(workspace.name),
          ),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }
        ref
            .read(workspaceControllerProvider.notifier)
            .setActiveWorkspace(value);
      },
    );
  }
}

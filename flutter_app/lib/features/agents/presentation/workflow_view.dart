import 'package:flutter/material.dart';

import 'package:mandarart_journey/features/agents/domain/agent_models.dart';
import 'package:mandarart_journey/features/agents/presentation/agent_step_card.dart';
import 'package:mandarart_journey/features/projects/domain/project_models.dart';

class WorkflowView extends StatelessWidget {
  const WorkflowView({
    super.key,
    required this.agents,
    required this.tasks,
  });

  final List<PlatformAgent> agents;
  final List<ProjectTask> tasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < agents.length; index++) ...[
          AgentStepCard(
            agent: agents[index],
            task: tasks.firstWhere(
              (task) => task.assignedAgentKey == agents[index].key,
              orElse: () => ProjectTask(
                id: 'missing-$index',
                projectId: 'missing',
                assignedAgentKey: agents[index].key,
                taskType: 'missing',
                title: 'Missing task',
                status: TaskStatus.failed,
                dedupeKey: 'missing-$index',
                input: const {},
                output: const {},
                createdAt: DateTime.now(),
              ),
            ),
            index: index,
          ),
          if (index != agents.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Icon(
                Icons.south_rounded,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
        ],
      ],
    );
  }
}

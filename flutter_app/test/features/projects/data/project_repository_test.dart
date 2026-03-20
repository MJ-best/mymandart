import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mandarart_journey/features/agents/domain/agent_models.dart';
import 'package:mandarart_journey/features/artifacts/domain/artifact_models.dart';
import 'package:mandarart_journey/features/projects/data/project_repository.dart';
import 'package:mandarart_journey/features/projects/domain/project_models.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('createProjectFromGoal builds an ordered workflow bundle', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = LocalProjectRepository(prefs);

    final bundle = await repository.createProjectFromGoal(
      workspaceId: 'workspace-1',
      createdBy: 'demo-user',
      projectGoal: 'Build a multi-agent vibe coding platform',
      agents: _agents,
    );

    expect(bundle.project.status, ProjectStatus.completed);
    expect(
      bundle.project.executionPlan.map((step) => step.agentKey).toList(),
      ['orchestrator', 'pm', 'system_designer', 'flutter', 'qa'],
    );
    expect(bundle.tasks, hasLength(5));
    expect(bundle.completedTaskCount, 5);
    expect(bundle.artifacts, hasLength(6));
    expect(
      bundle.artifacts.map((artifact) => artifact.type).toList(),
      [
        ArtifactType.executionPlan,
        ArtifactType.prd,
        ArtifactType.schema,
        ArtifactType.ui,
        ArtifactType.code,
        ArtifactType.qa,
      ],
    );
    expect(
      bundle.artifacts
          .singleWhere((artifact) => artifact.type == ArtifactType.code)
          .status,
      ArtifactStatus.partial,
    );

    final stored = await repository.listProjects(workspaceId: 'workspace-1');
    expect(stored, hasLength(1));
    expect(stored.first.project.id, bundle.project.id);
  });

  test('createProjectFromGoal rejects empty and duplicate goals', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = LocalProjectRepository(prefs);

    await expectLater(
      repository.createProjectFromGoal(
        workspaceId: 'workspace-1',
        createdBy: 'demo-user',
        projectGoal: '   ',
        agents: _agents,
      ),
      throwsA(
        isA<ProjectRepositoryException>().having(
          (error) => error.message,
          'message',
          contains('project_goal must not be empty'),
        ),
      ),
    );

    await repository.createProjectFromGoal(
      workspaceId: 'workspace-1',
      createdBy: 'demo-user',
      projectGoal: 'Build a multi-agent vibe coding platform',
      agents: _agents,
    );

    await expectLater(
      repository.createProjectFromGoal(
        workspaceId: 'workspace-1',
        createdBy: 'demo-user',
        projectGoal: 'build a multi-agent vibe coding platform',
        agents: _agents,
      ),
      throwsA(
        isA<ProjectRepositoryException>().having(
          (error) => error.message,
          'message',
          contains('Duplicate task execution blocked'),
        ),
      ),
    );
  });
}

const _agents = [
  PlatformAgent(
    key: 'orchestrator',
    name: 'Orchestrator Agent',
    roleName: 'orchestrator',
    boundary: 'Plans workflow.',
    systemPrompt: 'Plan the workflow.',
    sortOrder: 0,
    outputTypes: ['execution_plan'],
    skills: [
      AgentSkill(
        key: 'planning',
        label: 'Planning',
        description: 'Creates a plan.',
      ),
    ],
  ),
  PlatformAgent(
    key: 'pm',
    name: 'PM Agent',
    roleName: 'pm',
    boundary: 'Writes product specs.',
    systemPrompt: 'Create the PRD.',
    sortOrder: 1,
    outputTypes: ['prd'],
    skills: [
      AgentSkill(
        key: 'prd',
        label: 'PRD',
        description: 'Defines scope.',
      ),
    ],
  ),
  PlatformAgent(
    key: 'system_designer',
    name: 'System Designer Agent',
    roleName: 'system_designer',
    boundary: 'Designs schema and policies.',
    systemPrompt: 'Design the schema.',
    sortOrder: 2,
    outputTypes: ['schema'],
    skills: [
      AgentSkill(
        key: 'schema',
        label: 'Schema',
        description: 'Defines tables.',
      ),
    ],
  ),
  PlatformAgent(
    key: 'flutter',
    name: 'Flutter Agent',
    roleName: 'flutter',
    boundary: 'Builds UI and code.',
    systemPrompt: 'Generate the Flutter app shell.',
    sortOrder: 3,
    outputTypes: ['ui', 'code'],
    skills: [
      AgentSkill(
        key: 'ui',
        label: 'UI',
        description: 'Builds the app shell.',
      ),
    ],
  ),
  PlatformAgent(
    key: 'qa',
    name: 'QA Agent',
    roleName: 'qa',
    boundary: 'Finds gaps and missing cases.',
    systemPrompt: 'Review the outputs.',
    sortOrder: 4,
    outputTypes: ['qa'],
    skills: [
      AgentSkill(
        key: 'qa',
        label: 'QA',
        description: 'Checks edge cases.',
      ),
    ],
  ),
];

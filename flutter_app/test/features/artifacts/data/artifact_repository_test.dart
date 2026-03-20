import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mandarart_journey/features/agents/domain/agent_models.dart';
import 'package:mandarart_journey/features/artifacts/data/artifact_repository.dart';
import 'package:mandarart_journey/features/artifacts/domain/artifact_models.dart';
import 'package:mandarart_journey/features/projects/data/project_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('artifact repository returns stored project artifacts', () async {
    final prefs = await SharedPreferences.getInstance();
    final projectRepository = LocalProjectRepository(prefs);
    final bundle = await projectRepository.createProjectFromGoal(
      workspaceId: 'workspace-1',
      createdBy: 'demo-user',
      projectGoal: 'Build MVP workflow',
      agents: _agents,
    );
    final repository = ProjectArtifactRepository(projectRepository);

    final artifacts = await repository.listArtifacts(bundle.project.id);
    final executionPlan = await repository.getArtifact(
      projectId: bundle.project.id,
      artifactId: artifacts.first.id,
    );

    expect(artifacts, hasLength(6));
    expect(
      artifacts.map((artifact) => artifact.type).toSet(),
      {
        ArtifactType.executionPlan,
        ArtifactType.prd,
        ArtifactType.schema,
        ArtifactType.ui,
        ArtifactType.code,
        ArtifactType.qa,
      },
    );
    expect(executionPlan?.body, contains('Goal: Build MVP workflow'));
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

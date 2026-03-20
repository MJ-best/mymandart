import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mandarart_journey/core/providers/app_providers.dart';
import 'package:mandarart_journey/core/workflow_platform_app.dart';
import 'package:mandarart_journey/features/agents/data/agent_repository.dart';
import 'package:mandarart_journey/features/agents/domain/agent_models.dart';
import 'package:mandarart_journey/features/projects/data/project_repository.dart';
import 'package:mandarart_journey/features/workspace/data/workspace_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('demo mode opens dashboard and navigates project workflow',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('platform.demo_mode', true);

    final workspaceRepository = LocalWorkspaceRepository(prefs);
    final workspace =
        (await workspaceRepository.ensureSeed(ownerUserId: 'demo-user')).single;
    final projectRepository = LocalProjectRepository(prefs);
    await projectRepository.createProjectFromGoal(
      workspaceId: workspace.id,
      createdBy: 'demo-user',
      projectGoal: 'Build MVP workflow',
      agents: _testAgents,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          agentRepositoryProvider
              .overrideWithValue(const _TestAgentRepository()),
        ],
        child: const WorkflowPlatformApp(),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Build with agent pipelines'), findsOneWidget);
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    expect(find.text('Build MVP workflow'), findsWidgets);
    await tester.tap(find.text('Build MVP workflow').first,
        warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Workflow'), findsOneWidget);
    expect(find.text('Artifacts'), findsOneWidget);
    expect(find.text('Execution Plan'), findsOneWidget);
  });
}

class _TestAgentRepository implements AgentRepository {
  const _TestAgentRepository();

  @override
  Future<List<PlatformAgent>> listAgents() async => _testAgents;
}

const _testAgents = [
  PlatformAgent(
    key: 'orchestrator',
    name: 'Orchestrator Agent',
    roleName: 'orchestrator',
    boundary: 'Plans the workflow and assigns tasks.',
    systemPrompt: 'Plan the workflow.',
    sortOrder: 0,
    outputTypes: ['execution_plan'],
    skills: [
      AgentSkill(
        key: 'planning',
        label: 'Planning',
        description: 'Creates the task graph.',
      ),
    ],
  ),
  PlatformAgent(
    key: 'pm',
    name: 'PM Agent',
    roleName: 'pm',
    boundary: 'Defines the PRD and user flow.',
    systemPrompt: 'Write the PRD.',
    sortOrder: 1,
    outputTypes: ['prd'],
    skills: [
      AgentSkill(
        key: 'prd',
        label: 'PRD',
        description: 'Scopes the MVP.',
      ),
    ],
  ),
  PlatformAgent(
    key: 'system_designer',
    name: 'System Designer Agent',
    roleName: 'system_designer',
    boundary: 'Designs schema and RLS.',
    systemPrompt: 'Design the schema.',
    sortOrder: 2,
    outputTypes: ['schema'],
    skills: [
      AgentSkill(
        key: 'schema',
        label: 'Schema',
        description: 'Models data and ownership.',
      ),
    ],
  ),
  PlatformAgent(
    key: 'flutter',
    name: 'Flutter Agent',
    roleName: 'flutter',
    boundary: 'Builds the Flutter UI.',
    systemPrompt: 'Build the UI.',
    sortOrder: 3,
    outputTypes: ['ui', 'code'],
    skills: [
      AgentSkill(
        key: 'ui',
        label: 'UI',
        description: 'Builds a responsive workflow UI.',
      ),
    ],
  ),
  PlatformAgent(
    key: 'qa',
    name: 'QA Agent',
    roleName: 'qa',
    boundary: 'Validates gaps and edge cases.',
    systemPrompt: 'Review the output.',
    sortOrder: 4,
    outputTypes: ['qa'],
    skills: [
      AgentSkill(
        key: 'qa',
        label: 'QA',
        description: 'Reviews missing cases.',
      ),
    ],
  ),
];

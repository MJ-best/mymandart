import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:mandarart_journey/core/providers/app_providers.dart';
import 'package:mandarart_journey/features/agents/domain/agent_models.dart';
import 'package:mandarart_journey/features/artifacts/domain/artifact_models.dart';
import 'package:mandarart_journey/features/chat/domain/conversation_models.dart';
import 'package:mandarart_journey/features/projects/domain/project_models.dart';

abstract class ProjectRepository {
  Future<List<ProjectBundle>> listProjects({required String workspaceId});
  Future<ProjectBundle?> getProject(String projectId);
  Future<ProjectBundle> createProjectFromGoal({
    required String workspaceId,
    required String createdBy,
    required String projectGoal,
    required List<PlatformAgent> agents,
  });
}

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return LocalProjectRepository(ref.watch(sharedPreferencesProvider));
});

class ProjectRepositoryException implements Exception {
  const ProjectRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocalProjectRepository implements ProjectRepository {
  LocalProjectRepository(this._prefs);

  static const _projectsKey = 'platform.project_bundles';

  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  @override
  Future<ProjectBundle> createProjectFromGoal({
    required String workspaceId,
    required String createdBy,
    required String projectGoal,
    required List<PlatformAgent> agents,
  }) async {
    final goal = projectGoal.trim();
    if (goal.isEmpty) {
      throw const ProjectRepositoryException('project_goal must not be empty.');
    }

    final bundles = _readBundles();
    final duplicateExists = bundles.any(
      (bundle) =>
          bundle.project.workspaceId == workspaceId &&
          bundle.project.projectGoal.trim().toLowerCase() ==
              goal.toLowerCase() &&
          bundle.project.status != ProjectStatus.archived,
    );
    if (duplicateExists) {
      throw const ProjectRepositoryException(
        'Duplicate task execution blocked for the same project goal.',
      );
    }

    final created = _buildBundle(
      workspaceId: workspaceId,
      createdBy: createdBy,
      goal: goal,
      agents: agents,
    );
    bundles.insert(0, created);
    await _prefs.setString(
      _projectsKey,
      jsonEncode(bundles.map((bundle) => bundle.toJson()).toList()),
    );
    return created;
  }

  @override
  Future<ProjectBundle?> getProject(String projectId) async {
    for (final bundle in _readBundles()) {
      if (bundle.project.id == projectId) {
        return bundle;
      }
    }
    return null;
  }

  @override
  Future<List<ProjectBundle>> listProjects(
      {required String workspaceId}) async {
    final bundles = _readBundles()
        .where((bundle) => bundle.project.workspaceId == workspaceId)
        .toList(growable: false);
    bundles.sort(
      (left, right) =>
          right.project.updatedAt.compareTo(left.project.updatedAt),
    );
    return bundles;
  }

  List<ProjectBundle> _readBundles() {
    final raw = _prefs.getString(_projectsKey);
    if (raw == null || raw.isEmpty) {
      return <ProjectBundle>[];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ProjectBundle.fromJson(item as Map<String, dynamic>))
        .toList(growable: true);
  }

  ProjectBundle _buildBundle({
    required String workspaceId,
    required String createdBy,
    required String goal,
    required List<PlatformAgent> agents,
  }) {
    final now = DateTime.now();
    final projectId = _uuid.v4();
    final conversationId = _uuid.v4();
    final sortedAgents = List<PlatformAgent>.from(agents)
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    final plan = <ExecutionPlanStep>[];
    final tasks = <ProjectTask>[];
    final artifacts = <ProjectArtifact>[];
    final messages = <ExecutionMessage>[
      ExecutionMessage(
        id: _uuid.v4(),
        projectId: projectId,
        conversationId: conversationId,
        role: MessageRole.user,
        content: 'Goal received: $goal',
        createdAt: now,
      ),
    ];
    final toolRuns = <ToolRun>[];

    for (final agent in sortedAgents) {
      final taskId = _uuid.v4();
      final outputType = _primaryOutput(agent.roleName);
      plan.add(
        ExecutionPlanStep(
          order: agent.sortOrder,
          agentKey: agent.key,
          title: _taskTitle(agent.roleName),
          description: _taskDescription(agent.roleName, goal),
          outputType: outputType,
        ),
      );
      tasks.add(
        ProjectTask(
          id: taskId,
          projectId: projectId,
          assignedAgentKey: agent.key,
          taskType: outputType,
          title: _taskTitle(agent.roleName),
          status: TaskStatus.completed,
          dedupeKey: '$projectId-${agent.key}',
          input: {'project_goal': goal},
          output: {'artifact_type': outputType},
          createdAt: now,
          startedAt: now,
          finishedAt: now,
        ),
      );
      messages.add(
        ExecutionMessage(
          id: _uuid.v4(),
          projectId: projectId,
          conversationId: conversationId,
          role: MessageRole.agent,
          content: _taskDescription(agent.roleName, goal),
          createdAt: now,
          agentKey: agent.key,
        ),
      );
      toolRuns.add(
        ToolRun(
          id: _uuid.v4(),
          projectId: projectId,
          taskId: taskId,
          toolName: _toolName(agent.roleName),
          status: ToolRunStatus.completed,
          input: {'project_goal': goal},
          output: {'artifact_type': outputType},
          startedAt: now,
          finishedAt: now,
          agentKey: agent.key,
        ),
      );
      artifacts.addAll(
        _buildArtifacts(
          projectId: projectId,
          taskId: taskId,
          goal: goal,
          agent: agent,
          createdAt: now,
          plan: plan,
        ),
      );
    }

    return ProjectBundle(
      project: Project(
        id: projectId,
        workspaceId: workspaceId,
        createdBy: createdBy,
        title: goal.length > 36 ? '${goal.substring(0, 33)}...' : goal,
        projectGoal: goal,
        status: ProjectStatus.completed,
        executionPlan: plan,
        createdAt: now,
        updatedAt: now,
        lastRunAt: now,
      ),
      tasks: tasks,
      artifacts: artifacts,
      conversation: ExecutionConversation(
        id: conversationId,
        projectId: projectId,
        title: 'Execution log',
        kind: ConversationKind.execution,
        createdAt: now,
        updatedAt: now,
      ),
      messages: messages,
      toolRuns: toolRuns,
    );
  }

  List<ProjectArtifact> _buildArtifacts({
    required String projectId,
    required String taskId,
    required String goal,
    required PlatformAgent agent,
    required DateTime createdAt,
    required List<ExecutionPlanStep> plan,
  }) {
    ProjectArtifact artifact({
      required ArtifactType type,
      required String title,
      required String body,
      ArtifactStatus status = ArtifactStatus.ready,
      String format = 'markdown',
    }) {
      return ProjectArtifact(
        id: _uuid.v4(),
        projectId: projectId,
        taskId: taskId,
        agentKey: agent.key,
        title: title,
        type: type,
        format: format,
        body: body,
        status: status,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
    }

    switch (agent.roleName) {
      case 'orchestrator':
        return [
          artifact(
            type: ArtifactType.executionPlan,
            title: 'Execution Plan',
            body: [
              '# Execution Plan',
              '',
              'Goal: $goal',
              '',
              for (final step in plan)
                '${step.order + 1}. ${step.title} -> ${step.outputType}',
            ].join('\n'),
          ),
        ];
      case 'pm':
        return [
          artifact(
            type: ArtifactType.prd,
            title: 'PRD',
            body: 'PRD for $goal',
          ),
        ];
      case 'system_designer':
        return [
          artifact(
            type: ArtifactType.schema,
            title: 'Schema',
            body: 'Supabase schema for $goal',
            format: 'sql',
          ),
        ];
      case 'flutter':
        return [
          artifact(
            type: ArtifactType.ui,
            title: 'UI',
            body: 'Flutter web-first dashboard for $goal',
          ),
          artifact(
            type: ArtifactType.code,
            title: 'Code',
            body: 'Generated app skeleton for $goal',
            status: ArtifactStatus.partial,
            format: 'dart',
          ),
        ];
      case 'qa':
        return [
          artifact(
            type: ArtifactType.qa,
            title: 'QA',
            body: 'QA checklist for $goal',
          ),
        ];
    }
    return const [];
  }

  String _primaryOutput(String roleName) {
    switch (roleName) {
      case 'orchestrator':
        return 'execution_plan';
      case 'pm':
        return 'prd';
      case 'system_designer':
        return 'schema';
      case 'flutter':
        return 'ui_code';
      case 'qa':
        return 'qa';
    }
    return 'artifact';
  }

  String _taskTitle(String roleName) {
    switch (roleName) {
      case 'orchestrator':
        return 'Plan execution workflow';
      case 'pm':
        return 'Generate PRD and user flow';
      case 'system_designer':
        return 'Design schema and RLS';
      case 'flutter':
        return 'Generate Flutter UI and code';
      case 'qa':
        return 'Validate outputs';
    }
    return 'Run task';
  }

  String _taskDescription(String roleName, String goal) {
    switch (roleName) {
      case 'orchestrator':
        return 'The orchestrator turned "$goal" into an execution pipeline.';
      case 'pm':
        return 'PM scoped features and user flow for "$goal".';
      case 'system_designer':
        return 'System Designer modeled tables, keys, and policies.';
      case 'flutter':
        return 'Flutter Agent created a responsive shell and workflow UI.';
      case 'qa':
        return 'QA validated edge cases and missing paths.';
    }
    return goal;
  }

  String _toolName(String roleName) {
    switch (roleName) {
      case 'orchestrator':
        return 'planner';
      case 'pm':
        return 'prd_generator';
      case 'system_designer':
        return 'schema_designer';
      case 'flutter':
        return 'ui_codegen';
      case 'qa':
        return 'review_runner';
    }
    return 'tool';
  }
}

import 'package:mandarart_journey/features/artifacts/domain/artifact_models.dart';
import 'package:mandarart_journey/features/chat/domain/conversation_models.dart';

enum ProjectStatus {
  draft,
  planning,
  running,
  completed,
  failed,
  archived;

  String toJson() => name;

  static ProjectStatus fromJson(String? value) {
    return ProjectStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ProjectStatus.draft,
    );
  }
}

enum TaskStatus {
  queued,
  running,
  completed,
  failed,
  cancelled;

  String toJson() => name;

  static TaskStatus fromJson(String? value) {
    return TaskStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TaskStatus.queued,
    );
  }
}

class ExecutionPlanStep {
  const ExecutionPlanStep({
    required this.order,
    required this.agentKey,
    required this.title,
    required this.description,
    required this.outputType,
  });

  final int order;
  final String agentKey;
  final String title;
  final String description;
  final String outputType;

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'agentKey': agentKey,
      'title': title,
      'description': description,
      'outputType': outputType,
    };
  }

  factory ExecutionPlanStep.fromJson(Map<String, dynamic> json) {
    return ExecutionPlanStep(
      order: json['order'] as int,
      agentKey: json['agentKey'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      outputType: json['outputType'] as String,
    );
  }
}

class Project {
  const Project({
    required this.id,
    required this.workspaceId,
    required this.createdBy,
    required this.title,
    required this.projectGoal,
    required this.status,
    required this.executionPlan,
    required this.createdAt,
    required this.updatedAt,
    this.lastRunAt,
  });

  final String id;
  final String workspaceId;
  final String createdBy;
  final String title;
  final String projectGoal;
  final ProjectStatus status;
  final List<ExecutionPlanStep> executionPlan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastRunAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'createdBy': createdBy,
      'title': title,
      'projectGoal': projectGoal,
      'status': status.toJson(),
      'executionPlan': executionPlan.map((step) => step.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastRunAt': lastRunAt?.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      createdBy: json['createdBy'] as String,
      title: json['title'] as String,
      projectGoal: json['projectGoal'] as String,
      status: ProjectStatus.fromJson(json['status'] as String?),
      executionPlan: (json['executionPlan'] as List<dynamic>? ?? const [])
          .map((item) =>
              ExecutionPlanStep.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastRunAt: json['lastRunAt'] == null
          ? null
          : DateTime.parse(json['lastRunAt'] as String),
    );
  }
}

class ProjectTask {
  const ProjectTask({
    required this.id,
    required this.projectId,
    required this.assignedAgentKey,
    required this.taskType,
    required this.title,
    required this.status,
    required this.dedupeKey,
    required this.input,
    required this.output,
    required this.createdAt,
    this.errorMessage,
    this.startedAt,
    this.finishedAt,
  });

  final String id;
  final String projectId;
  final String assignedAgentKey;
  final String taskType;
  final String title;
  final TaskStatus status;
  final String dedupeKey;
  final Map<String, dynamic> input;
  final Map<String, dynamic> output;
  final DateTime createdAt;
  final String? errorMessage;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'assignedAgentKey': assignedAgentKey,
      'taskType': taskType,
      'title': title,
      'status': status.toJson(),
      'dedupeKey': dedupeKey,
      'input': input,
      'output': output,
      'createdAt': createdAt.toIso8601String(),
      'errorMessage': errorMessage,
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }

  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    return ProjectTask(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      assignedAgentKey: json['assignedAgentKey'] as String,
      taskType: json['taskType'] as String,
      title: json['title'] as String,
      status: TaskStatus.fromJson(json['status'] as String?),
      dedupeKey: json['dedupeKey'] as String? ?? '',
      input: Map<String, dynamic>.from(json['input'] as Map? ?? const {}),
      output: Map<String, dynamic>.from(json['output'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      errorMessage: json['errorMessage'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      finishedAt: json['finishedAt'] == null
          ? null
          : DateTime.parse(json['finishedAt'] as String),
    );
  }
}

class ProjectBundle {
  const ProjectBundle({
    required this.project,
    required this.tasks,
    required this.artifacts,
    required this.conversation,
    required this.messages,
    required this.toolRuns,
  });

  final Project project;
  final List<ProjectTask> tasks;
  final List<ProjectArtifact> artifacts;
  final ExecutionConversation conversation;
  final List<ExecutionMessage> messages;
  final List<ToolRun> toolRuns;

  int get completedTaskCount =>
      tasks.where((task) => task.status == TaskStatus.completed).length;

  Map<String, dynamic> toJson() {
    return {
      'project': project.toJson(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'artifacts': artifacts.map((artifact) => artifact.toJson()).toList(),
      'conversation': conversation.toJson(),
      'messages': messages.map((message) => message.toJson()).toList(),
      'toolRuns': toolRuns.map((run) => run.toJson()).toList(),
    };
  }

  factory ProjectBundle.fromJson(Map<String, dynamic> json) {
    return ProjectBundle(
      project: Project.fromJson(json['project'] as Map<String, dynamic>),
      tasks: (json['tasks'] as List<dynamic>? ?? const [])
          .map((item) => ProjectTask.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      artifacts: (json['artifacts'] as List<dynamic>? ?? const [])
          .map((item) => ProjectArtifact.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      conversation: ExecutionConversation.fromJson(
          json['conversation'] as Map<String, dynamic>),
      messages: (json['messages'] as List<dynamic>? ?? const [])
          .map(
              (item) => ExecutionMessage.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      toolRuns: (json['toolRuns'] as List<dynamic>? ?? const [])
          .map((item) => ToolRun.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

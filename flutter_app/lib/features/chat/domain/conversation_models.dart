enum ConversationKind {
  execution,
  review,
  recovery;

  String toJson() => name;

  static ConversationKind fromJson(String? value) {
    return ConversationKind.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ConversationKind.execution,
    );
  }
}

enum MessageRole {
  user,
  agent,
  system;

  String toJson() => name;

  static MessageRole fromJson(String? value) {
    return MessageRole.values.firstWhere(
      (item) => item.name == value,
      orElse: () => MessageRole.system,
    );
  }
}

enum ToolRunStatus {
  started,
  completed,
  failed;

  String toJson() => name;

  static ToolRunStatus fromJson(String? value) {
    return ToolRunStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ToolRunStatus.started,
    );
  }
}

class ExecutionConversation {
  const ExecutionConversation({
    required this.id,
    required this.projectId,
    required this.title,
    required this.kind,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String title;
  final ConversationKind kind;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'kind': kind.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExecutionConversation.fromJson(Map<String, dynamic> json) {
    return ExecutionConversation(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      kind: ConversationKind.fromJson(json['kind'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ExecutionMessage {
  const ExecutionMessage({
    required this.id,
    required this.projectId,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.agentKey,
  });

  final String id;
  final String projectId;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final String? agentKey;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'conversationId': conversationId,
      'role': role.toJson(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'agentKey': agentKey,
    };
  }

  factory ExecutionMessage.fromJson(Map<String, dynamic> json) {
    return ExecutionMessage(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      conversationId: json['conversationId'] as String,
      role: MessageRole.fromJson(json['role'] as String?),
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      agentKey: json['agentKey'] as String?,
    );
  }
}

class ToolRun {
  const ToolRun({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.toolName,
    required this.status,
    required this.input,
    required this.output,
    required this.startedAt,
    this.agentKey,
    this.errorMessage,
    this.finishedAt,
  });

  final String id;
  final String projectId;
  final String taskId;
  final String toolName;
  final ToolRunStatus status;
  final Map<String, dynamic> input;
  final Map<String, dynamic> output;
  final DateTime startedAt;
  final String? agentKey;
  final String? errorMessage;
  final DateTime? finishedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'toolName': toolName,
      'status': status.toJson(),
      'input': input,
      'output': output,
      'startedAt': startedAt.toIso8601String(),
      'agentKey': agentKey,
      'errorMessage': errorMessage,
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }

  factory ToolRun.fromJson(Map<String, dynamic> json) {
    return ToolRun(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      taskId: json['taskId'] as String,
      toolName: json['toolName'] as String,
      status: ToolRunStatus.fromJson(json['status'] as String?),
      input: Map<String, dynamic>.from(json['input'] as Map? ?? const {}),
      output: Map<String, dynamic>.from(json['output'] as Map? ?? const {}),
      startedAt: DateTime.parse(json['startedAt'] as String),
      agentKey: json['agentKey'] as String?,
      errorMessage: json['errorMessage'] as String?,
      finishedAt: json['finishedAt'] == null
          ? null
          : DateTime.parse(json['finishedAt'] as String),
    );
  }
}

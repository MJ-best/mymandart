enum ArtifactType {
  executionPlan,
  prd,
  schema,
  ui,
  code,
  qa;

  String toJson() => name;

  static ArtifactType fromJson(String? value) {
    return ArtifactType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ArtifactType.executionPlan,
    );
  }
}

enum ArtifactStatus {
  ready,
  partial,
  failed;

  String toJson() => name;

  static ArtifactStatus fromJson(String? value) {
    return ArtifactStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ArtifactStatus.ready,
    );
  }
}

class ProjectArtifact {
  const ProjectArtifact({
    required this.id,
    required this.projectId,
    required this.title,
    required this.type,
    required this.format,
    required this.body,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.taskId,
    this.agentKey,
  });

  final String id;
  final String projectId;
  final String title;
  final ArtifactType type;
  final String format;
  final String body;
  final ArtifactStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? taskId;
  final String? agentKey;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'type': type.toJson(),
      'format': format,
      'body': body,
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'taskId': taskId,
      'agentKey': agentKey,
    };
  }

  factory ProjectArtifact.fromJson(Map<String, dynamic> json) {
    return ProjectArtifact(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      type: ArtifactType.fromJson(json['type'] as String?),
      format: json['format'] as String? ?? 'markdown',
      body: json['body'] as String? ?? '',
      status: ArtifactStatus.fromJson(json['status'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      taskId: json['taskId'] as String?,
      agentKey: json['agentKey'] as String?,
    );
  }
}

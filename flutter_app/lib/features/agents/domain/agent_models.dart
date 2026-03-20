class PlatformAgent {
  const PlatformAgent({
    required this.key,
    required this.name,
    required this.roleName,
    required this.boundary,
    required this.systemPrompt,
    required this.sortOrder,
    required this.outputTypes,
    required this.skills,
  });

  final String key;
  final String name;
  final String roleName;
  final String boundary;
  final String systemPrompt;
  final int sortOrder;
  final List<String> outputTypes;
  final List<AgentSkill> skills;

  factory PlatformAgent.fromJson(Map<String, dynamic> json) {
    return PlatformAgent(
      key: json['key'] as String,
      name: json['name'] as String,
      roleName: json['roleName'] as String,
      boundary: json['boundary'] as String,
      systemPrompt: json['systemPrompt'] as String,
      sortOrder: json['sortOrder'] as int? ?? 0,
      outputTypes: (json['outputTypes'] as List<dynamic>? ?? const [])
          .map((value) => value as String)
          .toList(growable: false),
      skills: (json['skills'] as List<dynamic>? ?? const [])
          .map((value) => AgentSkill.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class AgentSkill {
  const AgentSkill({
    required this.key,
    required this.label,
    required this.description,
  });

  final String key;
  final String label;
  final String description;

  factory AgentSkill.fromJson(Map<String, dynamic> json) {
    return AgentSkill(
      key: json['key'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
    );
  }
}

class GoalModel {
  final String id;
  final String centralGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GoalModel({
    required this.id,
    required this.centralGoal,
    required this.createdAt,
    required this.updatedAt,
  });
}

class ThemeModel {
  final String id;
  final String goalId;
  final String themeText;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ThemeModel({
    required this.id,
    required this.goalId,
    required this.themeText,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });
}

class ActionItemModel {
  final String id;
  final String themeId;
  final String actionText;
  final bool isCompleted;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ActionItemModel({
    required this.id,
    required this.themeId,
    required this.actionText,
    required this.isCompleted,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  ActionItemModel copyWith({
    String? actionText,
    bool? isCompleted,
  }) {
    return ActionItemModel(
      id: id,
      themeId: themeId,
      actionText: actionText ?? this.actionText,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'themeId': themeId,
      'actionText': actionText,
      'isCompleted': isCompleted,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ActionItemModel.fromJson(Map<String, dynamic> json) {
    return ActionItemModel(
      id: json['id'] as String,
      themeId: json['themeId'] as String,
      actionText: json['actionText'] as String,
      isCompleted: json['isCompleted'] as bool,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class MandalartStateModel {
  final String displayName;
  final String goalText;
  final List<String> themes;
  final List<ActionItemModel> actionItems;
  final int currentStep;
  final bool showViewer;

  const MandalartStateModel({
    required this.displayName,
    required this.goalText,
    required this.themes,
    required this.actionItems,
    required this.currentStep,
    required this.showViewer,
  });

  factory MandalartStateModel.initial() => MandalartStateModel(
        displayName: '',
        goalText: '',
        themes: List.filled(8, ''),
        actionItems: const [],
        currentStep: 0,
        showViewer: false,
      );

  MandalartStateModel copyWith({
    String? displayName,
    String? goalText,
    List<String>? themes,
    List<ActionItemModel>? actionItems,
    int? currentStep,
    bool? showViewer,
  }) {
    return MandalartStateModel(
      displayName: displayName ?? this.displayName,
      goalText: goalText ?? this.goalText,
      themes: themes ?? this.themes,
      actionItems: actionItems ?? this.actionItems,
      currentStep: currentStep ?? this.currentStep,
      showViewer: showViewer ?? this.showViewer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'goalText': goalText,
      'themes': themes,
      'actionItems': actionItems.map((a) => a.toJson()).toList(),
      'currentStep': currentStep,
    };
  }

  factory MandalartStateModel.fromJson(Map<String, dynamic> json) {
    return MandalartStateModel(
      displayName: json['displayName'] as String? ?? '',
      goalText: json['goalText'] as String? ?? '',
      themes: (json['themes'] as List<dynamic>?)?.cast<String>() ?? List.filled(8, ''),
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((item) => ActionItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      currentStep: json['currentStep'] as int? ?? 0,
      showViewer: false,
    );
  }
}

/// 저장된 만다라트의 메타데이터
class SavedMandalartMeta {
  final String id;
  final String displayName;
  final String goalText;
  final int completedCount;
  final int totalCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedMandalartMeta({
    required this.id,
    required this.displayName,
    required this.goalText,
    required this.completedCount,
    required this.totalCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'goalText': goalText,
      'completedCount': completedCount,
      'totalCount': totalCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SavedMandalartMeta.fromJson(Map<String, dynamic> json) {
    return SavedMandalartMeta(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? '',
      goalText: json['goalText'] as String? ?? '',
      completedCount: json['completedCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory SavedMandalartMeta.fromState(String id, MandalartStateModel state, DateTime createdAt) {
    final completed = state.actionItems.where((a) => a.isCompleted).length;
    final total = state.actionItems.where((a) => a.actionText.trim().isNotEmpty).length;
    return SavedMandalartMeta(
      id: id,
      displayName: state.displayName,
      goalText: state.goalText,
      completedCount: completed,
      totalCount: total,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

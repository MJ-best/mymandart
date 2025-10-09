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
}

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

enum GoalPriority {
  high,
  medium,
  low,
  none;

  String toJson() => name;

  static GoalPriority fromJson(String value) {
    return GoalPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GoalPriority.none,
    );
  }
}

class ThemeModel {
  final String id;
  final String goalId;
  final String themeText;
  final int order;
  final GoalPriority priority; // Added priority
  final DateTime createdAt;
  final DateTime updatedAt;

  const ThemeModel({
    required this.id,
    required this.goalId,
    required this.themeText,
    required this.order,
    this.priority = GoalPriority.none, // Default to none
    required this.createdAt,
    required this.updatedAt,
  });
}

enum ActionStatus {
  notStarted,
  inProgress,
  completed;

  String toJson() => name;

  static ActionStatus fromJson(String value) {
    return ActionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActionStatus.notStarted,
    );
  }
}

class ActionItemModel {
  final String id;
  final String themeId;
  final String actionText;
  final ActionStatus status;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const ActionItemModel({
    required this.id,
    required this.themeId,
    required this.actionText,
    required this.status,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
  });

  // 하위 호환성을 위한 getter
  bool get isCompleted => status == ActionStatus.completed;
  bool get isInProgress => status == ActionStatus.inProgress;
  bool get isNotStarted => status == ActionStatus.notStarted;

  ActionItemModel copyWith({
    String? actionText,
    ActionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return ActionItemModel(
      id: id,
      themeId: themeId,
      actionText: actionText ?? this.actionText,
      status: status ?? this.status,
      order: order,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'themeId': themeId,
      'actionText': actionText,
      'status': status.toJson(),
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory ActionItemModel.fromJson(Map<String, dynamic> json) {
    // 하위 호환성: 'isCompleted'가 있으면 status로 변환
    ActionStatus status;
    if (json.containsKey('status')) {
      status = ActionStatus.fromJson(json['status'] as String);
    } else if (json.containsKey('isCompleted')) {
      status = (json['isCompleted'] as bool)
          ? ActionStatus.completed
          : ActionStatus.notStarted;
    } else {
      status = ActionStatus.notStarted;
    }

    return ActionItemModel(
      id: json['id'] as String,
      themeId: json['themeId'] as String,
      actionText: json['actionText'] as String,
      status: status,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

class MandalartStateModel {
  final String displayName;
  final String goalText;
  final List<ThemeModel> themes;
  final List<ActionItemModel> actionItems;
  final int currentStep;
  final bool showViewer;
  final Map<String, int> calendarLog;

  const MandalartStateModel({
    required this.displayName,
    required this.goalText,
    required this.themes,
    required this.actionItems,
    required this.currentStep,
    required this.showViewer,
    required this.calendarLog,
  });

  factory MandalartStateModel.initial() => MandalartStateModel(
        displayName: '',
        goalText: '',
        themes: List.generate(
            8,
            (i) => ThemeModel(
                id: 'placeholder',
                goalId: 'placeholder',
                themeText: '',
                order: i,
                priority: GoalPriority.none,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now())),
        actionItems: const [],
        currentStep: 0,
        showViewer: false,
        calendarLog: const {},
      );

  MandalartStateModel copyWith({
    String? displayName,
    String? goalText,
    List<ThemeModel>? themes,
    List<ActionItemModel>? actionItems,
    int? currentStep,
    bool? showViewer,
    Map<String, int>? calendarLog,
  }) {
    return MandalartStateModel(
      displayName: displayName ?? this.displayName,
      goalText: goalText ?? this.goalText,
      themes: themes ?? this.themes,
      actionItems: actionItems ?? this.actionItems,
      currentStep: currentStep ?? this.currentStep,
      showViewer: showViewer ?? this.showViewer,
      calendarLog: calendarLog ?? this.calendarLog,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'goalText': goalText,
      'themes': themes
          .map((t) => {
                'id': t.id,
                'goalId': t.goalId,
                'themeText': t.themeText,
                'order': t.order,
                'priority': t.priority.toJson(),
                'createdAt': t.createdAt.toIso8601String(),
                'updatedAt': t.updatedAt.toIso8601String(),
              })
          .toList(),
      'actionItems': actionItems.map((a) => a.toJson()).toList(),
      'currentStep': currentStep,
      'calendarLog': calendarLog,
    };
  }

  factory MandalartStateModel.fromJson(Map<String, dynamic> json) {
    List<ThemeModel> themes;
    if (json['themes'] != null) {
      final list = json['themes'] as List;
      if (list.isNotEmpty && list.first is String) {
        // Backward compatibility: Convert string list to ThemeModels
        themes = List.generate(8, (i) {
          final text = i < list.length ? list[i] as String : '';
          return ThemeModel(
            id: 'legacy_$i',
            goalId: 'legacy_goal',
            themeText: text,
            order: i,
            priority: GoalPriority.none,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        });
      } else {
        // Parse ThemeModel objects
        themes = list.map((item) {
          final m = item as Map<String, dynamic>;
          return ThemeModel(
            id: m['id'] as String? ?? 'id',
            goalId: m['goalId'] as String? ?? 'gid',
            themeText: m['themeText'] as String? ?? '',
            order: m['order'] as int? ?? 0,
            priority: m.containsKey('priority')
                ? GoalPriority.fromJson(m['priority'] as String)
                : GoalPriority.none,
            createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
                DateTime.now(),
            updatedAt: DateTime.tryParse(m['updatedAt'] as String? ?? '') ??
                DateTime.now(),
          );
        }).toList();
      }
    } else {
      themes = List.generate(
          8,
          (i) => ThemeModel(
              id: 'placeholder',
              goalId: 'placeholder',
              themeText: '',
              order: i,
              priority: GoalPriority.none,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now()));
    }

    return MandalartStateModel(
      displayName: json['displayName'] as String? ?? '',
      goalText: json['goalText'] as String? ?? '',
      themes: themes,
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((item) =>
                  ActionItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      currentStep: json['currentStep'] as int? ?? 0,
      showViewer: false,
      calendarLog: (json['calendarLog'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          const {},
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

  factory SavedMandalartMeta.fromState(
      String id, MandalartStateModel state, DateTime createdAt) {
    final completed = state.actionItems.where((a) => a.isCompleted).length;
    final total =
        state.actionItems.where((a) => a.actionText.trim().isNotEmpty).length;
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

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mandarart_journey/models/mandalart.dart';

class ExportService {
  static Future<void> exportToJson(MandalartStateModel state) async {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final t in state.themes.where((t) => t.themeText.trim().isNotEmpty)) {
      grouped[t.themeText] = [];
    }
    for (final a in state.actionItems) {
      final themeIndex =
          int.tryParse(a.themeId.replaceFirst('theme-', '')) ?? -1;
      if (themeIndex >= 0 && themeIndex < state.themes.length) {
        final theme = state.themes[themeIndex]; 
        final themeText = theme.themeText;
        if (themeText.trim().isNotEmpty) {
          grouped[themeText]!.add({
            'actionText': a.actionText,
            'status': a.status.toJson(),
          });
        }
      }
    }
    final jsonData = {
      'goal': state.goalText,
      'displayName': state.displayName,
      'themes': grouped.entries
          .map((e) => {
                'themeText': e.key,
                'actionItems': e.value,
              })
          .toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    await Clipboard.setData(ClipboardData(
        text: const JsonEncoder.withIndent('  ').convert(jsonData)));
  }

  /// JSON 형식의 텍스트를 클립보드에서 가져와서 MandalartStateModel로 변환
  static Future<MandalartStateModel?> importFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData == null || clipboardData.text == null) {
        return null;
      }

      return importFromJson(clipboardData.text!);
    } catch (e) {
      return null;
    }
  }

  /// JSON 문자열을 MandalartStateModel로 변환
  static MandalartStateModel? importFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // 목표와 이름 추출
      final goal = data['goal'] as String? ?? '';
      final displayName = data['displayName'] as String? ?? '';

      // 테마와 액션 아이템 추출
      final themes = List<ThemeModel>.generate(8, (i) => ThemeModel(
        id: 'imported_theme_$i',
        goalId: 'imported_goal',
        themeText: '',
        order: i,
        priority: GoalPriority.none,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      final actionItems = <ActionItemModel>[];

      final themesData = data['themes'] as List<dynamic>? ?? [];
      for (var i = 0; i < themesData.length && i < 8; i++) {
        final themeData = themesData[i] as Map<String, dynamic>;
        final themeText = themeData['themeText'] as String? ?? '';
        
        final existing = themes[i];
        themes[i] = ThemeModel(
          id: existing.id,
          goalId: existing.goalId,
          themeText: themeText,
          order: existing.order,
          priority: existing.priority,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now(),
        );

        final actionsData = themeData['actionItems'] as List<dynamic>? ?? [];
        for (var j = 0; j < actionsData.length && j < 8; j++) {
          final actionData = actionsData[j] as Map<String, dynamic>;
          final actionText = actionData['actionText'] as String? ?? '';

          // 상태 파싱 (하위 호환성)
          ActionStatus status;
          if (actionData.containsKey('status')) {
            status = ActionStatus.fromJson(actionData['status'] as String);
          } else if (actionData.containsKey('isCompleted')) {
            status = (actionData['isCompleted'] as bool)
                ? ActionStatus.completed
                : ActionStatus.notStarted;
          } else {
            status = ActionStatus.notStarted;
          }

          if (actionText.trim().isNotEmpty) {
            actionItems.add(ActionItemModel(
              id: 'imported-$i-$j',
              themeId: 'theme-$i',
              actionText: actionText,
              status: status,
              order: j,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
          }
        }
      }

      return MandalartStateModel(
        displayName: displayName,
        goalText: goal,
        themes: themes,
        actionItems: actionItems,
        currentStep: 0,
        showViewer: false,
        calendarLog: const {},
      );
    } catch (e) {
      return null;
    }
  }
}

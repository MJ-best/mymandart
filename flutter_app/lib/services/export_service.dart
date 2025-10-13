import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mandarart_journey/models/mandalart.dart';

class ExportService {
  static Future<void> exportToJson(MandalartStateModel state) async {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final t in state.themes.where((t) => t.trim().isNotEmpty)) {
      grouped[t] = [];
    }
    for (final a in state.actionItems) {
      final themeIndex =
          int.tryParse(a.themeId.replaceFirst('theme-', '')) ?? -1;
      if (themeIndex >= 0 && themeIndex < state.themes.length) {
        final themeText = state.themes[themeIndex];
        if (themeText.trim().isNotEmpty) {
          grouped[themeText]!.add({
            'actionText': a.actionText,
            'isCompleted': a.isCompleted,
          });
        }
      }
    }
    final jsonData = {
      'goal': state.goalText,
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
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Material;
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';

import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/utils/mandalart_grid.dart';
import 'package:mandarart_journey/utils/web_downloader.dart' if (dart.library.io) 'package:mandarart_journey/utils/web_downloader_mobile.dart';

class MandalartViewer extends StatefulWidget {
  final MandalartStateModel state;
  final VoidCallback onClose;
  const MandalartViewer({super.key, required this.state, required this.onClose});

  @override
  State<MandalartViewer> createState() => _MandalartViewerState();
}

class _MandalartViewerState extends State<MandalartViewer> {
  Object currentView = 'full'; // 'full' | int
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final isFull = currentView == 'full';
    final grid = isFull
        ? createMandalartGrid(widget.state)
        : createThemeGrid(widget.state, (currentView as int));

    final completed = widget.state.actionItems.where((a) => a.isCompleted).length;
    final total = widget.state.actionItems.where((a) => a.actionText.trim().isNotEmpty).length;

    return Screenshot(
      controller: _screenshotController,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: CupertinoPageScaffold(
          key: ValueKey(currentView),
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('만다라트 차트'),
          backgroundColor: CupertinoColors.systemBackground,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!kIsWeb)
                Semantics(
                  label: 'Save image to gallery',
                  button: true,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _saveImage();
                    },
                    child: const Icon(CupertinoIcons.photo_on_rectangle),
                  ),
                ),
              if (kIsWeb)
                Semantics(
                  label: 'Download image',
                  button: true,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _downloadImageWeb();
                    },
                    child: const Icon(CupertinoIcons.share),
                  ),
                ),
              Semantics(
                label: 'Export as JSON',
                button: true,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _exportJson();
                  },
                  child: const Icon(CupertinoIcons.doc_text),
                ),
              ),
              Semantics(
                label: 'Close viewer',
                button: true,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onClose();
                  },
                  child: const Icon(CupertinoIcons.xmark),
                ),
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '$completed/$total 액션아이템 완료',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GridView.count(
                          crossAxisCount: isFull ? 9 : 3,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (var r = 0; r < grid.length; r++)
                              for (var c = 0; c < grid[r].length; c++)
                                _Cell(
                                  cell: grid[r][c],
                                  onTap: () {
                                    if (isFull && grid[r][c].type == 'theme') {
                                      HapticFeedback.lightImpact();
                                      // map r,c to theme index (center 3x3 index)
                                      final map = <List<int>>[
                                        [3,3],[3,4],[3,5],
                                        [4,3],      [4,5],
                                        [5,3],[5,4],[5,5],
                                      ];
                                      final idx = map.indexWhere((p) => p[0] == r && p[1] == c);
                                      if (idx != -1) setState(() => currentView = idx);
                                    }
                                  },
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isFull)
                  Semantics(
                    label: 'Return to full view',
                    button: true,
                    child: CupertinoButton.filled(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => currentView = 'full');
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.arrow_left, size: 20),
                          SizedBox(width: 8),
                          Text('전체보기'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _saveImage() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      await Gal.putImageBytes(image);
      if (mounted) {
        HapticFeedback.mediumImpact();
        _showCupertinoAlert('이미지가 갤러리에 저장되었습니다.');
      }
    }
  }

  Future<void> _downloadImageWeb() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      downloadImageWeb(image);
    }
  }

  Future<void> _exportJson() async {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final t in widget.state.themes.where((t) => t.trim().isNotEmpty)) {
      grouped[t] = [];
    }
    for (final a in widget.state.actionItems) {
      final themeIndex = int.tryParse(a.themeId.replaceFirst('theme-', '')) ?? -1;
      if (themeIndex >= 0 && themeIndex < widget.state.themes.length) {
        final themeText = widget.state.themes[themeIndex];
        if (themeText.trim().isNotEmpty) {
          grouped[themeText]!.add({
            'actionText': a.actionText,
            'isCompleted': a.isCompleted,
          });
        }
      }
    }
    final jsonData = {
      'goal': widget.state.goalText,
      'themes': grouped.entries
          .map((e) => {
                'themeText': e.key,
                'actionItems': e.value,
              })
          .toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(jsonData)));
    if (mounted) {
      HapticFeedback.mediumImpact();
      _showCupertinoAlert('JSON이 클립보드에 복사되었습니다.');
    }
  }

  void _showCupertinoAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final GridCell cell;
  final VoidCallback? onTap;
  const _Cell({required this.cell, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg = CupertinoColors.label;
    switch (cell.type) {
      case 'goal':
        bg = CupertinoColors.systemPurple;
        fg = CupertinoColors.white;
        break;
      case 'theme':
        bg = CupertinoColors.systemPurple.withOpacity(0.7);
        fg = CupertinoColors.white;
        break;
      case 'outer-theme':
        bg = CupertinoColors.systemPurple.withOpacity(0.4);
        fg = CupertinoColors.white;
        break;
      case 'action':
        bg = cell.isCompleted ? CupertinoColors.systemPurple.withOpacity(0.6) : CupertinoColors.tertiarySystemFill;
        fg = cell.isCompleted ? CupertinoColors.white : CupertinoColors.label;
        break;
      default:
        bg = CupertinoColors.systemBackground;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(
            color: CupertinoColors.separator.withOpacity(0.3),
          ),
        ),
        child: Text(
          cell.text ?? '',
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: fg,
            fontSize: 11,
            fontWeight: cell.type == 'goal' ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
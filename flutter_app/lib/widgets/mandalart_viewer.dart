import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/utils/mandalart_grid.dart';
import 'package:mandarart_journey/data/keywords.dart';
import 'package:mandarart_journey/services/export_service.dart';
import 'package:mandarart_journey/services/image_service.dart';
import 'package:mandarart_journey/widgets/viewer/grid_cell.dart';

class MandalartViewer extends StatefulWidget {
  final MandalartStateModel state;
  final VoidCallback onClose;
  final void Function(int themeIndex, int actionIndex, bool completed)
      onToggleAction;
  const MandalartViewer({
    super.key,
    required this.state,
    required this.onClose,
    required this.onToggleAction,
  });

  @override
  State<MandalartViewer> createState() => _MandalartViewerState();
}

class _MandalartViewerState extends State<MandalartViewer> {
  Object currentView = 'full'; // 'full' | int
  final ScreenshotController _screenshotController = ScreenshotController();
  late Map<String, String> _randomQuote;

  @override
  void initState() {
    super.initState();
    // 랜덤 명언 선택
    final random = Random();
    _randomQuote = Keywords
        .motivationalQuotes[random.nextInt(Keywords.motivationalQuotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    final isFull = currentView == 'full';
    final grid = isFull
        ? createMandalartGrid(widget.state)
        : createThemeGrid(widget.state, (currentView as int));

    final completed =
        widget.state.actionItems.where((a) => a.isCompleted).length;
    final total = widget.state.actionItems
        .where((a) => a.actionText.trim().isNotEmpty)
        .length;

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
            middle: Text(
              widget.state.displayName.trim().isNotEmpty
                  ? widget.state.displayName.trim()
                  : '만다라트 차트',
            ),
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
                        _showWallpaperOptions(isDownload: false);
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
                        _showWallpaperOptions(isDownload: true);
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.state.displayName.trim().isNotEmpty
                        ? widget.state.displayName.trim()
                        : '나만의 만다라트',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.state.goalText.trim().isNotEmpty) ...[
                    Text(
                      widget.state.goalText.trim(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    '$completed/$total 액션아이템 완료',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '만다라트 차트',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.black
                                    .withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 5.0,
                              panEnabled: true,
                              scaleEnabled: true,
                              boundaryMargin: const EdgeInsets.all(20),
                              child: GridView.count(
                                crossAxisCount: isFull ? 9 : 3,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  for (var r = 0; r < grid.length; r++)
                                    for (var c = 0; c < grid[r].length; c++)
                                      () {
                                        final cell = grid[r][c];
                                        VoidCallback? handler;

                                        if (isFull) {
                                          if ((cell.type == 'theme' ||
                                                  cell.type == 'outer-theme') &&
                                              cell.themeIndex != null) {
                                            handler = () {
                                              HapticFeedback.lightImpact();
                                              setState(() => currentView =
                                                  cell.themeIndex!);
                                            };
                                          } else if (cell.type == 'action' &&
                                              cell.themeIndex != null) {
                                            handler = () {
                                              HapticFeedback.lightImpact();
                                              setState(() => currentView =
                                                  cell.themeIndex!);
                                            };
                                          }
                                        } else if (cell.type == 'action' &&
                                            cell.themeIndex != null &&
                                            cell.actionIndex != null) {
                                          handler = () {
                                            HapticFeedback.lightImpact();
                                            widget.onToggleAction(
                                              cell.themeIndex!,
                                              cell.actionIndex!,
                                              !cell.isCompleted,
                                            );
                                          };
                                        }

                                        return GridCellWidget(
                                          cell: cell,
                                          onTap: handler,
                                        );
                                      }(),
                                ],
                              ),
                            ),
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
                  const SizedBox(height: 24),
                  const Text(
                    '목표달성을 위한 조언',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 동기부여 명언
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          CupertinoIcons.quote_bubble,
                          color: CupertinoColors.systemPurple,
                          size: 24,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _randomQuote['quote']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.label,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '- ${_randomQuote['author']} -',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.systemPurple,
                          ),
                        ),
                      ],
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

  void _showWallpaperOptions({required bool isDownload}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(isDownload ? '다운로드 크기 선택' : '저장 크기 선택'),
        actions: [
          for (final preset in WallpaperPreset.values)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                Future.microtask(
                    () => _handleWallpaperExport(preset, isDownload));
              },
              child: Text(ImageService.getPresetLabel(preset)),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: const Text('취소'),
        ),
      ),
    );
  }

  Future<void> _handleWallpaperExport(
    WallpaperPreset preset,
    bool isDownload,
  ) async {
    try {
      final image = await ImageService.captureWithPreset(_screenshotController, preset);
      if (image == null) {
        if (mounted) {
          _showCupertinoAlert('이미지 캡처에 실패했습니다. 다시 시도해주세요.');
        }
        return;
      }

      if (isDownload) {
        if (kIsWeb) {
          ImageService.downloadWeb(image, ImageService.getFileNameForPreset(preset));
          if (mounted) {
            _showCupertinoAlert('이미지 다운로드가 시작되었습니다.');
          }
        }
        return;
      }

      await ImageService.saveToGallery(image);
      if (mounted) {
        HapticFeedback.mediumImpact();
        _showCupertinoAlert('${ImageService.getPresetLabel(preset)} 이미지가 갤러리에 저장되었습니다.');
      }
    } catch (error) {
      if (mounted) {
        _showCupertinoAlert('이미지 저장 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
    }
  }

  Future<void> _exportJson() async {
    await ExportService.exportToJson(widget.state);
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

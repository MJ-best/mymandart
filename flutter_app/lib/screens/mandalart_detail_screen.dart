import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';

import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/data/keywords.dart';
import 'package:mandarart_journey/services/export_service.dart';
import 'package:mandarart_journey/services/image_service.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/widgets/viewer/a4_mandalart_layout.dart';
import 'package:mandarart_journey/widgets/streak_widget.dart';
import 'package:mandarart_journey/widgets/goal_input_dialog.dart';

class MandalartDetailScreen extends ConsumerStatefulWidget {
  const MandalartDetailScreen({super.key});

  @override
  ConsumerState<MandalartDetailScreen> createState() => _MandalartDetailScreenState();
}

class _MandalartDetailScreenState extends ConsumerState<MandalartDetailScreen> {
  Object currentView = 'full'; // 'full' | int
  final ScreenshotController _screenshotController = ScreenshotController();
  late Map<String, String> _randomQuote;
  bool _isTodoExpanded = false;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _randomQuote = Keywords.motivationalQuotes[random.nextInt(Keywords.motivationalQuotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mandalartProvider);
    final notifier = ref.read(mandalartProvider.notifier);

    final body = SafeArea(
      child: _buildPortraitLayout(),
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.go('/'),
        ),
        middle: Text(state.displayName.isNotEmpty ? state.displayName : '만다라트 상세'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.ellipsis),
          onPressed: _showActionMenu,
        ),
      ),
      child: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
          child: body,
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    final state = ref.watch(mandalartProvider);
    final primaryColor = ref.watch(themeProvider).primaryColor;
    final isFull = currentView == 'full';

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildA4ViewerWithZoom(),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!isFull)
                    CupertinoButton.filled(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => currentView = 'full');
                        ref.read(activeThemeIndexProvider.notifier).state = null;
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
                  if (!isFull) const SizedBox(height: 12),
                  const StreakWidget(),
                  const SizedBox(height: 12),
                  _buildTodoListPreview(),
                   const SizedBox(height: 12),
                  CupertinoButton(
                    onPressed: () => context.push('/edit'),
                     child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       Icon(CupertinoIcons.pencil),
                       SizedBox(width: 8),
                       Text('목표 편집하기'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildA4ViewerWithZoom() {
    final state = ref.watch(mandalartProvider);
    final notifier = ref.read(mandalartProvider.notifier);

    return Container(
      color: CupertinoColors.systemGrey6.resolveFrom(context),
      child: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
          boundaryMargin: const EdgeInsets.all(10),
          child: A4MandalartLayout(
            state: state,
            currentView: currentView,
            onThemeClick: (themeIndex) {
              HapticFeedback.lightImpact();
              setState(() => currentView = themeIndex);
              ref.read(activeThemeIndexProvider.notifier).state = themeIndex;
            },
            onToggleAction: (themeIndex, actionIndex) {
              notifier.toggleActionStatus(
                  themeIndex: themeIndex, actionIndex: actionIndex);
            },
            forScreenshot: false,
            randomQuote: _randomQuote,
          ),
        ),
      ),
    );
  }

  Widget _buildTodoListPreview() {
    final state = ref.watch(mandalartProvider);
    final notifier = ref.read(mandalartProvider.notifier);
    final primaryColor = ref.watch(themeProvider).primaryColor;
    final incompleteActions = state.actionItems
        .where((action) => !action.isCompleted && action.actionText.trim().isNotEmpty)
        .toList();

    if (incompleteActions.isEmpty) {
      return Container(
          // ... (All goals completed view)
          );
    }

    final displayCount = _isTodoExpanded ? incompleteActions.length : 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Header)
          ...incompleteActions.take(displayCount).map((action) {
            final themeIndex = int.parse(action.themeId.split('-').last);
            return GestureDetector(
              onTap: () {
                notifier.toggleActionStatus(
                    themeIndex: themeIndex, actionIndex: action.order);
              },
              child: Container(
                  // ... (List item UI)
                  ),
            );
          }),
          if (incompleteActions.length > 3)
            CupertinoButton(
              onPressed: () => setState(() => _isTodoExpanded = !_isTodoExpanded),
              child: Text(_isTodoExpanded ? '접기' : '더 보기...'),
            ),
        ],
      ),
    );
  }

  void _showActionMenu() {
     showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              context.push('/edit');
            },
            child: const Text('편집하기'),
          ),
           CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showJsonOptions();
            },
            child: const Text('JSON 내보내기/가져오기'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
               Navigator.pop(context);
              _showWallpaperOptions(isDownload: false);
            },
            child: const Text('이미지로 저장'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ),
    );
  }

  void _showJsonOptions() {
    final notifier = ref.read(mandalartProvider.notifier);
    final state = ref.read(mandalartProvider);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('JSON 데이터 관리'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await ExportService.exportToJson(state);
               if (mounted) {
                _showCupertinoAlert('JSON이 클립보드에 복사되었습니다.');
               }
            },
            child: const Text('JSON 내보내기'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final importedState = await ExportService.importFromClipboard();
              if (importedState != null) {
                await notifier.importFromState(importedState);
                 if (mounted) {
                  _showCupertinoAlert('JSON 데이터를 성공적으로 불러왔습니다.');
                 }
              } else {
                 if (mounted) {
                  _showCupertinoAlert('클립보드에서 유효한 데이터를 찾지 못했습니다.');
                 }
              }
            },
            child: const Text('JSON 가져오기'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ),
    );
  }

  void _showWallpaperOptions({required bool isDownload}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(isDownload ? '다운로드 컨텐츠 선택' : '저장 컨텐츠 선택'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _handleWallpaperExport(WallpaperPreset.mobile, isDownload, false);
            },
            child: const Text('전체 화면 (모바일)'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ),
    );
  }

  Future<void> _handleWallpaperExport(WallpaperPreset preset, bool isDownload, bool isA4Only) async {
    // Simplified version
    try {
      final image = await ImageService.captureWithPreset(_screenshotController, preset);
      if (image != null) {
        if (isDownload && kIsWeb) {
          ImageService.downloadWeb(image, 'mandalart.png');
        } else if (!isDownload) {
          await ImageService.saveToGallery(image);
           if (mounted) {
            _showCupertinoAlert('이미지가 갤러리에 저장되었습니다.');
           }
        }
      }
    } catch (e) {
       if (mounted) {
        _showCupertinoAlert('이미지 저장 중 오류가 발생했습니다.');
       }
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

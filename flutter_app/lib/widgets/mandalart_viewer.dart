import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';

import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/data/keywords.dart';
import 'package:mandarart_journey/services/export_service.dart';
import 'package:mandarart_journey/services/image_service.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/widgets/viewer/a4_mandalart_layout.dart';

class MandalartViewer extends ConsumerStatefulWidget {
  final MandalartStateModel state;
  final VoidCallback onClose;
  final VoidCallback? onNavigateToActions;
  final void Function(int themeIndex, int actionIndex, bool completed)
      onToggleAction;
  const MandalartViewer({
    super.key,
    required this.state,
    required this.onClose,
    this.onNavigateToActions,
    required this.onToggleAction,
  });

  @override
  ConsumerState<MandalartViewer> createState() => _MandalartViewerState();
}

class _MandalartViewerState extends ConsumerState<MandalartViewer> {
  Object currentView = 'full'; // 'full' | int
  final ScreenshotController _screenshotController = ScreenshotController();
  final ScreenshotController _a4ScreenshotController = ScreenshotController();
  late Map<String, String> _randomQuote;
  bool _isTodoExpanded = false;

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
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Screenshot(
      controller: _screenshotController,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: CupertinoPageScaffold(
          key: ValueKey(currentView),
          backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              widget.state.displayName.trim().isNotEmpty
                  ? widget.state.displayName.trim()
                  : '만다라트 차트',
            ),
            backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 저장 버튼
                Semantics(
                  label: 'Save mandalart',
                  button: true,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _saveMandalart();
                    },
                    child: const Icon(CupertinoIcons.floppy_disk),
                  ),
                ),
                _buildThemeToggleButton(),
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
            child: isLandscape
                ? _buildLandscapeLayout()
                : _buildPortraitLayout(),
          ),
        ),
      ),
    );
  }

  /// 세로 모드 레이아웃
  Widget _buildPortraitLayout() {
    final isFull = currentView == 'full';

    return Column(
      children: [
        // 2/3: A4 만다라트 뷰어 (확대/축소 가능)
        Expanded(
          flex: 2,
          child: _buildA4ViewerWithZoom(),
        ),

        // 1/3: 하단 정보 영역 (TODO + 명언)
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                  if (!isFull) const SizedBox(height: 12),
                  // TODO 리스트 미리보기 (확장 시 명언이 아래로 밀림)
                  _buildTodoListPreview(),
                  const SizedBox(height: 12),
                  // 명언 (더보기 확장 시 스크롤로 가려짐)
                  _buildMotivationalQuote(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 가로 모드 레이아웃
  Widget _buildLandscapeLayout() {
    final isFull = currentView == 'full';

    return Row(
      children: [
        // 왼쪽: A4 만다라트 뷰어
        Expanded(
          flex: 3,
          child: _buildA4ViewerWithZoom(),
        ),

        // 오른쪽: TODO 리스트, 정보와 버튼
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const SizedBox(height: 20),
                // TODO 리스트 추가
                _buildTodoList(),
                const SizedBox(height: 20),
                _buildMotivationalQuote(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// A4 크기 레이아웃을 화면에 맞게 축소하여 표시
  Widget _buildA4ViewerWithZoom() {
    return Container(
      color: CupertinoColors.systemGrey6.resolveFrom(context),
      child: Stack(
        children: [
          // 화면에 표시되는 위젯 (다크모드 적용)
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              panEnabled: true,
              scaleEnabled: true,
              boundaryMargin: const EdgeInsets.all(40),
              child: A4MandalartLayout(
                state: widget.state,
                currentView: currentView,
                onThemeClick: (themeIndex) {
                  HapticFeedback.lightImpact();
                  setState(() => currentView = themeIndex);
                },
                onToggleAction: (themeIndex, actionIndex, completed) {
                  HapticFeedback.lightImpact();
                  widget.onToggleAction(themeIndex, actionIndex, completed);
                },
                forScreenshot: false, // 화면에는 다크모드 적용
              ),
            ),
          ),
          // 스크린샷용 위젯 (항상 밝은 배경, 화면에는 숨김)
          Offstage(
            child: Screenshot(
              controller: _a4ScreenshotController,
              child: A4MandalartLayout(
                state: widget.state,
                currentView: currentView,
                onThemeClick: (themeIndex) {},
                onToggleAction: (themeIndex, actionIndex, completed) {},
                forScreenshot: true, // 스크린샷은 밝은 배경
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 세로모드용 TODO 리스트 미리보기 위젯 (3개 + 확장 가능)
  Widget _buildTodoListPreview() {
    final incompleteActions = widget.state.actionItems
        .where((action) => !action.isCompleted && action.actionText.trim().isNotEmpty)
        .toList();

    if (incompleteActions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.systemGreen.withOpacity(0.3),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: CupertinoColors.systemGreen,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              '모든 할 일 완료!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGreen,
              ),
            ),
          ],
        ),
      );
    }

    // 확장 여부에 따라 표시할 개수 결정
    final displayCount = _isTodoExpanded
        ? (incompleteActions.length > 10 ? 10 : incompleteActions.length)
        : (incompleteActions.length > 3 ? 3 : incompleteActions.length);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemPurple.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.list_bullet,
                color: CupertinoColors.systemPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                incompleteActions.length <= 3
                    ? '오늘 집중할 ${incompleteActions.length}가지'
                    : '오늘 집중할 3가지',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...incompleteActions.take(displayCount).map((action) {
            final themeIndex = _getThemeIndexForAction(action);
            final actionIndex = _getActionIndexForTheme(action, themeIndex);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onToggleAction(themeIndex, actionIndex, true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground.resolveFrom(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CupertinoColors.separator.resolveFrom(context),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.circle,
                        size: 18,
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          action.actionText,
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // 더 보기 / 접기 버튼
          if (incompleteActions.length > 3)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _isTodoExpanded = !_isTodoExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isTodoExpanded
                        ? '접기'
                        : '더 보기 (${incompleteActions.length - 3}개 더)',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isTodoExpanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    color: CupertinoColors.systemPurple,
                    size: 14,
                  ),
                ],
              ),
            ),
          if (_isTodoExpanded && incompleteActions.length > 10) ...[
            const SizedBox(height: 4),
            Text(
              '외 ${incompleteActions.length - 10}개 더...',
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// TODO 리스트 위젯
  Widget _buildTodoList() {
    final incompleteActions = widget.state.actionItems
        .where((action) => !action.isCompleted && action.actionText.trim().isNotEmpty)
        .toList();

    if (incompleteActions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.systemGreen.withOpacity(0.3),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: CupertinoColors.systemGreen,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              '모든 할 일 완료!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGreen,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemPurple.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.list_bullet,
                color: CupertinoColors.systemPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘 집중할 일 (${incompleteActions.length > 10 ? 10 : incompleteActions.length}개)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...incompleteActions.take(10).map((action) {
            final themeIndex = _getThemeIndexForAction(action);
            final actionIndex = _getActionIndexForTheme(action, themeIndex);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onToggleAction(themeIndex, actionIndex, true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground.resolveFrom(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CupertinoColors.separator.resolveFrom(context),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.circle,
                        size: 18,
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          action.actionText,
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (incompleteActions.length > 10) ...[
            const SizedBox(height: 4),
            Text(
              '외 ${incompleteActions.length - 10}개 더...',
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 액션 아이템의 테마 인덱스 가져오기
  int _getThemeIndexForAction(ActionItemModel action) {
    // themeId를 기반으로 테마 인덱스 찾기
    for (int i = 0; i < widget.state.actionItems.length; i++) {
      if (widget.state.actionItems[i].id == action.id) {
        return i ~/ 8; // 각 테마당 8개의 액션 아이템
      }
    }
    return 0;
  }

  /// 테마 내에서 액션 아이템의 인덱스 가져오기
  int _getActionIndexForTheme(ActionItemModel action, int themeIndex) {
    final themeActions = widget.state.actionItems
        .where((a) => a.themeId == action.themeId)
        .toList();

    for (int i = 0; i < themeActions.length; i++) {
      if (themeActions[i].id == action.id) {
        return i;
      }
    }
    return 0;
  }

  /// 동기부여 명언 위젯
  Widget _buildMotivationalQuote() {
    return Container(
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label.resolveFrom(context),
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
    );
  }

  void _showWallpaperOptions({required bool isDownload}) {
    // 먼저 컨텐츠 타입 선택
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(isDownload ? '다운로드 컨텐츠 선택' : '저장 컨텐츠 선택'),
        message: const Text('어떤 내용을 저장하시겠습니까?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Future.microtask(() => _showSizeOptions(
                    isDownload: isDownload,
                    isA4Only: true,
                  ));
            },
            child: const Text('만다라트만'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Future.microtask(() => _showSizeOptions(
                    isDownload: isDownload,
                    isA4Only: false,
                  ));
            },
            child: const Text('전체 화면 (명언 포함)'),
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

  void _showSizeOptions({
    required bool isDownload,
    required bool isA4Only,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(isDownload ? '다운로드 크기 선택' : '저장 크기 선택'),
        actions: [
          for (final preset in WallpaperPreset.values)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                Future.microtask(() => _handleWallpaperExport(
                      preset,
                      isDownload,
                      isA4Only,
                    ));
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
    bool isA4Only,
  ) async {
    try {
      // A4만 저장할지 전체 화면을 저장할지에 따라 다른 controller 사용
      final controller = isA4Only ? _a4ScreenshotController : _screenshotController;
      final contentType = isA4Only ? '만다라트' : '전체 화면';

      final image = await ImageService.captureWithPreset(controller, preset);
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
            _showCupertinoAlert('$contentType 이미지 다운로드가 시작되었습니다.');
          }
        }
        return;
      }

      await ImageService.saveToGallery(image);
      if (mounted) {
        HapticFeedback.mediumImpact();
        _showCupertinoAlert('$contentType ${ImageService.getPresetLabel(preset)} 이미지가 갤러리에 저장되었습니다.');
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

  Widget _buildThemeToggleButton() {
    final themeState = ref.watch(themeProvider);
    final bool isLight = themeState.mode == ThemeMode.light;
    final IconData icon = isLight ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill;
    final String label = isLight ? 'Light mode' : 'Dark mode';

    return Semantics(
      label: 'Toggle theme: $label',
      button: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          HapticFeedback.lightImpact();
          ref.read(themeProvider.notifier).toggleTheme();
        },
        child: Icon(
          icon,
          color: CupertinoColors.systemPurple,
          size: 24,
        ),
      ),
    );
  }

  Future<void> _saveMandalart() async {
    try {
      await ref.read(mandalartProvider.notifier).saveCurrentMandalart();
      if (mounted) {
        HapticFeedback.mediumImpact();
        _showCupertinoAlert('만다라트가 저장되었습니다.');
      }
    } catch (error) {
      if (mounted) {
        _showCupertinoAlert('저장 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
    }
  }
}

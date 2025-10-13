import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/data/keywords.dart';
import 'package:mandarart_journey/services/export_service.dart';
import 'package:mandarart_journey/services/image_service.dart';
import 'package:mandarart_journey/widgets/viewer/a4_mandalart_layout.dart';

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
  final ScreenshotController _a4ScreenshotController = ScreenshotController();
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
        // A4 만다라트 뷰어 (확대/축소 가능)
        Expanded(
          child: _buildA4ViewerWithZoom(),
        ),

        // 하단 정보와 버튼
        Padding(
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
              const SizedBox(height: 12),
              _buildMotivationalQuote(),
            ],
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

        // 오른쪽: 정보와 버튼
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
      color: CupertinoColors.systemGrey6,
      child: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
          boundaryMargin: const EdgeInsets.all(40),
          child: Screenshot(
            controller: _a4ScreenshotController,
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
            ),
          ),
        ),
      ),
    );
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
}

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

class MandalartViewer extends ConsumerStatefulWidget {
  final MandalartStateModel state;
  final VoidCallback onClose;
  final VoidCallback? onNavigateToActions;
  final VoidCallback? onShowHelp;
  final void Function(int themeIndex, int actionIndex) onToggleAction;
  final bool withScaffold;
  const MandalartViewer({
    super.key,
    required this.state,
    required this.onClose,
    this.onNavigateToActions,
    this.onShowHelp,
    required this.onToggleAction,
    this.withScaffold = true,
  });

  @override
  ConsumerState<MandalartViewer> createState() => _MandalartViewerState();
}

class _MandalartViewerState extends ConsumerState<MandalartViewer> {
  Object currentView = 'full'; // 'full' | int
  final ScreenshotController _screenshotController = ScreenshotController();
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

    final body = SafeArea(
      child: isLandscape
          ? _buildLandscapeLayout()
          : _buildPortraitLayout(),
    );

    if (!widget.withScaffold) {
      // PageView 안에서 사용할 때: scaffold 없이 body만 렌더링
      return Screenshot(
        controller: _screenshotController,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: Container(
            key: ValueKey(currentView),
            color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
            child: body,
          ),
        ),
      );
    }

    // 독립 페이지로 사용할 때: scaffold 포함
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
                      _showJsonOptions();
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
          child: body,
        ),
      ),
    );
  }

  /// 세로 모드 레이아웃
  Widget _buildPortraitLayout() {
    final isFull = currentView == 'full';

    return Column(
      children: [
        // withScaffold가 false일 때 상단에 버튼 행 추가
        if (!widget.withScaffold) _buildActionButtons(),

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
                  // 꾸준점수 (출석체크)
                  const StreakWidget(),
                  const SizedBox(height: 12),
                  // TODO 리스트 미리보기 (확장 시 명언이 아래로 밀림)
                  _buildTodoListPreview(),
                  const SizedBox(height: 12),
                  // 명언 (더보기 확장 시 스크롤로 가려짐)
                  _buildMotivationalQuote(),
                  // withScaffold가 false일 때만 도움말 버튼 표시
                  if (!widget.withScaffold && widget.onShowHelp != null) ...[
                    const SizedBox(height: 12),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: widget.onShowHelp,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.question_circle,
                            color: CupertinoColors.systemPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '도움말',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.label.resolveFrom(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

    return Column(
      children: [
        // withScaffold가 false일 때 상단에 버튼 행 추가
        if (!widget.withScaffold) _buildActionButtons(),

        Expanded(
          child: Row(
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
                      // 꾸준점수 (출석체크)
                      const StreakWidget(),
                      const SizedBox(height: 20),
                      // TODO 리스트 추가
                      _buildTodoList(),
                      const SizedBox(height: 20),
                      _buildMotivationalQuote(),
                      // withScaffold가 false일 때만 도움말 버튼 표시
                      if (!widget.withScaffold && widget.onShowHelp != null) ...[
                        const SizedBox(height: 20),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onPressed: widget.onShowHelp,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.question_circle,
                                color: CupertinoColors.systemPurple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '도움말',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.label.resolveFrom(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A4 크기 레이아웃을 화면에 맞게 축소하여 표시
  Widget _buildA4ViewerWithZoom() {
    return Container(
      color: CupertinoColors.systemGrey6.resolveFrom(context),
      child: Center(
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
            onToggleAction: (themeIndex, actionIndex) {
              HapticFeedback.lightImpact();
              widget.onToggleAction(themeIndex, actionIndex);
            },
            forScreenshot: false, // 화면에는 다크모드 적용
          ),
        ),
      ),
    );
  }

  /// A4 레이아웃을 스크린샷용으로 생성
  Widget _buildA4ForScreenshot() {
    return A4MandalartLayout(
      state: widget.state,
      currentView: currentView,
      onThemeClick: (themeIndex) {},
      onToggleAction: (themeIndex, actionIndex) {},
      forScreenshot: true, // 스크린샷은 밝은 배경
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
                  widget.onToggleAction(themeIndex, actionIndex);
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
                  widget.onToggleAction(themeIndex, actionIndex);
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
    final parts = action.themeId.split('-');
    if (parts.length >= 2) {
      final parsed = int.tryParse(parts.last);
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  /// 테마 내에서 액션 아이템의 인덱스 가져오기
  int _getActionIndexForTheme(ActionItemModel action, int themeIndex) {
    return action.order.clamp(0, 7);
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

  /// withScaffold가 false일 때 표시할 액션 버튼들
  Widget _buildActionButtons() {
    final mediaQuery = MediaQuery.of(context);
    final isPhone = mediaQuery.size.width < 600;
    final iconSize = isPhone ? 20.0 : 24.0;
    final spacing = isPhone ? 4.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isPhone ? 8 : 16, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
              child: Icon(
                CupertinoIcons.floppy_disk,
                size: iconSize,
              ),
            ),
          ),
          SizedBox(width: spacing),
          // 다크모드 토글
          _buildThemeToggleButton(),
          SizedBox(width: spacing),
          // 이미지 저장/다운로드 버튼
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
                child: Icon(
                  CupertinoIcons.photo_on_rectangle,
                  size: iconSize,
                ),
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
                child: Icon(
                  CupertinoIcons.share,
                  size: iconSize,
                ),
              ),
            ),
          if (!kIsWeb) SizedBox(width: spacing),
          // JSON 내보내기/불러오기 버튼
          Semantics(
            label: 'Export or import JSON',
            button: true,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.lightImpact();
                _showJsonOptions();
              },
              child: Icon(
                CupertinoIcons.doc_text,
                size: iconSize,
              ),
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
      Uint8List? image;
      final contentType = isA4Only ? '만다라트' : '전체 화면';

      if (isA4Only) {
        // A4만 저장하는 경우 동적으로 위젯 생성하여 캡처
        final tempController = ScreenshotController();
        final a4Widget = RepaintBoundary(
          child: _buildA4ForScreenshot(),
        );

        // 위젯을 오버레이에 추가하여 렌더링
        final overlay = Overlay.of(context);
        late OverlayEntry entry;
        entry = OverlayEntry(
          builder: (context) => Positioned(
            left: -10000,
            top: 0,
            child: Screenshot(
              controller: tempController,
              child: a4Widget,
            ),
          ),
        );

        overlay.insert(entry);

        // 렌더링이 완료될 때까지 대기
        await Future.delayed(const Duration(milliseconds: 100));

        image = await ImageService.captureWithPreset(tempController, preset);

        // 오버레이 제거
        entry.remove();
      } else {
        // 전체 화면 저장
        image = await ImageService.captureWithPreset(_screenshotController, preset);
      }

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

  void _showJsonOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('JSON 데이터 관리'),
        message: const Text('JSON 형식으로 내보내거나 가져올 수 있습니다'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Future.microtask(() => _exportJson());
            },
            child: const Text('JSON 내보내기 (클립보드 복사)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Future.microtask(() => _importJson());
            },
            child: const Text('JSON 불러오기 (클립보드에서)'),
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

  Future<void> _exportJson() async {
    await ExportService.exportToJson(widget.state);
    if (mounted) {
      HapticFeedback.mediumImpact();
      _showCupertinoAlert('JSON이 클립보드에 복사되었습니다.');
    }
  }

  Future<void> _importJson() async {
    final importedState = await ExportService.importFromClipboard();
    if (importedState == null) {
      if (mounted) {
        _showCupertinoAlert('클립보드에서 유효한 JSON 데이터를 찾을 수 없습니다.');
      }
      return;
    }

    if (mounted) {
      // 확인 다이얼로그 표시
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('JSON 불러오기'),
          content: const Text('현재 작업 중인 만다라트를 불러온 데이터로 교체하시겠습니까?\n현재 데이터는 저장되지 않습니다.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await ref.read(mandalartProvider.notifier).importFromState(importedState);
                if (mounted) {
                  HapticFeedback.mediumImpact();
                  if (success) {
                    _showCupertinoAlert('JSON 데이터를 성공적으로 불러왔습니다.');
                  } else {
                    _showCupertinoAlert('JSON 데이터를 불러오는 중 오류가 발생했습니다.');
                  }
                }
              },
              child: const Text('불러오기'),
            ),
          ],
        ),
      );
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
        // 저장 후 저장된 만다라트 페이지로 이동
        widget.onClose(); // 먼저 뷰어 닫기
        context.push('/saved-mandalarts');
      }
    } catch (error) {
      if (mounted) {
        _showCupertinoAlert('저장 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
    }
  }
}

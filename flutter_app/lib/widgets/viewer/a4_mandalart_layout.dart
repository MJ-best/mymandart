import 'package:flutter/cupertino.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/utils/mandalart_grid.dart';
import 'package:mandarart_journey/widgets/viewer/grid_cell.dart';

/// A4 용지 크기에 최적화된 만다라트 레이아웃
/// A4 비율: 210mm x 297mm (약 0.707 또는 1:√2)
/// 인쇄를 위해 고정된 크기로 디자인
class A4MandalartLayout extends StatelessWidget {
  final MandalartStateModel state;
  final Object currentView;
  final void Function(int themeIndex) onThemeClick;
  final void Function(int themeIndex, int actionIndex) onToggleAction;
  final bool forScreenshot;
  final Map<String, String>? randomQuote;

  const A4MandalartLayout({
    super.key,
    required this.state,
    required this.currentView,
    required this.onThemeClick,
    required this.onToggleAction,
    this.forScreenshot = false,
    this.randomQuote,
  });

  // A4 용지 비율을 유지하면서 적절한 크기로 조정
  // 실제 A4: 210mm x 297mm (비율 ~0.707)
  // 렌더링 가능한 크기로 축소
  static const double a4Width = 800.0;  // 적절한 렌더링 크기
  static const double a4Height = 1131.0; // A4 비율 유지 (800 / 0.707)
  static const double a4Ratio = a4Width / a4Height; // ~0.707

  @override
  Widget build(BuildContext context) {
    final isFull = currentView == 'full';
    final grid = isFull
        ? createMandalartGrid(state)
        : createThemeGrid(state, (currentView as int));

    final completed = state.actionItems.where((a) => a.isCompleted).length;
    final total =
        state.actionItems.where((a) => a.actionText.trim().isNotEmpty).length;

    // 화면 크기를 고려한 동적 크기 계산
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    // 세로 모드에서는 화면 너비에 맞춰서, 가로 모드에서는 고정 크기 사용
    double effectiveWidth;
    double effectiveHeight;

    if (isPortrait && !forScreenshot) {
      // 세로 모드: 화면 너비의 95%를 사용 (여백 고려)
      effectiveWidth = screenWidth * 0.95;
      effectiveHeight = effectiveWidth / a4Ratio;
    } else {
      // 가로 모드 또는 스크린샷용: 고정 A4 크기 사용
      effectiveWidth = a4Width;
      effectiveHeight = a4Height;
    }

    // 스크린샷/인쇄용일 때만 밝은 테마 강제 적용
    final shouldForceLightTheme = forScreenshot;
    final effectiveContext = shouldForceLightTheme
        ? MediaQuery(
            data: MediaQuery.of(context).copyWith(
              platformBrightness: Brightness.light,
            ),
            child: Builder(
              builder: (context) => _buildContent(
                context,
                isFull,
                grid,
                completed,
                total,
                effectiveWidth,
                effectiveHeight,
              ),
            ),
          )
        : _buildContent(
            context,
            isFull,
            grid,
            completed,
            total,
            effectiveWidth,
            effectiveHeight,
          );

    return effectiveContext;
  }

  Widget _buildContent(
    BuildContext context,
    bool isFull,
    List<List<dynamic>> grid,
    int completed,
    int total,
    double width,
    double height,
  ) {
    // 현재 테마에 따른 동적 색상
    final backgroundColor = CupertinoColors.systemBackground.resolveFrom(context);
    final textColor = CupertinoColors.label.resolveFrom(context);
    final secondaryTextColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    // 화면 크기에 따라 폰트 크기와 패딩을 조정
    final scaleFactor = width / a4Width;
    final titleFontSize = (28 * scaleFactor).clamp(20.0, 28.0);
    final goalFontSize = (22 * scaleFactor).clamp(16.0, 22.0);
    final statusFontSize = (18 * scaleFactor).clamp(14.0, 18.0);
    final quoteFontSize = (13 * scaleFactor).clamp(11.0, 13.0);
    final authorFontSize = (11 * scaleFactor).clamp(9.0, 11.0);
    final footerFontSize = (12 * scaleFactor).clamp(10.0, 12.0);
    final padding = (24.0 * scaleFactor).clamp(12.0, 24.0);
    final spacing = (8.0 * scaleFactor).clamp(4.0, 8.0);

    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 헤더 섹션
            Text(
              state.displayName.trim().isNotEmpty
                  ? state.displayName.trim()
                  : '나만의 만다라트',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.2,
              ),
            ),
            SizedBox(height: spacing),
            if (state.goalText.trim().isNotEmpty) ...[
              Text(
                state.goalText.trim(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: goalFontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.3,
                ),
              ),
              SizedBox(height: spacing),
            ],
            Text(
              '$completed/$total 액션아이템 완료',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: statusFontSize,
                fontWeight: FontWeight.w600,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: spacing * 2),

            // 만다라트 그리드 (메인 컨텐츠)
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(
                        color: CupertinoColors.systemGrey.resolveFrom(context).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: GridView.count(
                      crossAxisCount: isFull ? 9 : 3,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
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
                                  handler = () => onThemeClick(cell.themeIndex!);
                                } else if (cell.type == 'action' &&
                                    cell.themeIndex != null) {
                                  handler = () => onThemeClick(cell.themeIndex!);
                                }
                              } else if (cell.type == 'action' &&
                                  cell.themeIndex != null &&
                                  cell.actionIndex != null) {
                                handler = () {
                                  onToggleAction(
                                    cell.themeIndex!,
                                    cell.actionIndex!,
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

            SizedBox(height: spacing * 1.5),

            // 명언 (날짜 위에 표시)
            if (randomQuote != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding * 0.67, vertical: spacing),
                child: Column(
                  children: [
                    Text(
                      '"${randomQuote!['quote']!}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: quoteFontSize,
                        fontStyle: FontStyle.italic,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: spacing * 0.5),
                    Text(
                      '- ${randomQuote!['author']} -',
                      style: TextStyle(
                        fontSize: authorFontSize,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing),
            ],

            // 푸터 - 현재 날짜
            Text(
              '생성일: ${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().day.toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: footerFontSize,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

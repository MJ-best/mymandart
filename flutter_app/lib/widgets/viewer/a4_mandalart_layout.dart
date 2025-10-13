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
  final void Function(int themeIndex, int actionIndex, bool completed)
      onToggleAction;

  const A4MandalartLayout({
    super.key,
    required this.state,
    required this.currentView,
    required this.onThemeClick,
    required this.onToggleAction,
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

    return Container(
      width: a4Width,
      height: a4Height,
      color: CupertinoColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 헤더 섹션
            Text(
              state.displayName.trim().isNotEmpty
                  ? state.displayName.trim()
                  : '나만의 만다라트',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.black,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            if (state.goalText.trim().isNotEmpty) ...[
              Text(
                state.goalText.trim(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              '$completed/$total 액션아이템 완료',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemPurple,
              ),
            ),
            const SizedBox(height: 16),

            // 만다라트 그리드 (메인 컨텐츠)
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(
                        color: CupertinoColors.systemGrey.withOpacity(0.3),
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

            const SizedBox(height: 12),

            // 푸터 - 현재 날짜
            Text(
              '생성일: ${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().day.toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

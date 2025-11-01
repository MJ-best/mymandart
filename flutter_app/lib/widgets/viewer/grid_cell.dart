import 'package:flutter/cupertino.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/utils/mandalart_grid.dart';

class GridCellWidget extends StatelessWidget {
  final GridCell cell;
  final VoidCallback? onTap;
  const GridCellWidget({super.key, required this.cell, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    double fontSize;
    switch (cell.type) {
      case 'goal':
        bg = CupertinoColors.systemGreen;
        fg = CupertinoColors.white;
        fontSize = 18;
        break;
      case 'theme':
        bg = CupertinoColors.systemGreen.withOpacity(0.7);
        fg = CupertinoColors.white;
        fontSize = 16;
        break;
      case 'outer-theme':
        bg = CupertinoColors.systemGreen.withOpacity(0.4);
        fg = CupertinoColors.white;
        fontSize = 14;
        break;
      case 'action':
        switch (cell.status) {
          case ActionStatus.completed:
            bg = CupertinoColors.systemGreen.withOpacity(0.6);
            fg = CupertinoColors.white;
            break;
          case ActionStatus.inProgress:
            bg = CupertinoColors.systemOrange.withOpacity(0.6);
            fg = CupertinoColors.white;
            break;
          case ActionStatus.notStarted:
            bg = CupertinoColors.tertiarySystemFill.resolveFrom(context);
            fg = CupertinoColors.label.resolveFrom(context);
            break;
        }
        fontSize = 13;
        break;
      default:
        bg = CupertinoColors.systemBackground.resolveFrom(context);
        fg = CupertinoColors.label.resolveFrom(context);
        fontSize = 13;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(
            color: CupertinoColors.separator.resolveFrom(context).withOpacity(0.3),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final text = cell.text?.trim() ?? '';
            if (text.isEmpty ||
                constraints.maxWidth <= 0 ||
                constraints.maxHeight <= 0) {
              return const SizedBox.shrink();
            }

            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;
            double targetFontSize = fontSize;
            const double minFontSize = 8.0;

            TextPainter painterFor(double size) {
              final painter = TextPainter(
                text: TextSpan(
                  text: text,
                  style: TextStyle(
                    color: fg,
                    fontSize: size,
                    height: 1.2,
                    fontWeight: cell.type == 'goal'
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                maxLines: null,
              );
              painter.layout(maxWidth: maxWidth);
              return painter;
            }

            var painter = painterFor(targetFontSize);
            while ((painter.width > maxWidth || painter.height > maxHeight) &&
                targetFontSize > minFontSize) {
              targetFontSize = (targetFontSize - 1).clamp(minFontSize, fontSize);
              painter = painterFor(targetFontSize);
              if (targetFontSize == minFontSize) {
                break;
              }
            }

            return Text(
              text,
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: null,
              style: TextStyle(
                color: fg,
                fontSize: targetFontSize,
                height: 1.2,
                fontWeight:
                    cell.type == 'goal' ? FontWeight.w700 : FontWeight.w500,
              ),
            );
          },
        ),
      ),
    );
  }
}

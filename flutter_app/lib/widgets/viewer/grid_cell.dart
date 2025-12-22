import 'package:flutter/material.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/utils/app_theme.dart';
import 'package:mandarart_journey/utils/mandalart_grid.dart';

class GridCellWidget extends StatelessWidget {
  final GridCell cell;
  final VoidCallback? onTap;
  const GridCellWidget({super.key, required this.cell, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;
    final isDark = theme.brightness == Brightness.dark;

    Color bg;
    Color fg;
    double fontSize;
    FontWeight fontWeight = FontWeight.normal;

    switch (cell.type) {
      case 'goal':
        bg = primaryColor;
        fg = onPrimary;
        fontSize = 18;
        fontWeight = FontWeight.bold;
        break;
      case 'theme':
        // Theme cells
        bg = isDark 
            ? primaryColor.withValues(alpha: 0.15) 
            : primaryColor.withValues(alpha: 0.1);
        fg = colorScheme.onSurface;
        fontSize = 16;
        fontWeight = FontWeight.w600;
        break;
      case 'outer-theme':
         // Outer ring theme cells
        bg = isDark 
            ? primaryColor.withValues(alpha: 0.05) 
            : primaryColor.withValues(alpha: 0.05);
        fg = colorScheme.onSurface;
        fontSize = 14;
        fontWeight = FontWeight.w600;
        break;
      case 'action':
        switch (cell.status) {
          case ActionStatus.completed:
            bg = AppTheme.statusDone.withValues(alpha: 0.2);
            fg = isDark ? Colors.white : Colors.black87; 
            break;
          case ActionStatus.inProgress:
            bg = AppTheme.statusExec.withValues(alpha: 0.2);
            fg = isDark ? Colors.white : Colors.black87;
            break;
          case ActionStatus.notStarted:
            bg = colorScheme.surface;
            fg = colorScheme.onSurface;
            break;
        }
        fontSize = 13;
        break;
      default:
        bg = colorScheme.surface;
        fg = colorScheme.onSurface;
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
            color: (cell.type == 'goal') 
                ? primaryColor 
                : colorScheme.outline.withValues(alpha: 0.3),
            width: (cell.type == 'goal') ? 2 : 1,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                     color: fg,
                     fontSize: size,
                     fontWeight: fontWeight,
                     height: 1.2,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fg,
                fontSize: targetFontSize,
                height: 1.2,
                fontWeight: fontWeight,
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.onStepSelected,
  });

  final int currentStep;
  final ValueChanged<int>? onStepSelected;

  static const _labels = ['뷰어', '실행', '기록'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final isWide = MediaQuery.of(context).size.width >= 480;

    return Semantics(
      label: '현재 진행 단계 ${currentStep + 1} / 3',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.24),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_labels.length, (index) {
            final isCurrent = index == currentStep;
            final isPast = index < currentStep;
            final isActive = isCurrent || isPast;
            final backgroundColor = isCurrent
                ? primaryColor
                : isPast
                    ? primaryColor.withValues(alpha: 0.16)
                    : Colors.transparent;
            final foregroundColor = isCurrent
                ? (theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white)
                : isPast
                    ? primaryColor
                    : CupertinoColors.secondaryLabel.resolveFrom(context);

            final child = Padding(
              padding: EdgeInsets.only(
                right: index == _labels.length - 1 ? 0 : 6,
              ),
              child: CupertinoButton(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                onPressed: onStepSelected == null
                    ? null
                    : () => onStepSelected!(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 12 : 10,
                    vertical: isWide ? 8 : 7,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: isCurrent ? 18 : 16,
                        height: isCurrent ? 18 : 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.white.withValues(alpha: 0.24)
                              : isPast
                                  ? primaryColor.withValues(alpha: 0.14)
                                  : colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isCurrent
                                ? foregroundColor
                                : isPast
                                    ? primaryColor
                                    : foregroundColor,
                          ),
                        ),
                      ),
                      if (isWide) ...[
                        const SizedBox(width: 8),
                        Text(
                          _labels[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isCurrent ? FontWeight.w800 : FontWeight.w700,
                            color: foregroundColor,
                          ),
                        ),
                      ],
                      if (!isWide && isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          _labels[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isCurrent ? FontWeight.w800 : FontWeight.w700,
                            color: foregroundColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );

            return child;
          }),
        ),
      ),
    );
  }
}

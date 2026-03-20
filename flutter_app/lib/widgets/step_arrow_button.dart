import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StepArrowButton extends StatelessWidget {
  const StepArrowButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = theme.primaryColor;
    final isEnabled = onPressed != null;
    final Color iconColor = isEnabled
        ? primaryColor
        : CupertinoColors.systemGrey3.resolveFrom(context);
    final Color backgroundColor = isEnabled
        ? primaryColor.withValues(alpha: 0.14)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);
    final Color borderColor = isEnabled
        ? primaryColor.withValues(alpha: 0.2)
        : colorScheme.outline.withValues(alpha: 0.16);

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      child: SizedBox(
        width: 48,
        height: 48,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
        ),
      ),
    );
  }
}

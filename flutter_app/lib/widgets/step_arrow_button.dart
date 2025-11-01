import 'package:flutter/cupertino.dart';

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
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final isEnabled = onPressed != null;
    final Color iconColor = isEnabled
        ? primaryColor
        : CupertinoColors.systemGrey3.resolveFrom(context);
    final Color backgroundColor = isEnabled
        ? primaryColor.withValues(alpha: 0.16)
        : CupertinoColors.systemGrey4.resolveFrom(context).withValues(alpha: 0.28);

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      child: SizedBox(
        width: 36,
        height: 36,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: iconColor),
          ),
        ),
      ),
    );
  }
}

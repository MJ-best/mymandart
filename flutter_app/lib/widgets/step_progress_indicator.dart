import 'package:flutter/cupertino.dart';

class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '현재 진행 단계 ${currentStep + 1} / 3',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index <= currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 6 : 5,
            height: isActive ? 6 : 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemGrey3,
            ),
          );
        }),
      ),
    );
  }
}

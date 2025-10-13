import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mandarart_journey/data/keywords.dart';

class GoalStep extends StatefulWidget {
  final String value;
  final void Function(String) onChange;
  const GoalStep({super.key, required this.value, required this.onChange});

  @override
  State<GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends State<GoalStep> {
  late final TextEditingController _controller;
  late final List<String> _randomCommunityGoals;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(() {
      widget.onChange(_controller.text);
    });

    // 랜덤하게 5개의 커뮤니티 목표 선택
    final random = Random();
    final shuffled = List<String>.from(Keywords.communityGoals)
      ..shuffle(random);
    _randomCommunityGoals = shuffled.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '나의 목표',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
                letterSpacing: -0.41,
              ),
            ),
            if (_controller.text.isNotEmpty)
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('목표 초기화'),
                      content: const Text('작성한 목표를 삭제하시겠습니까?'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('취소'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _controller.clear();
                            widget.onChange('');
                            Navigator.pop(context);
                          },
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(
                  CupertinoIcons.trash,
                  color: CupertinoColors.destructiveRed,
                  size: 20,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: _controller,
          maxLines: 4,
          placeholder: Keywords.goalExamples[0],
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(8),
          ),
          style: const TextStyle(
            fontSize: 17,
            color: CupertinoColors.label,
          ),
          placeholderStyle: const TextStyle(
            fontSize: 17,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_controller.text.length}/200',
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Row(
          children: [
            Icon(
              CupertinoIcons.person_2,
              size: 18,
              color: CupertinoColors.systemPurple,
            ),
            SizedBox(width: 8),
            Text(
              '다른 사람들은 이런 목표를 세우고 있어요',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _randomCommunityGoals.map((goal) {
            return CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              minimumSize: const Size(44, 44),
              color: CupertinoColors.systemPurple.withOpacity(0.1),
              onPressed: () {
                HapticFeedback.selectionClick();
                _controller.text = goal;
              },
              child: Text(
                goal,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemPurple,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

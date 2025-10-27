import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mandarart_journey/data/keywords.dart';

class ThemesStep extends StatefulWidget {
  final String goalText;
  final List<String> themes;
  final void Function(List<String>) onChange;
  const ThemesStep({
    super.key,
    required this.goalText,
    required this.themes,
    required this.onChange,
  });

  @override
  State<ThemesStep> createState() => _ThemesStepState();
}

class _ThemesStepState extends State<ThemesStep> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.themes.length,
      (index) => TextEditingController(text: widget.themes[index]),
    );
    for (int i = 0; i < _controllers.length; i++) {
      final index = i;
      _controllers[index].addListener(() {
        final next = List<String>.from(widget.themes);
        next[index] = _controllers[index].text;
        widget.onChange(next);
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant ThemesStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.themes != oldWidget.themes) {
      Future.microtask(() {
        for (int i = 0; i < _controllers.length; i++) {
          if (_controllers[i].text != widget.themes[i]) {
            _controllers[i].text = widget.themes[i];
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasGoal = widget.goalText.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 중앙 목표 표시 - "확장되는 느낌" 전달
        if (hasGoal) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CupertinoColors.systemPurple.withOpacity(0.15),
                  CupertinoColors.systemIndigo.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CupertinoColors.systemPurple.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            color: CupertinoColors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '중심 목표',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.goalText.trim(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.label,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.arrow_down,
                      color: CupertinoColors.systemPurple.withOpacity(0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '8가지 핵심영역',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.arrow_down,
                      color: CupertinoColors.systemPurple.withOpacity(0.6),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        Wrap(
          runSpacing: 12,
          children: List.generate(8, (index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '액션타겟 ${index + 1}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label,
                            ),
                          ),
                          if (_controllers[index].text.isNotEmpty)
                            CupertinoButton(
                              padding: const EdgeInsets.all(6),
                              minimumSize: const Size(32, 32),
                              onPressed: () {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text('테마 초기화'),
                                    content:
                                        Text('액션타겟 ${index + 1}을(를) 삭제하시겠습니까?'),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text('취소'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      CupertinoDialogAction(
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          HapticFeedback.mediumImpact();
                                          _controllers[index].clear();
                                          final next =
                                              List<String>.from(widget.themes);
                                          next[index] = '';
                                          widget.onChange(next);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('삭제'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CupertinoColors.destructiveRed,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  CupertinoIcons.xmark,
                                  size: 10,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _controllers[index],
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.tertiarySystemFill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        style: const TextStyle(
                          fontSize: 17,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_controllers[index].text.trim().isEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Keywords.themeExamples.map((keyword) {
                      return CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        minimumSize: const Size(44, 44),
                        color: CupertinoColors.systemGrey5,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _controllers[index].text = keyword;
                        },
                        child: Text(
                          keyword,
                          style: const TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.label,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '진행률: ${widget.themes.where((t) => t.trim().isNotEmpty).length}/8',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemPurple,
          ),
        ),
      ],
    );
  }
}

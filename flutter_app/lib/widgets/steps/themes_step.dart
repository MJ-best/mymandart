import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mandarart_journey/data/keywords.dart';

class ThemesStep extends StatefulWidget {
  final List<String> themes;
  final void Function(List<String>) onChange;
  const ThemesStep({super.key, required this.themes, required this.onChange});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/data/keywords.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/widgets/mandalart_viewer.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MandalartAppScreen extends ConsumerWidget {
  const MandalartAppScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mandalartProvider);
    final notifier = ref.read(mandalartProvider.notifier);

    if (state.showViewer) {
      return MandalartViewer(
        state: state,
        onClose: notifier.closeViewer,
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Mandalart Journey'),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
        trailing: Semantics(
          label: 'View Mandalart grid',
          button: true,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.openViewer();
            },
            child: const Icon(CupertinoIcons.square_grid_2x2),
          ),
        ),
      ),
      child: SafeArea(
        child: ScreenTypeLayout.builder(
          mobile: (BuildContext context) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${state.currentStep + 1} / 3',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                if (state.currentStep == 0) _GoalStep(state.goalText, notifier.updateGoal),
                if (state.currentStep == 1) _ThemesStep(state.themes, notifier.updateThemes),
                if (state.currentStep == 2) _ActionsStep(state, notifier),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Go to previous step',
                        button: true,
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(16),
                          onPressed: state.currentStep > 0
                              ? () {
                                  HapticFeedback.lightImpact();
                                  notifier.previousStep();
                                }
                              : null,
                          color: CupertinoColors.systemGrey4,
                          disabledColor: CupertinoColors.quaternarySystemFill,
                          child: const Text(
                            '이전',
                            style: TextStyle(color: CupertinoColors.label),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label: state.currentStep < 2 ? 'Go to next step' : 'View Mandalart chart',
                        button: true,
                        child: CupertinoButton.filled(
                          padding: const EdgeInsets.all(16),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            if (state.currentStep < 2) {
                              notifier.nextStep();
                            } else {
                              notifier.openViewer();
                            }
                          },
                          child: Text(state.currentStep < 2 ? '다음' : '만다라트 보기'),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          tablet: (BuildContext context) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${state.currentStep + 1} / 3',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                if (state.currentStep == 0) _GoalStep(state.goalText, notifier.updateGoal),
                if (state.currentStep == 1) _ThemesStep(state.themes, notifier.updateThemes),
                if (state.currentStep == 2) _ActionsStep(state, notifier),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Go to previous step',
                        button: true,
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(16),
                          onPressed: state.currentStep > 0
                              ? () {
                                  HapticFeedback.lightImpact();
                                  notifier.previousStep();
                                }
                              : null,
                          color: CupertinoColors.systemGrey4,
                          disabledColor: CupertinoColors.quaternarySystemFill,
                          child: const Text(
                            '이전',
                            style: TextStyle(color: CupertinoColors.label),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label: state.currentStep < 2 ? 'Go to next step' : 'View Mandalart chart',
                        button: true,
                        child: CupertinoButton.filled(
                          padding: const EdgeInsets.all(16),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            if (state.currentStep < 2) {
                              notifier.nextStep();
                            } else {
                              notifier.openViewer();
                            }
                          },
                          child: Text(state.currentStep < 2 ? '다음' : '만다라트 보기'),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalStep extends StatefulWidget {
  final String value;
  final void Function(String) onChange;
  const _GoalStep(this.value, this.onChange);

  @override
  State<_GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends State<_GoalStep> {
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
    final shuffled = List<String>.from(Keywords.communityGoals)..shuffle(random);
    _randomCommunityGoals = shuffled.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '나의 목표',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 12),
        CupertinoTextField(
          controller: _controller,
          maxLines: 4,
          placeholder: Keywords.goalExamples[0],
          padding: const EdgeInsets.all(12),
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
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(
              CupertinoIcons.person_2,
              size: 18,
              color: CupertinoColors.systemPurple,
            ),
            const SizedBox(width: 8),
            const Text(
              '다른 사람들은 이런 목표를 세우고 있어요',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _randomCommunityGoals.map((goal) {
            return CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

class _ThemesStep extends StatefulWidget {
  final List<String> themes;
  final void Function(List<String>) onChange;
  const _ThemesStep(this.themes, this.onChange);

  @override
  State<_ThemesStep> createState() => _ThemesStepState();
}

class _ThemesStepState extends State<_ThemesStep> {
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
      });
    }
  }

  @override
  void didUpdateWidget(covariant _ThemesStep oldWidget) {
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
                      Text(
                        '테마 ${index + 1}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _controllers[index],
                        padding: const EdgeInsets.all(12),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Keywords.themeExamples.map((keyword) {
                    return CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

class _ActionsStep extends StatefulWidget {
  final MandalartStateModel state;
  final MandalartNotifier notifier;
  const _ActionsStep(this.state, this.notifier);

  @override
  State<_ActionsStep> createState() => _ActionsStepState();
}

class _ActionsStepState extends State<_ActionsStep> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  int? _expandedThemeIndex;
  String? _focusedKey;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant _ActionsStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _disposeControllers();
      Future.microtask(() {
        _initializeControllers();
      });
    }
  }

  void _initializeControllers() {
    for (var themeIndex = 0; themeIndex < widget.state.themes.length; themeIndex++) {
      final themeId = 'theme-$themeIndex';
      for (var actionIndex = 0; actionIndex < 8; actionIndex++) {
        final key = '${themeId}_$actionIndex';
        final existing = widget.state.actionItems.firstWhere(
          (a) => a.themeId == themeId && a.order == actionIndex,
          orElse: () => ActionItemModel(
            id: 'tmp',
            themeId: themeId,
            actionText: '',
            isCompleted: false,
            order: actionIndex,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        final controller = TextEditingController(text: existing.actionText);
        controller.addListener(() {
          widget.notifier.updateActionItem(
            themeIndex: themeIndex,
            actionIndex: actionIndex,
            text: controller.text,
          );
        });
        final focusNode = FocusNode();
        focusNode.addListener(() {
          if (focusNode.hasFocus) {
            setState(() => _focusedKey = key);
          }
        });
        _controllers[key] = controller;
        _focusNodes[key] = focusNode;
      }
    }
  }

  void _disposeControllers() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.state.themes.where((t) => t.trim().isNotEmpty).toList();
    if (filled.isEmpty) {
      return const Text(
        '먼저 테마를 입력해주세요.',
        style: TextStyle(
          fontSize: 17,
          color: CupertinoColors.secondaryLabel,
        ),
      );
    }
    return Column(
      children: List.generate(filled.length, (themeIndex) {
        final isExpanded = _expandedThemeIndex == themeIndex;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.separator.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(16),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _expandedThemeIndex = isExpanded ? null : themeIndex;
                  });
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        filled[themeIndex],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                      color: CupertinoColors.systemPurple,
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 1,
                    color: CupertinoColors.separator.withOpacity(0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(8, (actionIndex) {
                final themeId = 'theme-$themeIndex';
                final key = '${themeId}_$actionIndex';
                final existing = widget.state.actionItems.firstWhere(
                  (a) => a.themeId == themeId && a.order == actionIndex,
                  orElse: () => ActionItemModel(
                    id: 'tmp',
                    themeId: themeId,
                    actionText: '',
                    isCompleted: false,
                    order: actionIndex,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Semantics(
                          label: existing.isCompleted ? 'Mark as incomplete' : 'Mark as complete',
                          child: CupertinoCheckbox(
                            value: existing.isCompleted,
                            activeColor: CupertinoColors.systemPurple,
                            onChanged: (v) {
                              HapticFeedback.lightImpact();
                              widget.notifier.updateActionItem(
                                themeIndex: themeIndex,
                                actionIndex: actionIndex,
                                completed: v ?? false,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CupertinoContextMenu(
                            actions: [
                              CupertinoContextMenuAction(
                                trailingIcon: CupertinoIcons.clear,
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context);
                                  _controllers[key]?.clear();
                                  widget.notifier.updateActionItem(
                                    themeIndex: themeIndex,
                                    actionIndex: actionIndex,
                                    text: '',
                                  );
                                },
                                child: const Text('Clear'),
                              ),
                              CupertinoContextMenuAction(
                                isDestructiveAction: true,
                                trailingIcon: CupertinoIcons.delete,
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  Navigator.pop(context);
                                  _controllers[key]?.clear();
                                  widget.notifier.updateActionItem(
                                    themeIndex: themeIndex,
                                    actionIndex: actionIndex,
                                    text: '',
                                    completed: false,
                                  );
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                            child: CupertinoTextField(
                              controller: _controllers[key],
                              focusNode: _focusNodes[key],
                              placeholder: Keywords.getActionsForTheme(filled[themeIndex])[actionIndex % Keywords.getActionsForTheme(filled[themeIndex]).length],
                              padding: const EdgeInsets.all(12),
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
                              onChanged: (v) => widget.notifier.updateActionItem(
                                themeIndex: themeIndex,
                                actionIndex: actionIndex,
                                text: v,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (actionIndex < 7) const SizedBox(height: 12),
                  ],
                );
              }),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '추천 액션',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: Keywords.getActionsForTheme(filled[themeIndex]).map((keyword) {
                          return CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            color: CupertinoColors.systemGrey5,
                            minimumSize: const Size(30, 30),
                            onPressed: _focusedKey != null && _focusedKey!.startsWith('theme-$themeIndex')
                                ? () {
                                    HapticFeedback.selectionClick();
                                    _controllers[_focusedKey]?.text = keyword;
                                  }
                                : null,
                            child: Text(
                              keyword,
                              style: TextStyle(
                                fontSize: 13,
                                color: _focusedKey != null && _focusedKey!.startsWith('theme-$themeIndex')
                                    ? CupertinoColors.label
                                    : CupertinoColors.secondaryLabel,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

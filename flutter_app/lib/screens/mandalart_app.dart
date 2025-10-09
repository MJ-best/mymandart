import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/data/keywords.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/widgets/mandalart_viewer.dart';
import 'package:responsive_builder/responsive_builder.dart';


class MandalartAppScreen extends ConsumerStatefulWidget {
  const MandalartAppScreen({super.key});

  @override
  ConsumerState<MandalartAppScreen> createState() => _MandalartAppScreenState();
}

class _MandalartAppScreenState extends ConsumerState<MandalartAppScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialStep = ref.read(mandalartProvider).currentStep;
    _pageController = PageController(initialPage: initialStep);
    ref.listen<int>(
      mandalartProvider.select((value) => value.currentStep),
      (previous, next) {
        if (!_pageController.hasClients) {
          return;
        }
        final currentPage = _pageController.page?.round() ?? _pageController.initialPage;
        if (currentPage != next) {
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mandalartProvider);
    final notifier = ref.read(mandalartProvider.notifier);

    if (state.showViewer) {
      return MandalartViewer(
        state: state,
        onClose: notifier.closeViewer,
        onToggleAction: (themeIndex, actionIndex, completed) {
          notifier.updateActionItem(
            themeIndex: themeIndex,
            actionIndex: actionIndex,
            completed: completed,
          );
        },
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            if (state.currentStep > 0) {
              notifier.previousStep();
            }
          },
        ),
        middle: Text(
          state.displayName.isNotEmpty ? state.displayName : '나만의 만다라트',
        ),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _StepArrowButton(
                    icon: CupertinoIcons.chevron_back,
                    semanticLabel: '이전 단계로 이동',
                    onPressed: state.currentStep > 0
                        ? () {
                            HapticFeedback.lightImpact();
                            notifier.previousStep();
                          }
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: _StepProgressIndicator(
                        currentStep: state.currentStep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StepArrowButton(
                    icon: CupertinoIcons.chevron_forward,
                    semanticLabel: state.currentStep < 2
                        ? '다음 단계로 이동'
                        : '만다라트 보기 열기',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (state.currentStep < 2) {
                        notifier.nextStep();
                      } else {
                        notifier.openViewer();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ScreenTypeLayout.builder(
                mobile: (BuildContext context) => _buildStepPager(
                  context: context,
                  state: state,
                  notifier: notifier,
                  padding: const EdgeInsets.all(16),
                ),
                tablet: (BuildContext context) => _buildStepPager(
                  context: context,
                  state: state,
                  notifier: notifier,
                  padding: const EdgeInsets.all(32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPager({
    required BuildContext context,
    required MandalartStateModel state,
    required MandalartNotifier notifier,
    required EdgeInsets padding,
  }) {
    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (page) {
        if (page != state.currentStep) {
          notifier.setStep(page);
        }
      },
      children: List.generate(3, (index) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index == 0)
                _GoalStep(state.goalText, notifier.updateGoal)
              else if (index == 1)
                _ThemesStep(state.themes, notifier.updateThemes)
              else
                _ActionsStep(state, notifier),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}

class _StepProgressIndicator extends StatelessWidget {
  const _StepProgressIndicator({required this.currentStep});

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
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: isActive ? 14 : 10,
            height: isActive ? 14 : 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? CupertinoColors.systemPurple
                  : CupertinoColors.systemGrey3,
            ),
          );
        }),
      ),
    );
  }
}

class _StepArrowButton extends StatelessWidget {
  const _StepArrowButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final Color iconColor = isEnabled
        ? CupertinoColors.systemPurple.resolveFrom(context)
        : CupertinoColors.systemGrey3.resolveFrom(context);
    final Color backgroundColor = isEnabled
        ? CupertinoColors.systemPurple.resolveFrom(context).withOpacity(0.16)
        : CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.28);

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
        if (mounted) {
          setState(() {});
        }
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
    for (var themeIndex = 0;
        themeIndex < widget.state.themes.length;
        themeIndex++) {
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
    final filledThemes = widget.state.themes
        .asMap()
        .entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .toList();
    if (filledThemes.isEmpty) {
      return const Text(
        '먼저 테마를 입력해주세요.',
        style: TextStyle(
          fontSize: 17,
          color: CupertinoColors.secondaryLabel,
        ),
      );
    }
    return Column(
      children: List.generate(filledThemes.length, (themeIndex) {
        final themeEntry = filledThemes[themeIndex];
        final actualThemeIndex = themeEntry.key;
        final themeTitle = themeEntry.value;
        final themeKeywords = Keywords.getActionsForTheme(themeTitle);
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
                        themeTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(36, 36),
                      onPressed: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('액션 아이템 초기화'),
                            content: Text(
                                '$themeTitle의 모든 액션 아이템을 삭제하시겠습니까?'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('취소'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  widget.notifier
                                      .clearThemeActions(actualThemeIndex);
                                  Navigator.pop(context);
                                },
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 18,
                        height: 18,
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
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
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
                      final themeId = 'theme-$actualThemeIndex';
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
                                label: existing.isCompleted
                                    ? 'Mark as incomplete'
                                    : 'Mark as complete',
                                child: CupertinoCheckbox(
                                  value: existing.isCompleted,
                                  activeColor: CupertinoColors.systemPurple,
                                  onChanged: (v) {
                                    HapticFeedback.lightImpact();
                                    widget.notifier.updateActionItem(
                                      themeIndex: actualThemeIndex,
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
                                          themeIndex: actualThemeIndex,
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
                                          themeIndex: actualThemeIndex,
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
                                    placeholder: themeKeywords.isNotEmpty
                                        ? themeKeywords[actionIndex %
                                            themeKeywords.length]
                                        : null,
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
                                    onChanged: (v) =>
                                        widget.notifier.updateActionItem(
                                      themeIndex: actualThemeIndex,
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
                        children: themeKeywords.map((keyword) {
                          final themeKeyPrefix = 'theme-$actualThemeIndex';
                          return CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            color: CupertinoColors.systemGrey5,
                            minimumSize: const Size(44, 44),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              final targetKey = _focusedKey != null &&
                                      _focusedKey!.startsWith(themeKeyPrefix)
                                  ? _focusedKey
                                  : '${themeKeyPrefix}_0';
                              final controller = _controllers[targetKey];
                              if (controller != null) {
                                controller.text = keyword;
                                controller.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(offset: controller.text.length),
                                );
                              }
                            },
                            child: Text(
                              keyword,
                              style: const TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.label,
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

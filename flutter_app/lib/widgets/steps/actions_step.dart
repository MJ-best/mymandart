import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/data/keywords.dart';

class ActionsStep extends StatefulWidget {
  final MandalartStateModel state;
  final MandalartNotifier notifier;
  const ActionsStep({super.key, required this.state, required this.notifier});

  @override
  State<ActionsStep> createState() => _ActionsStepState();
}

class _ActionsStepState extends State<ActionsStep> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  int? _expandedThemeIndex;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant ActionsStep oldWidget) {
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
            status: ActionStatus.notStarted,
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
    final primaryColor = CupertinoTheme.of(context).primaryColor;
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
      children: [
        // 목표 표시 - 연결성 강화
        if (widget.state.goalText.trim().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.1),
                  CupertinoColors.systemIndigo.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            color: primaryColor,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '중심 목표',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.state.goalText.trim(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${filledThemes.length}개의 핵심영역이 각각 8가지 측정가능한 구체적 행동으로 확장됩니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        ...List.generate(filledThemes.length, (themeIndex) {
          final themeEntry = filledThemes[themeIndex];
          final actualThemeIndex = themeEntry.key;
          final themeTitle = themeEntry.value;
          final themeKeywords = Keywords.getActionsForTheme(themeTitle);
          final isExpanded = _expandedThemeIndex == themeIndex;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isExpanded
                  ? primaryColor.withValues(alpha: 0.05)
                  : CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded
                    ? primaryColor.withValues(alpha: 0.3)
                    : CupertinoColors.separator.resolveFrom(context).withValues(alpha: 0.3),
                width: isExpanded ? 2 : 1,
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
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label.resolveFrom(context),
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
                      color: primaryColor,
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
                    color: CupertinoColors.separator.resolveFrom(context).withValues(alpha: 0.3),
                  ),
                ),
                // 확장 메시지 추가
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.arrow_down_circle_fill,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '8가지 측정가능한 구체적 행동',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.secondaryLabel.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.arrow_down_circle_fill,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 16,
                      ),
                    ],
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
                          status: ActionStatus.notStarted,
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
                              // 상태 표시 아이콘 (터치로 상태 변경)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  final newStatus = widget.notifier.toggleActionStatus(
                                    themeIndex: actualThemeIndex,
                                    actionIndex: actionIndex,
                                  );
                                  // Add strong haptic feedback when completing a task
                                  if (newStatus == ActionStatus.completed) {
                                    HapticFeedback.mediumImpact();
                                  }
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: existing.status == ActionStatus.completed
                                        ? primaryColor
                                        : existing.status == ActionStatus.inProgress
                                            ? CupertinoColors.systemOrange
                                            : CupertinoColors.systemGrey5,
                                  ),
                                  child: Icon(
                                    existing.status == ActionStatus.completed
                                        ? CupertinoIcons.checkmark_alt
                                        : existing.status == ActionStatus.inProgress
                                            ? CupertinoIcons.play_fill
                                            : CupertinoIcons.circle,
                                    color: existing.status == ActionStatus.notStarted
                                        ? CupertinoColors.systemGrey
                                        : CupertinoColors.white,
                                    size: 16,
                                  ),
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
                                          status: ActionStatus.notStarted,
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
                                      color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: CupertinoColors.label.resolveFrom(context),
                                    ),
                                    placeholderStyle: TextStyle(
                                      fontSize: 17,
                                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
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
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.lightbulb,
                            size: 16,
                            color: CupertinoColors.secondaryLabel.resolveFrom(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '액션 아이디어',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.secondaryLabel.resolveFrom(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        themeKeywords.join(' · '),
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                          height: 1.5,
                        ),
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
      ],
    );
  }
}

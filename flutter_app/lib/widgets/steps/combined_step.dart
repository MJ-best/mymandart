import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/data/keywords.dart';
import 'package:mandarart_journey/widgets/streak_widget.dart';

/// 테마 입력과 액션 아이템 입력을 결합한 스텝
class CombinedStep extends ConsumerStatefulWidget {
  final MandalartStateModel state;
  final MandalartNotifier notifier;
  const CombinedStep({super.key, required this.state, required this.notifier});

  @override
  ConsumerState<CombinedStep> createState() => _CombinedStepState();
}

class _CombinedStepState extends ConsumerState<CombinedStep> {
  late final List<TextEditingController> _themeControllers;
  final Map<String, TextEditingController> _actionControllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  int? _expandedThemeIndex;

  @override
  void initState() {
    super.initState();
    _initializeThemeControllers();
    _initializeActionControllers();
  }

  void _initializeThemeControllers() {
    _themeControllers = List.generate(
      widget.state.themes.length,
      (index) => TextEditingController(text: widget.state.themes[index]),
    );
    for (int i = 0; i < _themeControllers.length; i++) {
      final index = i;
      _themeControllers[index].addListener(() {
        final next = List<String>.from(widget.state.themes);
        next[index] = _themeControllers[index].text;
        widget.notifier.updateThemes(next);
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _initializeActionControllers() {
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
        _actionControllers[key] = controller;
        _focusNodes[key] = focusNode;
      }
    }
  }

  @override
  void didUpdateWidget(covariant CombinedStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.themes != oldWidget.state.themes) {
      Future.microtask(() {
        for (int i = 0; i < _themeControllers.length; i++) {
          if (_themeControllers[i].text != widget.state.themes[i]) {
            _themeControllers[i].text = widget.state.themes[i];
          }
        }
      });
    }
    if (widget.state != oldWidget.state) {
      _disposeActionControllers();
      Future.microtask(() {
        _initializeActionControllers();
      });
    }
  }

  void _disposeActionControllers() {
    for (var controller in _actionControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _actionControllers.clear();
    _focusNodes.clear();
  }

  @override
  void dispose() {
    for (var controller in _themeControllers) {
      controller.dispose();
    }
    _disposeActionControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasGoal = widget.state.goalText.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 출석체크 위젯 (꾸준점수)
        const StreakWidget(),
        const SizedBox(height: 24),

        // 중앙 목표 표시
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
                  widget.state.goalText.trim(),
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
                      '이 목표를 실현하기 위한 8가지 핵심 영역',
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

        // 테마 입력 섹션
        Text(
          '8가지 핵심 영역 (액션타겟)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(8, (themeIndex) {
          final hasTheme = _themeControllers[themeIndex].text.trim().isNotEmpty;
          final isExpanded = _expandedThemeIndex == themeIndex && hasTheme;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 테마 입력 필드
              Container(
                decoration: BoxDecoration(
                  color: isExpanded
                      ? CupertinoColors.systemPurple.withOpacity(0.05)
                      : CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpanded
                        ? CupertinoColors.systemPurple.withOpacity(0.3)
                        : CupertinoColors.separator.resolveFrom(context).withOpacity(0.3),
                    width: isExpanded ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '액션타겟 ${themeIndex + 1}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.label,
                                ),
                              ),
                              Row(
                                children: [
                                  if (hasTheme)
                                    CupertinoButton(
                                      padding: const EdgeInsets.all(6),
                                      minimumSize: const Size(32, 32),
                                      onPressed: () {
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (context) => CupertinoAlertDialog(
                                            title: const Text('테마 초기화'),
                                            content: Text('액션타겟 ${themeIndex + 1}을(를) 삭제하시겠습니까?'),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: const Text('취소'),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                              CupertinoDialogAction(
                                                isDestructiveAction: true,
                                                onPressed: () {
                                                  HapticFeedback.mediumImpact();
                                                  _themeControllers[themeIndex].clear();
                                                  widget.notifier.clearThemeActions(themeIndex);
                                                  setState(() {
                                                    _expandedThemeIndex = null;
                                                  });
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
                                  if (hasTheme) const SizedBox(width: 8),
                                  if (hasTheme)
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          _expandedThemeIndex = isExpanded ? null : themeIndex;
                                        });
                                      },
                                      child: Icon(
                                        isExpanded
                                            ? CupertinoIcons.chevron_up
                                            : CupertinoIcons.chevron_down,
                                        color: CupertinoColors.systemPurple,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CupertinoTextField(
                            controller: _themeControllers[themeIndex],
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

                    // 테마 예제 키워드
                    if (!hasTheme) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: Keywords.themeExamples.map((keyword) {
                            return CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              minimumSize: const Size(44, 44),
                              color: CupertinoColors.systemGrey5,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                _themeControllers[themeIndex].text = keyword;
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
                      ),
                    ],

                    // 액션 아이템 (확장 시에만 표시)
                    if (isExpanded) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 1,
                          color: CupertinoColors.separator.resolveFrom(context).withOpacity(0.3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.arrow_down_circle_fill,
                              color: CupertinoColors.systemPurple.withOpacity(0.6),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '이 영역을 달성하기 위한 8가지 구체적 행동',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              CupertinoIcons.arrow_down_circle_fill,
                              color: CupertinoColors.systemPurple.withOpacity(0.6),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildActionItems(themeIndex, _themeControllers[themeIndex].text),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }),

        const SizedBox(height: 8),
        Text(
          '진행률: ${widget.state.themes.where((t) => t.trim().isNotEmpty).length}/8',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildActionItems(int themeIndex, String themeTitle) {
    final themeId = 'theme-$themeIndex';
    final themeKeywords = Keywords.getActionsForTheme(themeTitle);

    return Column(
      children: [
        ...List.generate(8, (actionIndex) {
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
                  // 상태 표시 아이콘
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.notifier.toggleActionStatus(
                        themeIndex: themeIndex,
                        actionIndex: actionIndex,
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: existing.status == ActionStatus.completed
                            ? CupertinoColors.systemPurple
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
                            _actionControllers[key]?.clear();
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
                            _actionControllers[key]?.clear();
                            widget.notifier.updateActionItem(
                              themeIndex: themeIndex,
                              actionIndex: actionIndex,
                              text: '',
                              status: ActionStatus.notStarted,
                            );
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                      child: CupertinoTextField(
                        controller: _actionControllers[key],
                        focusNode: _focusNodes[key],
                        placeholder: themeKeywords.isNotEmpty
                            ? themeKeywords[actionIndex % themeKeywords.length]
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
        const SizedBox(height: 16),
        // 액션 아이디어
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
      ],
    );
  }
}

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
  String? _focusedKey;

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

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';
import 'package:mandarart_journey/data/keywords.dart';
import 'package:mandarart_journey/widgets/streak_widget.dart';

class EditMandalartScreen extends ConsumerStatefulWidget {
  const EditMandalartScreen({super.key});

  @override
  ConsumerState<EditMandalartScreen> createState() => _EditMandalartScreenState();
}

class _EditMandalartScreenState extends ConsumerState<EditMandalartScreen> {
  late final List<TextEditingController> _themeControllers;
  final Map<String, TextEditingController> _actionControllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  int? _expandedThemeIndex;

  @override
  void initState() {
    super.initState();
    final state = ref.read(mandalartProvider);
    _themeControllers = List.generate(
      state.themes.length,
      (index) => TextEditingController(text: state.themes[index]),
    );
    _initializeActionControllers(state);

    for (int i = 0; i < _themeControllers.length; i++) {
      final index = i;
      _themeControllers[i].addListener(() {
        final notifier = ref.read(mandalartProvider.notifier);
        final currentThemes = ref.read(mandalartProvider).themes;
        final next = List<String>.from(currentThemes);
        next[index] = _themeControllers[index].text;
        notifier.updateThemes(next);
      });
    }
  }

  void _initializeActionControllers(MandalartStateModel state) {
    final notifier = ref.read(mandalartProvider.notifier);
    for (var themeIndex = 0; themeIndex < state.themes.length; themeIndex++) {
      final themeId = 'theme-$themeIndex';
      for (var actionIndex = 0; actionIndex < 8; actionIndex++) {
        final key = '${themeId}_$actionIndex';
        final existing = state.actionItems.firstWhere(
          (a) => a.themeId == themeId && a.order == actionIndex,
          orElse: () => ActionItemModel.initial(themeId, actionIndex),
        );
        final controller = TextEditingController(text: existing.actionText);
        controller.addListener(() {
          notifier.updateActionItem(
            themeIndex: themeIndex,
            actionIndex: actionIndex,
            text: controller.text,
          );
        });
        _actionControllers[key] = controller;
        _focusNodes[key] = FocusNode();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _themeControllers) {
      controller.dispose();
    }
    for (var controller in _actionControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mandalartProvider);
    final notifier = ref.read(mandalartProvider.notifier);
    final primaryColor = ref.watch(themeProvider).primaryColor;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        middle: const Text('목표 편집'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            final notifier = ref.read(mandalartProvider.notifier);
            await notifier.saveCurrentMandalart();
            if (mounted) {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('저장 완료'),
                  content: const Text('만다라트가 저장되었습니다.'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('확인'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        context.pop(); // Go back to the previous screen
                      },
                    ),
                  ],
                ),
              );
            }
          },
          child: const Text('저장'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ... (Goal display and other widgets from CombinedStep)
            ..._buildThemeAndActionFields(state, notifier, primaryColor),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildThemeAndActionFields(
      MandalartStateModel state, MandalartNotifier notifier, Color primaryColor) {
    return List.generate(8, (themeIndex) {
      final isExpanded = _expandedThemeIndex == themeIndex;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isExpanded
              ? primaryColor.withOpacity(0.05)
              : CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CupertinoListTile(
              title: Text('액션타겟 ${themeIndex + 1}'),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _expandedThemeIndex = isExpanded ? null : themeIndex;
                  });
                },
                child: Icon(isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CupertinoTextField(
                controller: _themeControllers[themeIndex],
                placeholder: '핵심 목표 ${themeIndex + 1}',
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildActionItems(themeIndex, state, notifier),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildActionItems(int themeIndex, MandalartStateModel state, MandalartNotifier notifier) {
    final themeId = 'theme-$themeIndex';
    return Column(
      children: List.generate(8, (actionIndex) {
        final key = '${themeId}_$actionIndex';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CupertinoTextField(
            controller: _actionControllers[key],
            placeholder: '세부 목표 ${actionIndex + 1}',
          ),
        );
      }),
    );
  }
}

extension on ActionItemModel {
  static ActionItemModel initial(String themeId, int order) {
    final now = DateTime.now();
    return ActionItemModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      themeId: themeId,
      actionText: '',
      status: ActionStatus.notStarted,
      order: order,
      createdAt: now,
      updatedAt: now,
    );
  }
}

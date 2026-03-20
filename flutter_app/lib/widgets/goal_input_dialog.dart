import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';

class GoalInputDialog extends ConsumerStatefulWidget {
  final bool isNew;
  const GoalInputDialog({super.key, this.isNew = false});

  @override
  ConsumerState<GoalInputDialog> createState() => _GoalInputDialogState();
}

class _GoalInputDialogState extends ConsumerState<GoalInputDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(mandalartProvider);
    _nameController = TextEditingController(text: state.displayName);
    _goalController = TextEditingController(text: state.goalText);
    _checkInput();

    _nameController.addListener(_checkInput);
    _goalController.addListener(_checkInput);
  }

  void _checkInput() {
    setState(() {
      _canSubmit = _goalController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSubmit) return;

    HapticFeedback.mediumImpact();
    ref
        .read(mandalartProvider.notifier)
        .updateDisplayName(_nameController.text.trim());
    ref
        .read(mandalartProvider.notifier)
        .updateGoal(_goalController.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(themeProvider).primaryColor;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.isNew ? '새로운 만다라트' : '만다라트 설정'),
        leading: widget.isNew
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('취소'),
                onPressed: () => Navigator.pop(context),
              ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _canSubmit ? _submit : null,
          child: Text(
            '완료',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _canSubmit ? primaryColor : CupertinoColors.systemGrey,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.info_circle_fill, color: primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '만다라트의 이름과 가장 중요한 핵심 목표를 설정해주세요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.label.resolveFrom(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Field 1: Name
            Text(
              '만다라트 이름',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _nameController,
              placeholder: '예: 2024년 갓생살기',
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground
                    .resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 24),

            // Field 2: Core Goal
            Row(
              children: [
                Text(
                  '핵심 목표',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(color: CupertinoColors.activeOrange),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _goalController,
              placeholder: '최종적으로 이루고 싶은 꿈 (예: 100억 부자)',
              padding: const EdgeInsets.all(16),
              minLines: 1,
              maxLines: 3,
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground
                    .resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),

            const SizedBox(height: 40),
            if (widget.isNew)
              CupertinoButton.filled(
                onPressed: _canSubmit ? _submit : null,
                child: const Text('시작하기'),
              ),
          ],
        ),
      ),
    );
  }
}

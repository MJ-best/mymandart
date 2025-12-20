import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';

class NewMandalartScreen extends ConsumerStatefulWidget {
  const NewMandalartScreen({super.key});

  @override
  ConsumerState<NewMandalartScreen> createState() => _NewMandalartScreenState();
}

class _NewMandalartScreenState extends ConsumerState<NewMandalartScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _goalController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        middle: const Text('만다라트 만들기'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text(
              '어떤 목표를\n이루고 싶으신가요?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '성공적인 계획을 위해 핵심 주제를 입력해주세요.',
              style: TextStyle(fontSize: 15, color: CupertinoColors.secondaryLabel),
            ),
            const SizedBox(height: 32),
            CupertinoTextField(
              controller: _titleController,
              placeholder: '예: 2024년 갓생 프로젝트',
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),
            CupertinoTextField(
              controller: _goalController,
              placeholder: '예: 바디프로필 촬영 성공',
               padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            _buildKeywords(),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: () {
                final notifier = ref.read(mandalartProvider.notifier);
                notifier.updateDisplayName(_titleController.text);
                notifier.updateGoal(_goalController.text);
                context.go('/detail');
              },
              child: const Text('만다라트 생성하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywords() {
    final keywords = ['이직 성공', '체지방 15%', '유럽 여행', '책 50권'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keywords.map((keyword) {
        return CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
          onPressed: () {
            _goalController.text = keyword;
          },
          child: Text(
            keyword,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.label,
            ),
          ),
        );
      }).toList(),
    );
  }
}

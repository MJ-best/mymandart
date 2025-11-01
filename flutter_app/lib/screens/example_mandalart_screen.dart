import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarart_journey/data/ohtani_example.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';

/// 오타니 쇼헤이의 만다라트 예시를 보여주는 화면
class ExampleMandalartScreen extends ConsumerWidget {
  const ExampleMandalartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(themeProvider).primaryColor;
    final exampleData = OhtaniMandalartExample.data;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            // 상단 안내 영역
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '오타니 쇼헤이의 만다라트 예시',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: CupertinoColors.systemGrey,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '각 영역을 클릭해서 구체적인 액션을 확인해보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),

            // 만다라트 뷰어
            Expanded(
              child: _ExampleMandalartViewer(data: exampleData),
            ),

            // 하단 버튼 영역
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                      GoRouter.of(context).go('/create');
                    },
                    child: const Text(
                      '내 만다라트 만들기',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '돌아가기',
                      style: TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 예시 데이터를 표시하는 만다라트 뷰어 (읽기 전용)
class _ExampleMandalartViewer extends StatefulWidget {
  final MandalartStateModel data;

  const _ExampleMandalartViewer({required this.data});

  @override
  State<_ExampleMandalartViewer> createState() => _ExampleMandalartViewerState();
}

class _ExampleMandalartViewerState extends State<_ExampleMandalartViewer> {
  int? _selectedThemeIndex;

  List<ActionItemModel> _getActionsForTheme(int themeIndex) {
    return widget.data.actionItems
        .where((a) => a.themeId == 'theme-$themeIndex')
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    if (_selectedThemeIndex != null) {
      // 특정 테마의 액션 보기
      final primaryColor = CupertinoTheme.of(context).primaryColor;
      return _buildActionView(context, _selectedThemeIndex!, primaryColor);
    } else {
      // 전체 만다라트 보기
      return _buildMandalartGrid(context, isPortrait);
    }
  }

  Widget _buildMandalartGrid(BuildContext context, bool isPortrait) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isPortrait ? 500 : 700,
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                if (index == 4) {
                  // 중심 목표
                  return _buildCenterCell(widget.data.goalText, primaryColor);
                } else {
                  // 테마 영역
                  final themeIndex = index < 4 ? index : index - 1;
                  return _buildThemeCell(context, themeIndex, primaryColor);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterCell(String goalText, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            goalText,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCell(BuildContext context, int themeIndex, Color primaryColor) {
    final theme = widget.data.themes[themeIndex];
    final actions = _getActionsForTheme(themeIndex);
    final completedCount = actions.where((a) => a.isCompleted).length;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedThemeIndex = themeIndex;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  theme,
                  style: const TextStyle(
                    color: CupertinoColors.label,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (actions.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$completedCount/${actions.length}',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionView(BuildContext context, int themeIndex, Color primaryColor) {
    final theme = widget.data.themes[themeIndex];
    final actions = _getActionsForTheme(themeIndex);

    return Column(
      children: [
        // 헤더
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedThemeIndex = null;
                  });
                },
                child: Icon(
                  CupertinoIcons.back,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${actions.length}가지 구체적 행동',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 액션 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        action.actionText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

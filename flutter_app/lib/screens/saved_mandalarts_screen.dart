import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/screens/landing_screen.dart';

class SavedMandalartsScreen extends ConsumerStatefulWidget {
  const SavedMandalartsScreen({super.key});

  @override
  ConsumerState<SavedMandalartsScreen> createState() => _SavedMandalartsScreenState();
}

class _SavedMandalartsScreenState extends ConsumerState<SavedMandalartsScreen> {
  List<SavedMandalartMeta> _savedMandalarts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedMandalarts();
  }

  Future<void> _loadSavedMandalarts() async {
    setState(() => _isLoading = true);
    final mandalarts = await ref.read(mandalartProvider.notifier).getSavedMandalarts();
    setState(() {
      _savedMandalarts = mandalarts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Text('저장된 만다라트'),
          ],
        ),
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
          child: const Icon(CupertinoIcons.chevron_left),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _savedMandalarts.isEmpty
                ? _buildEmptyState()
                : _buildMandalartList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.square_grid_3x2,
              size: 64,
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
            const SizedBox(height: 16),
            Text(
              '저장된 만다라트가 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '만다라트를 완성하고 저장해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMandalartList() {
    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 16)),
        // 새 만다라트 시작 버튼
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                showCupertinoModalPopup(
                  context: context,
                  builder: (dialogContext) => LandingScreen(
                    isModal: true,
                    onComplete: () async {
                      await ref.read(mandalartProvider.notifier).startNewMandalart();
                      if (mounted && context.mounted) {
                        context.pop(); // 저장된 만다라트 화면 닫기
                      }
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemPurple.withOpacity(0.15),
                      CupertinoColors.systemIndigo.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.systemPurple.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: CupertinoColors.systemPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '새 만다라트 시작',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final mandalart = _savedMandalarts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildMandalartCard(mandalart),
              );
            },
            childCount: _savedMandalarts.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }

  Widget _buildMandalartCard(SavedMandalartMeta meta) {
    final progressPercent = meta.totalCount > 0
        ? (meta.completedCount / meta.totalCount * 100).toInt()
        : 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _loadMandalart(meta.id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.resolveFrom(context).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meta.displayName.trim().isNotEmpty
                        ? meta.displayName.trim()
                        : '제목 없음',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(30, 30),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showDeleteDialog(meta);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.destructiveRed,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.xmark,
                      size: 12,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (meta.goalText.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                meta.goalText.trim(),
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5.resolveFrom(context),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: meta.totalCount > 0
                          ? (meta.completedCount / meta.totalCount).clamp(0.0, 1.0)
                          : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemPurple,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$progressPercent%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemPurple.resolveFrom(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${meta.completedCount}/${meta.totalCount} 완료',
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                Text(
                  _formatDate(meta.updatedAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) {
      return '오늘';
    } else if (diff == 1) {
      return '어제';
    } else if (diff < 7) {
      return '$diff일 전';
    } else {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _loadMandalart(String id) async {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CupertinoActivityIndicator()),
    );

    await ref.read(mandalartProvider.notifier).loadMandalart(id);

    if (mounted) {
      context.pop(); // 로딩 다이얼로그 닫기
      context.pop(); // 저장된 만다라트 화면 닫기 (이전 화면으로 돌아감)
    }
  }

  void _showDeleteDialog(SavedMandalartMeta meta) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('만다라트 삭제'),
        content: Text('${meta.displayName.trim().isNotEmpty ? meta.displayName.trim() : "이 만다라트"}를 삭제하시겠습니까?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(mandalartProvider.notifier).deleteMandalart(meta.id);
              await _loadSavedMandalarts();
              if (mounted) {
                HapticFeedback.mediumImpact();
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

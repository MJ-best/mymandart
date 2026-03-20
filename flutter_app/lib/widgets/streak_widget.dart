import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarart_journey/models/streak.dart';
import 'package:mandarart_journey/providers/streak_provider.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';

class StreakWidget extends ConsumerWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final brightness = CupertinoTheme.brightnessOf(context);
    final isDark = brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final success = await ref.read(streakProvider.notifier).checkIn();
        if (!context.mounted) return;
        if (success) {
          HapticFeedback.mediumImpact();
          _showCheckInSuccess(context, ref.read(streakProvider));
        } else {
          _showAlreadyCheckedIn(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getGradientColors(streak.status, isDark),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _getPrimaryColor(streak.status, isDark)
                  .withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildStreakIcon(streak.status),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${streak.currentStreak}일 연속',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.white,
                          ),
                        ),
                        Text(
                          _getStatusText(streak.status),
                          style: TextStyle(
                            fontSize: 11,
                            color: CupertinoColors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  CupertinoIcons.hand_raised_fill,
                  color: CupertinoColors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 진행 바
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      streak.phaseDescription,
                      style: TextStyle(
                        fontSize: 10,
                        color: CupertinoColors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '최고 ${streak.longestStreak}일',
                      style: TextStyle(
                        fontSize: 9,
                        color: CupertinoColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 21일 진행바
                _buildProgressBar(
                  context,
                  ref,
                  current: streak.currentStreak.clamp(0, 21),
                  max: 21,
                  label: '21일',
                  isComplete: streak.hasReachedConscious,
                ),
                const SizedBox(height: 3),
                // 66일 진행바
                _buildProgressBar(
                  context,
                  ref,
                  current: streak.currentStreak.clamp(0, 66),
                  max: 66,
                  label: '66일',
                  isComplete: streak.hasReachedHabit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    WidgetRef ref, {
    required int current,
    required int max,
    required String label,
    required bool isComplete,
  }) {
    final primaryColor = ref.watch(themeProvider).primaryColor;
    final progress = (current / max).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: isComplete ? primaryColor : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: CupertinoColors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakIcon(StreakStatus status) {
    IconData icon;

    switch (status) {
      case StreakStatus.ash:
        icon = CupertinoIcons.circle;
        break;
      case StreakStatus.smoke:
        icon = CupertinoIcons.smoke;
        break;
      case StreakStatus.fire:
        icon = CupertinoIcons.flame;
        break;
      case StreakStatus.strongFire:
        icon = CupertinoIcons.flame_fill;
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CupertinoColors.white.withValues(alpha: 0.2),
      ),
      child: Icon(
        icon,
        color: CupertinoColors.white,
        size: 20,
      ),
    );
  }

  List<Color> _getGradientColors(StreakStatus status, bool isDark) {
    switch (status) {
      case StreakStatus.ash:
        return isDark
            ? [
                const Color(0xFF2D3139),
                const Color(0xFF23272F),
              ]
            : [
                const Color(0xFF6B7280),
                const Color(0xFF4B5563),
              ];
      case StreakStatus.smoke:
        return isDark
            ? [
                const Color(0xFF3F4451),
                const Color(0xFF2D3139),
              ]
            : [
                const Color(0xFF9CA3AF),
                const Color(0xFF6B7280),
              ];
      case StreakStatus.fire:
        return isDark
            ? [
                const Color(0xFF5A5E6B),
                const Color(0xFF4B5563),
              ]
            : [
                const Color(0xFFF97316),
                const Color(0xFFEA580C),
              ];
      case StreakStatus.strongFire:
        return isDark
            ? [
                const Color(0xFF6B7280),
                const Color(0xFF5A5E6B),
              ]
            : [
                const Color(0xFFDC2626),
                const Color(0xFFB91C1C),
              ];
    }
  }

  Color _getPrimaryColor(StreakStatus status, bool isDark) {
    switch (status) {
      case StreakStatus.ash:
        return isDark ? const Color(0xFF2D3139) : const Color(0xFF6B7280);
      case StreakStatus.smoke:
        return isDark ? const Color(0xFF3F4451) : const Color(0xFF9CA3AF);
      case StreakStatus.fire:
        return isDark ? const Color(0xFF5A5E6B) : const Color(0xFFF97316);
      case StreakStatus.strongFire:
        return isDark ? const Color(0xFF6B7280) : const Color(0xFFDC2626);
    }
  }

  String _getStatusText(StreakStatus status) {
    switch (status) {
      case StreakStatus.ash:
        return '재만 남음 - 다시 시작하세요';
      case StreakStatus.smoke:
        return '연기만 남음 - 오늘 다시 도전!';
      case StreakStatus.fire:
        return '불이 붙었습니다!';
      case StreakStatus.strongFire:
        return '불이 활활 타오릅니다!';
    }
  }

  void _showCheckInSuccess(BuildContext context, StreakModel streak) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('출석 완료!'),
          ],
        ),
        content: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              '${streak.currentStreak}일 연속 출석 중입니다.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              streak.phaseDescription,
              style: TextStyle(
                fontSize: 14,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showAlreadyCheckedIn(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('이미 출석했습니다'),
        content: const Text('오늘은 이미 출석 체크를 완료했습니다.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

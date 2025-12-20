import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDate = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _changeMonth(int offset) {
    HapticFeedback.selectionClick();
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + offset);
    });
  }

  void _selectDate(DateTime date) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mandalartProvider);
    final primaryColor = ref.watch(themeProvider).primaryColor;

    final logsByDate = _getLogsByDate(state);
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final selectedDayLogs = logsByDate[selectedDateStr] ?? [];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        middle: Text(DateFormat('yyyy년 M월').format(_focusedDate)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.calendar_today),
          onPressed: () {
            HapticFeedback.selectionClick();
            final now = DateTime.now();
            setState(() {
              _focusedDate = DateTime(now.year, now.month);
              _selectedDate = now;
            });
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            _buildCalendarControls(),
            _buildWeekdayHeaders(),
            _buildMonthGrid(logsByDate, primaryColor),
            const SizedBox(height: 24),
            _buildSelectedDayLogs(selectedDayLogs, state, primaryColor),
          ],
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _getLogsByDate(MandalartStateModel state) {
    final Map<String, List<Map<String, dynamic>>> logsByDate = {};
    for (var item in state.actionItems) {
      if (item.startedAt != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(item.startedAt!);
        logsByDate.putIfAbsent(dateStr, () => []).add({'type': 'start', 'item': item});
      }
      if (item.completedAt != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(item.completedAt!);
        logsByDate.putIfAbsent(dateStr, () => []).add({'type': 'complete', 'item': item});
      }
    }
    return logsByDate;
  }

  Widget _buildCalendarControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _changeMonth(-1),
            child: const Icon(CupertinoIcons.chevron_left),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _changeMonth(1),
            child: const Icon(CupertinoIcons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
          return SizedBox(
            width: 32,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: day == '일'
                    ? CupertinoColors.systemRed
                    : CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthGrid(Map<String, List<Map<String, dynamic>>> logs, Color primaryColor) {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final prevMonthDays = (firstDayOfMonth.weekday % 7);
    const totalCells = 42;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.3,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - prevMonthDays;
        final date = DateTime(_focusedDate.year, _focusedDate.month, 1 + dayOffset);
        final isCurrentMonth = date.month == _focusedDate.month;

        if (!isCurrentMonth) {
          return const SizedBox.shrink();
        }

        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final dayLogs = logs[dateStr] ?? [];
        final hasActivity = dayLogs.isNotEmpty;
        final isSelected = _isSameDay(date, _selectedDate);
        final isToday = _isSameDay(date, DateTime.now());

        return GestureDetector(
          onTap: () => _selectDate(date),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? primaryColor
                  : (hasActivity ? primaryColor.withOpacity(0.15) : const Color(0x00000000)),
              border: isToday && !isSelected ? Border.all(color: primaryColor.withOpacity(0.5), width: 1) : null,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected
                        ? CupertinoColors.white
                        : (hasActivity ? primaryColor : CupertinoColors.label.resolveFrom(context)),
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                if (hasActivity && !isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayLogs(List<Map<String, dynamic>> logs, MandalartStateModel state, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${DateFormat('M월 d일 (E)', 'ko_KR').format(_selectedDate)} 활동',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: CupertinoColors.label),
        ),
        const SizedBox(height: 12),
        if (logs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '기록된 활동이 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 14),
            ),
          )
        else
          ...logs.map((event) {
            final item = event['item'] as ActionItemModel;
            final isStart = event['type'] == 'start';
            final themeIndex = int.tryParse(item.themeId.split('-').last) ?? -1;
            final themeText = (themeIndex >= 0 && themeIndex < state.themes.length) ? state.themes[themeIndex] : '';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${isStart ? "시작" : "완료"}: ${item.actionText}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: CupertinoColors.label),
                        ),
                        if (themeText.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            themeText,
                            style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                          ),
                        ]
                      ],
                    ),
                  ),
                  Icon(
                    isStart ? CupertinoIcons.play_circle : CupertinoIcons.check_mark_circled_solid,
                    color: isStart ? CupertinoColors.secondaryLabel.resolveFrom(context) : primaryColor,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

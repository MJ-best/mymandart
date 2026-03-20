import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';

class CalendarStep extends ConsumerStatefulWidget {
  const CalendarStep({super.key});

  @override
  ConsumerState<CalendarStep> createState() => _CalendarStepState();
}

class _CalendarStepState extends ConsumerState<CalendarStep> {
  static const Color _primaryAccentColor = Color(0xFF7EA8F8);
  static const Color _statusExecColor = Color(0xFFF2E77C);
  static const Color _statusDoneColor = Color(0xFF7BC8A4);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final logsByDate = _buildLogsByDate(state.actionItems);
    final totalEvents = logsByDate.values.fold<int>(
      0,
      (sum, events) => sum + events.length,
    );
    final completedEvents = state.actionItems.where((item) {
      return item.completedAt != null && item.actionText.trim().isNotEmpty;
    }).length;
    final activeDays = logsByDate.keys.length;
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final selectedDayLogs = logsByDate[selectedDateStr] ?? const [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wideLayout = constraints.maxWidth >= 980;
        final headerMetricWidth = wideLayout ? 180.0 : double.infinity;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E425D)
                      : const Color(0xFFE1D9D0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACTIVITY CALENDAR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: isDark
                                ? const Color(0xFFF2E77C)
                                : const Color(0xFF8C8B5F),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '실행과 완료의 흐름을 날짜별로 확인해요.',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${DateFormat('yyyy년 M월').format(_focusedDate)}에 기록된 진행 로그를 한눈에 볼 수 있습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.68),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: headerMetricWidth,
                    child: _MetricCard(
                      label: '전체 이벤트',
                      value: '$totalEvents',
                      helper: '시작 + 완료',
                      accent: primaryColor,
                    ),
                  ),
                  SizedBox(
                    width: headerMetricWidth,
                    child: _MetricCard(
                      label: '활동한 날짜',
                      value: '$activeDays',
                      helper: '기록된 일수',
                      accent: _statusExecColor,
                    ),
                  ),
                  SizedBox(
                    width: headerMetricWidth,
                    child: _MetricCard(
                      label: '완료 횟수',
                      value: '$completedEvents',
                      helper: 'completed',
                      accent: _statusDoneColor,
                    ),
                  ),
                ],
              ),
            ),
            if (wideLayout)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: _buildCalendarPanel(
                      context: context,
                      logsByDate: logsByDate,
                      primaryColor: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 8,
                    child: _buildSelectedDayPanel(
                      context,
                      state,
                      selectedDayLogs,
                    ),
                  ),
                ],
              )
            else ...[
              _buildCalendarPanel(
                context: context,
                logsByDate: logsByDate,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 20),
              _buildSelectedDayPanel(
                context,
                state,
                selectedDayLogs,
              ),
            ],
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Map<String, List<Map<String, dynamic>>> _buildLogsByDate(
    List<ActionItemModel> items,
  ) {
    final logsByDate = <String, List<Map<String, dynamic>>>{};

    for (final item in items) {
      if (item.startedAt != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(item.startedAt!);
        logsByDate.putIfAbsent(dateStr, () => []);
        logsByDate[dateStr]!.add({
          'type': 'start',
          'item': item,
          'occurredAt': item.startedAt!,
        });
      }
      if (item.completedAt != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(item.completedAt!);
        logsByDate.putIfAbsent(dateStr, () => []);
        logsByDate[dateStr]!.add({
          'type': 'complete',
          'item': item,
          'occurredAt': item.completedAt!,
        });
      }
    }

    for (final entry in logsByDate.entries) {
      entry.value.sort((a, b) {
        final aTime = a['occurredAt'] as DateTime;
        final bTime = b['occurredAt'] as DateTime;
        return bTime.compareTo(aTime);
      });
    }

    return logsByDate;
  }

  Widget _buildCalendarPanel({
    required BuildContext context,
    required Map<String, List<Map<String, dynamic>>> logsByDate,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MonthButton(
                icon: CupertinoIcons.chevron_left,
                onPressed: () => _changeMonth(-1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedDate),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '날짜를 선택해 해당 날의 실행 흐름을 확인하세요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.62),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _MonthButton(
                icon: CupertinoIcons.chevron_right,
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children:
                ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((day) {
              final isSunday = day == 'SUN';
              return Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: isSunday
                        ? CupertinoColors.systemRed
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _buildMonthGrid(logsByDate, primaryColor, context),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _LegendChip(
                label: '선택한 날짜',
                background: _CalendarStepState._primaryAccentColor,
                foreground: Colors.white,
              ),
              _LegendChip(
                label: '활동 있음',
                background: Color(0x1F7EA8F8),
                foreground: _CalendarStepState._primaryAccentColor,
              ),
              _LegendChip(
                label: '오늘',
                background: Color(0x14F2E77C),
                foreground: Color(0xFF8C8B5F),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayPanel(
    BuildContext context,
    MandalartStateModel state,
    List<Map<String, dynamic>> selectedDayLogs,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECTED DAY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('M월 d일 (E)').format(_selectedDate),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedDayLogs.isEmpty
                ? '아직 기록이 없습니다.'
                : '${selectedDayLogs.length}개의 흐름이 기록되어 있습니다.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 18),
          if (selectedDayLogs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.calendar_today,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 28,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '이 날짜에는 아직 시작이나 완료 기록이 없어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          else
            ...selectedDayLogs.map((event) {
              final item = event['item'] as ActionItemModel;
              final type = event['type'] as String;
              final occurredAt = event['occurredAt'] as DateTime;
              final isStart = type == 'start';
              final themeIndex =
                  int.tryParse(item.themeId.split('-').last) ?? -1;
              final themeText =
                  (themeIndex >= 0 && themeIndex < state.themes.length)
                      ? state.themes[themeIndex].themeText
                      : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isStart
                        ? _statusExecColor.withValues(alpha: 0.35)
                        : _statusDoneColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isStart
                            ? _statusExecColor.withValues(alpha: 0.18)
                            : _statusDoneColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isStart
                            ? CupertinoIcons.play_fill
                            : CupertinoIcons.check_mark,
                        size: 18,
                        color: isStart ? _statusExecColor : _statusDoneColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isStart
                                      ? _statusExecColor.withValues(alpha: 0.16)
                                      : _statusDoneColor.withValues(
                                          alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  isStart ? 'STARTED' : 'COMPLETED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: isStart
                                        ? _statusExecColor
                                        : _statusDoneColor,
                                  ),
                                ),
                              ),
                              Text(
                                DateFormat('a h:mm').format(occurredAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.56),
                                ),
                              ),
                            ],
                          ),
                          if (themeText.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              themeText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.56),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            item.actionText.trim().isEmpty
                                ? '새 액션'
                                : item.actionText.trim(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(
    Map<String, List<Map<String, dynamic>>> logs,
    Color primaryColor,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final prevMonthDays = firstDayOfMonth.weekday % 7;
    const totalCells = 42;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.92,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - prevMonthDays;
        final date =
            DateTime(_focusedDate.year, _focusedDate.month, 1 + dayOffset);
        final isCurrentMonth = date.month == _focusedDate.month;

        if (!isCurrentMonth) {
          return const SizedBox.shrink();
        }

        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final dayLogs = logs[dateStr] ?? const [];
        final hasActivity = dayLogs.isNotEmpty;
        final completedCount =
            dayLogs.where((event) => event['type'] == 'complete').length;
        final isSelected = _CalendarDateUtils.isSameDay(date, _selectedDate);
        final isToday = _CalendarDateUtils.isSameDay(date, DateTime.now());
        final backgroundColor = isSelected
            ? primaryColor
            : hasActivity
                ? primaryColor.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _selectDate(date),
            child: Ink(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : isToday
                          ? _statusExecColor.withValues(alpha: 0.55)
                          : hasActivity
                              ? primaryColor.withValues(alpha: 0.18)
                              : colorScheme.outline.withValues(alpha: 0.12),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected
                                ? (theme.brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white)
                                : colorScheme.onSurface,
                            fontWeight: isSelected || isToday
                                ? FontWeight.w800
                                : FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        if (isToday)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.white : _statusExecColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    if (hasActivity)
                      Text(
                        '${dayLogs.length}개 이벤트',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? (theme.brightness == Brightness.dark
                                  ? Colors.black.withValues(alpha: 0.72)
                                  : Colors.white.withValues(alpha: 0.88))
                              : colorScheme.onSurface.withValues(alpha: 0.66),
                        ),
                      )
                    else
                      Text(
                        '기록 없음',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    const SizedBox(height: 6),
                    if (hasActivity)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.28)
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: dayLogs.isEmpty
                                      ? 0
                                      : completedCount / dayLogs.length,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : _statusDoneColor,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.accent,
  });

  final String label;
  final String value;
  final String helper;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: accent,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _CalendarDateUtils {
  static bool isSameDay(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year &&
        dateA?.month == dateB?.month &&
        dateA?.day == dateB?.day;
  }
}

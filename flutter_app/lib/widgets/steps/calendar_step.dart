import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';
import 'package:mandarart_journey/models/mandalart.dart';

class CalendarStep extends ConsumerStatefulWidget {
  const CalendarStep({super.key});

  @override
  ConsumerState<CalendarStep> createState() => _CalendarStepState();
}

class _CalendarStepState extends ConsumerState<CalendarStep> {
  late DateTime _focusedDate; // Month view focus
  late DateTime _selectedDate; // Selected day for viewing logs

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
      _focusedDate = DateTime(
        _focusedDate.year,
        _focusedDate.month + offset,
      );
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

    // Event wrapper to distinguish start vs complete
    final Map<String, List<Map<String, dynamic>>> logsByDate = {}; // {'type': 'start'|'complete', 'item': ActionItemModel}
    
    for (var item in state.actionItems) {
      if (item.startedAt != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(item.startedAt!);
        logsByDate.putIfAbsent(dateStr, () => []);
        logsByDate[dateStr]!.add({'type': 'start', 'item': item});
      }
      if (item.completedAt != null) {
         final dateStr = DateFormat('yyyy-MM-dd').format(item.completedAt!);
         logsByDate.putIfAbsent(dateStr, () => []);
         logsByDate[dateStr]!.add({'type': 'complete', 'item': item});
      }
    }
    
    // Calculate total distinct completed items for the header count (or total events?)
    // User asked to record start. Let's show "Total X Events" or keep "X Completed"?
    // User text: "X goals completed" (original).
    // Let's change to "X Started / Y Completed" or just total activities.
    // Let's stick to "X Activities Recorded" ("X개의 활동 기록")
    int totalEvents = 0;
    logsByDate.forEach((_, events) => totalEvents += events.length);

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final selectedDayLogs = logsByDate[selectedDateStr] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header ---
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
               Text(
                 '나의 발자취',
                 style: TextStyle(
                   fontSize: 14,
                   fontWeight: FontWeight.w600,
                   color: CupertinoColors.secondaryLabel.resolveFrom(context),
                 ),
               ),
               const SizedBox(height: 4),
               Text(
                  '$totalEvents개의 활동 기록',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
            ],
          ),
        ),

        // --- Calendar Control ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _changeMonth(-1),
                child: const Icon(CupertinoIcons.chevron_left),
              ),
              Text(
                DateFormat('yyyy년 M월').format(_focusedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _changeMonth(1),
                child: const Icon(CupertinoIcons.chevron_right),
              ),
            ],
          ),
        ),
        
        // --- Weekday Headers ---
        Padding(
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
        ),

        // --- Calendar Grid ---
        _buildMonthGrid(logsByDate, primaryColor),
        
        const SizedBox(height: 32),
        
        // --- Selected Date Logs ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '${DateFormat('M월 d일 (E)', 'ko_KR').format(_selectedDate)} 활동',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.label,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (selectedDayLogs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '달성한 목표가 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 14,
              ),
            ),
          )
        else
          ...selectedDayLogs.map((event) {
             final item = event['item'] as ActionItemModel;
             final type = event['type'] as String;
             final isStart = type == 'start';

             // Find theme text
             final themeIndex = int.tryParse(item.themeId.split('-').last) ?? -1;
             final themeText = (themeIndex >= 0 && themeIndex < state.themes.length)
                 ? state.themes[themeIndex]
                 : '';
                 
             return Container(
               margin: const EdgeInsets.only(bottom: 8),
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                 borderRadius: BorderRadius.circular(12),
                 border: Border(
                   left: BorderSide(
                     color: isStart ? primaryColor.withValues(alpha: 0.5) : primaryColor, 
                     width: 4
                   )
                 ),
               ),
               child: Row(
                 children: [
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                               decoration: BoxDecoration(
                                 color: isStart 
                                    ? CupertinoColors.systemGrey5.resolveFrom(context)
                                    : primaryColor.withValues(alpha: 0.1),
                                 borderRadius: BorderRadius.circular(4),
                               ),
                               child: Text(
                                 isStart ? '시작' : '완료',
                                 style: TextStyle(
                                   fontSize: 10,
                                   fontWeight: FontWeight.bold,
                                   color: isStart ? CupertinoColors.secondaryLabel : primaryColor,
                                 ),
                               ),
                             ),
                             const SizedBox(width: 6),
                             if (themeText.isNotEmpty)
                               Text(
                                 themeText,
                                 style: TextStyle(
                                   fontSize: 12,
                                   color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                 ),
                               ),
                           ],
                         ),
                         const SizedBox(height: 4),
                         Text(
                           item.actionText.isEmpty ? '새로운 목표' : item.actionText,
                           style: const TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.w500,
                             color: CupertinoColors.label,
                           ),
                         ),
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
          
        // Extra space for scrolling
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMonthGrid(Map<String, List<Map<String, dynamic>>> logs, Color primaryColor) {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final prevMonthDays = (firstDayOfMonth.weekday % 7); // Sunday = 0
    final totalCells = 42; // 6 rows * 7 cols

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4, // Reduced from 8
        crossAxisSpacing: 4, // Reduced from 8
        childAspectRatio: 1.3, // Compressed vertical height
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
        final isSelected = DateUtils.isSameDay(date, _selectedDate);
        final isToday = DateUtils.isSameDay(date, DateTime.now());

        return GestureDetector(
          onTap: () => _selectDate(date),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected 
                  ? primaryColor 
                  : (hasActivity ? primaryColor.withValues(alpha: 0.15) : const Color(0x00000000)),
              border: isToday && !isSelected
                  ? Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1)
                  : null,
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
                    fontSize: 13, // Slightly smaller font
                  ),
                ),
                if (hasActivity && !isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 3, // Smaller dot
                    height: 3,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper needed because Flutter's DateUtils isn't fully available/reliable in straight Cupertino context sometimes or strict analysis
class DateUtils {
  static bool isSameDay(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year &&
        dateA?.month == dateB?.month &&
        dateA?.day == dateB?.day;
  }
}

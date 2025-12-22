import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';

import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/utils/app_theme.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

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
    
    int totalEvents = 0;
    logsByDate.forEach((_, events) => totalEvents += events.length);

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final selectedDayLogs = logsByDate[selectedDateStr] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header ---
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF333220) : const Color(0xFFE6E6DB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
               Text(
                 'TOTAL ACTIVITIES',
                 style: TextStyle(
                   fontSize: 12,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 1.2,
                   color: isDark ? const Color(0xFF8C8B5F) : const Color(0xFF8C8B5F),
                 ),
               ),
               const SizedBox(height: 8),
               Text(
                  '$totalEvents',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    height: 1.0,
                  ),
                ),
               const SizedBox(height: 4),
               Text(
                 'Recorded actions',
                 style: TextStyle(
                   fontSize: 14,
                   color: colorScheme.onSurface.withValues(alpha: 0.6),
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
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _changeMonth(-1),
                icon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedDate),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _changeMonth(1),
                icon: Icon(Icons.chevron_right, color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
        
        // --- Weekday Headers ---
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: day == 'S' 
                        ? CupertinoColors.systemRed 
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // --- Calendar Grid ---
        _buildMonthGrid(logsByDate, primaryColor, context),
        
        const SizedBox(height: 32),
        
        // --- Selected Date Logs ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            DateFormat('MMMM d (E)').format(_selectedDate),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (selectedDayLogs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'No activities recorded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
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
                 ? state.themes[themeIndex].themeText
                 : '';
                 
             return Container(
               margin: const EdgeInsets.only(bottom: 8),
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: colorScheme.surface,
                 borderRadius: BorderRadius.circular(16),
                 border: Border.all(
                   color: colorScheme.outline.withValues(alpha: 0.2),
                 ),
                 boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                 ]
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
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                 color: isStart 
                                    ? colorScheme.surfaceContainerHighest
                                    : primaryColor.withValues(alpha: 0.1),
                                 borderRadius: BorderRadius.circular(6),
                               ),
                               child: Text(
                                 isStart ? 'STARTED' : 'COMPLETED',
                                 style: TextStyle(
                                   fontSize: 10,
                                   fontWeight: FontWeight.bold,
                                   color: isStart ? colorScheme.onSurfaceVariant : primaryColor,
                                   letterSpacing: 0.5,
                                 ),
                               ),
                             ),
                             const SizedBox(width: 8),
                             if (themeText.isNotEmpty)
                               Expanded(
                                 child: Text(
                                   themeText,
                                   style: TextStyle(
                                     fontSize: 12,
                                     color: colorScheme.onSurface.withValues(alpha: 0.6),
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                               ),
                           ],
                         ),
                         const SizedBox(height: 8),
                         Text(
                           item.actionText.isEmpty ? 'New Goal' : item.actionText,
                           style: TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.w600,
                             color: colorScheme.onSurface,
                           ),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(width: 12),
                   Container(
                     width: 32, 
                     height: 32,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: isStart ? Colors.transparent : primaryColor,
                       border: isStart ? Border.all(color: AppTheme.statusExec, width: 2) : null,
                     ),
                     alignment: Alignment.center,
                     child: Icon(
                       isStart ? Icons.play_arrow : Icons.check,
                       color: isStart ? AppTheme.statusExec : Colors.white,
                       size: 16,
                     ),
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

  Widget _buildMonthGrid(Map<String, List<Map<String, dynamic>>> logs, Color primaryColor, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final prevMonthDays = (firstDayOfMonth.weekday % 7); // Sunday = 0
    const totalCells = 42; // 6 rows * 7 cols

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0, 
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
                  : (hasActivity ? primaryColor.withValues(alpha: 0.15) : Colors.transparent),
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
                        ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white) 
                        : (hasActivity ? primaryColor : colorScheme.onSurface),
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14, 
                  ),
                ),
                if (hasActivity && !isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4, 
                    height: 4,
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

class DateUtils {
  static bool isSameDay(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year &&
        dateA?.month == dateB?.month &&
        dateA?.day == dateB?.day;
  }
}

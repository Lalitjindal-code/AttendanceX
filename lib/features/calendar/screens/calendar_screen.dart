import 'package:attendancex/core/enums/attendance_status.dart';
import 'package:attendancex/features/calendar/providers/calendar_provider.dart';
import 'package:attendancex/features/calendar/widgets/daily_attendance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarStateAsync = ref.watch(calendarNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: calendarStateAsync.when(
        data: (state) {
          return Column(
            children: [
              TableCalendar<AttendanceStatus>(
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2030, 12, 31),
                focusedDay: state.focusedDate,
                selectedDayPredicate: (day) => isSameDay(state.selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  ref.read(calendarSelectedDateProvider.notifier).setDate(selectedDay);
                  ref.read(calendarFocusedDateProvider.notifier).setDate(focusedDay);
                },
                onPageChanged: (focusedDay) {
                  ref.read(calendarFocusedDateProvider.notifier).setDate(focusedDay);
                },
                eventLoader: (day) {
                  final normalizedDate = DateTime(day.year, day.month, day.day);
                  return state.attendanceMarkers[normalizedDate] ?? [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox();

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.take(4).map((status) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStatusColor(status),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const Divider(),
              Expanded(
                child: state.selectedDayDetails.items.isEmpty
                    ? Center(
                        child: Text(
                          'No classes scheduled for ${DateFormat('MMMM d, yyyy').format(state.selectedDate)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.selectedDayDetails.items.length,
                        itemBuilder: (context, index) {
                          final item = state.selectedDayDetails.items[index];
                          return DailyAttendanceCard(
                            item: item,
                            date: state.selectedDate,
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.medical:
        return Colors.orange;
      case AttendanceStatus.holiday:
        return Colors.blue;
      case AttendanceStatus.gt:
        return Colors.purple;
      case AttendanceStatus.pending:
        return Colors.grey;
    }
  }
}

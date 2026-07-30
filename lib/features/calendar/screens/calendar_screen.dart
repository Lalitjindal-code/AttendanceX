import 'package:attendancex/core/enums/attendance_status.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/features/attendance/providers/attendance_providers.dart';
import 'package:attendancex/features/calendar/models/calendar_state.dart';
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
                  ref.read(calendarVisibleMonthProvider.notifier).setMonth(focusedDay);
                },
                onDayLongPressed: (selectedDay, focusedDay) {
                  final isFuture = selectedDay.isAfter(DateTime.now());
                  if (isFuture) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot mark attendance for future dates')),
                    );
                    return;
                  }
                  
                  ref.read(calendarSelectedDateProvider.notifier).setDate(selectedDay);
                  ref.read(calendarFocusedDateProvider.notifier).setDate(focusedDay);
                  _showAddManualAttendanceDialog(context, ref, state, selectedDay);
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

  void _showAddManualAttendanceDialog(
      BuildContext context, WidgetRef ref, CalendarState state, DateTime date) {
    if (state.allSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subjects available. Please add a subject first.')),
      );
      return;
    }

    Subject? selectedSubject;
    AttendanceStatus? selectedStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Manual Attendance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Subject>(
                    decoration: const InputDecoration(labelText: 'Subject'),
                    value: selectedSubject,
                    items: state.allSubjects.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedSubject = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AttendanceStatus>(
                    decoration: const InputDecoration(labelText: 'Status'),
                    value: selectedStatus,
                    items: AttendanceStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStatusColor(status),
                              ),
                            ),
                            Text(status.name.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedStatus = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedSubject != null && selectedStatus != null
                      ? () {
                          final repo = ref.read(attendanceRepositoryProvider);
                          final att = Attendance()
                            ..subjectId = selectedSubject!.id
                            ..scheduleId = -1
                            ..date = DateTime(date.year, date.month, date.day)
                            ..status = selectedStatus!;
                          repo.upsertAttendance(att);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

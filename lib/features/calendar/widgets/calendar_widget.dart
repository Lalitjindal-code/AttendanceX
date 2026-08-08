import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/attendance_status.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../../settings/providers/semester_provider.dart';
import '../models/calendar_state.dart';
import '../providers/calendar_provider.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  final CalendarState state;

  const CalendarWidget({super.key, required this.state});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.state.focusedDate;
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.focusedDate != oldWidget.state.focusedDate) {
      // Only update if it was changed externally
      _focusedDay = widget.state.focusedDate;
    }
  }

  Color _getStatusColor(AttendanceStatus status, BuildContext context) {
    switch (status) {
      case AttendanceStatus.present:
        return Theme.of(context).extension<CustomColors>()?.success ??
            Colors.green;
      case AttendanceStatus.absent:
        return Theme.of(context).colorScheme.error;
      case AttendanceStatus.medical:
        return Colors.orange;
      case AttendanceStatus.holiday:
        return Theme.of(context).colorScheme.primary;
      case AttendanceStatus.gt:
        return Colors.purple;
      case AttendanceStatus.pending:
        return Theme.of(context).colorScheme.outlineVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF16162C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: TableCalendar<Object>(
        availableGestures: AvailableGestures.horizontalSwipe,
        firstDay: DateTime(2000, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
          CalendarFormat.twoWeeks: '2 Weeks',
          CalendarFormat.week: 'Week',
        },
        selectedDayPredicate: (day) =>
            isSameDay(widget.state.selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          ref.read(calendarSelectedDateProvider.notifier).setDate(selectedDay);
          ref.read(calendarFocusedDateProvider.notifier).setDate(focusedDay);
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          ref.read(calendarVisibleMonthProvider.notifier).setMonth(focusedDay);
        },
        onDayLongPressed: (selectedDay, focusedDay) {
          final isFuture = selectedDay.isAfter(DateTime.now());
          if (isFuture) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Cannot mark attendance for future dates')),
            );
            return;
          }
          ref.read(calendarSelectedDateProvider.notifier).setDate(selectedDay);
          ref.read(calendarFocusedDateProvider.notifier).setDate(focusedDay);
          _showAddManualAttendanceDialog(
              context, ref, widget.state, selectedDay);
        },
        eventLoader: (day) {
          final normalizedDate = DateTime(day.year, day.month, day.day);
          return [
            ...?widget.state.attendanceMarkers[normalizedDate],
            ...?widget.state.taskMarkers[normalizedDate],
          ];
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          outsideTextStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.3)),
          defaultTextStyle:
              const TextStyle(color: Colors.white),
          weekendTextStyle:
              TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF7E73FF),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF7E73FF).withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          markersMaxCount: 4,
          canMarkersOverflow: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: false,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: const Color(0xFF7E73FF).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          formatButtonTextStyle: const TextStyle(
            color: Color(0xFF7E73FF),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox();

            // The main fix: We wrap the dots and control max size so they don't overflow
            return Positioned(
              bottom: 4,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 40),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 2,
                  children: events.take(4).map((event) {
                    Color markerColor;
                    if (event is AttendanceStatus) {
                      markerColor = _getStatusColor(event, context);
                    } else {
                      markerColor =
                          Theme.of(context).colorScheme.primary; // Task marker
                    }
                    return Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: markerColor,
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void _showAddManualAttendanceDialog(
    BuildContext context, WidgetRef ref, CalendarState state, DateTime date) {
  if (state.allSubjects.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('No subjects available. Please add a subject first.')),
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
                  key: const Key('subject_dropdown'),
                  decoration: const InputDecoration(labelText: 'Subject'),
                  initialValue: selectedSubject,
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
                  key: const Key('status_dropdown'),
                  decoration: const InputDecoration(labelText: 'Status'),
                  initialValue: selectedStatus,
                  items: AttendanceStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
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
              FilledButton(
                onPressed: selectedSubject != null && selectedStatus != null
                    ? () {
                        final semester = ref.read(semesterStateProvider);
                        if (semester == null) return;
                        
                        final att = Attendance()
                          ..semesterId = semester.id
                          ..subjectId = selectedSubject!.id
                          ..scheduleId = null
                          ..date = DateTime(date.year, date.month, date.day)
                          ..status = selectedStatus!;

                        final repo = ref.read(attendanceRepositoryProvider);
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

// Removed the extra bracket that closed the class prematurely
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? success;

  const CustomColors({this.success});

  @override
  ThemeExtension<CustomColors> copyWith({Color? success}) {
    return CustomColors(success: success ?? this.success);
  }

  @override
  ThemeExtension<CustomColors> lerp(
      ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      success: Color.lerp(success, other.success, t),
    );
  }
}

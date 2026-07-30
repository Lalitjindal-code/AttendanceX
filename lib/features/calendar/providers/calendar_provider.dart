import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/features/attendance/providers/attendance_providers.dart';
import 'package:attendancex/features/schedule/providers/schedule_providers.dart';
import 'package:attendancex/features/subjects/providers/subject_providers.dart';
import 'package:attendancex/features/calendar/engines/calendar_engine.dart';
import 'package:attendancex/features/calendar/models/calendar_state.dart';
import 'package:attendancex/features/calendar/models/daily_attendance_details.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart' hide Subject;

part 'calendar_provider.g.dart';

@riverpod
class CalendarSelectedDate extends _$CalendarSelectedDate {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

@riverpod
class CalendarFocusedDate extends _$CalendarFocusedDate {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

@riverpod
class CalendarVisibleMonth extends _$CalendarVisibleMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void setMonth(DateTime date) {
    state = DateTime(date.year, date.month, 1);
  }
}

@riverpod
class CalendarNotifier extends _$CalendarNotifier {
  @override
  Stream<CalendarState> build() {
    final subjectRepo = ref.watch(subjectRepositoryProvider);
    final scheduleRepo = ref.watch(scheduleRepositoryProvider);
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    
    // We listen to the dates. Because this is a StreamProvider, watching these
    // will cause build() to re-run and return a new Stream when they change.
    final selectedDate = ref.watch(calendarSelectedDateProvider);
    final focusedDate = ref.watch(calendarFocusedDateProvider);
    final visibleMonth = ref.watch(calendarVisibleMonthProvider);
    
    // Calculate a buffer for TableCalendar (previous and next month visible days)
    // TableCalendar usually shows max 6 weeks (42 days) total.
    // So 1 month back and 1 month forward is plenty.
    final startDate = DateTime(visibleMonth.year, visibleMonth.month - 1, 1);
    final endDate = DateTime(visibleMonth.year, visibleMonth.month + 2, 0); // End of next month

    return Rx.combineLatest3(
      subjectRepo.watchAll(),
      scheduleRepo.watchAll(),
      attendanceRepo.watchByDateRange(startDate, endDate),
      (List<Subject> subjects, List<Schedule> schedules, List<Attendance> attendances) {
        if (subjects.isEmpty) {
          return CalendarState(
            selectedDate: selectedDate,
            focusedDate: focusedDate,
            attendanceMarkers: CalendarEngine.generateMarkers([]),
            selectedDayDetails: DailyAttendanceDetails(date: selectedDate),
            allSubjects: [],
            isLoading: false,
          );
        }

        final markers = CalendarEngine.generateMarkers(attendances);
        final details = CalendarEngine.buildDailyDetails(
          selectedDate,
          subjects,
          schedules,
          attendances,
        );

        return CalendarState(
          selectedDate: selectedDate,
          focusedDate: focusedDate,
          attendanceMarkers: markers,
          selectedDayDetails: details,
          allSubjects: subjects,
          isLoading: false,
        );
      },
    );
  }
}

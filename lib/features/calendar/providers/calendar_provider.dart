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
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}

@riverpod
class CalendarFocusedDate extends _$CalendarFocusedDate {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
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

    return Rx.combineLatest3(
      subjectRepo.watchAll(),
      scheduleRepo.watchAll(),
      attendanceRepo.watchAll(),
      (List<Subject> subjects, List<Schedule> schedules, List<Attendance> attendances) {
        if (subjects.isEmpty) {
          return CalendarState(
            selectedDate: selectedDate,
            focusedDate: focusedDate,
            attendanceMarkers: CalendarEngine.generateMarkers([]),
            selectedDayDetails: DailyAttendanceDetails(date: selectedDate),
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
          isLoading: false,
        );
      },
    );
  }
}

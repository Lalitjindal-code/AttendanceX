import 'package:attendify/database/collections/attendance_collection.dart' show Attendance;
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/features/attendance/providers/attendance_providers.dart';
import 'package:attendify/features/schedule/providers/schedule_providers.dart';
import 'package:attendify/features/subjects/providers/subject_providers.dart';
import 'package:attendify/features/planner/providers/planner_provider.dart';
import 'package:attendify/features/calendar/engines/calendar_engine.dart';
import 'package:attendify/features/calendar/models/calendar_state.dart';
import 'package:attendify/core/enums/attendance_status.dart';
import 'package:attendify/features/calendar/models/daily_attendance_details.dart';
import 'package:attendify/database/collections/academic_task_collection.dart';
import 'package:attendify/features/settings/providers/semester_provider.dart';
import 'dart:collection';
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
    final plannerRepo = ref.watch(plannerRepositoryProvider);

    // We listen to the dates. Because this is a StreamProvider, watching these
    // will cause build() to re-run and return a new Stream when they change.
    final selectedDate = ref.watch(calendarSelectedDateProvider);
    final focusedDate = ref.watch(calendarFocusedDateProvider);

    final semester = ref.watch(semesterStateProvider);
    if (semester == null) {
      return Stream.value(CalendarState(
        selectedDate: selectedDate,
        focusedDate: focusedDate,
        attendanceMarkers: UnmodifiableMapView<DateTime, List<AttendanceStatus>>({}),
        taskMarkers: UnmodifiableMapView<DateTime, List<AcademicTask>>({}),
        selectedDayDetails: DailyAttendanceDetails(date: selectedDate),
        selectedDayTasks: [],
        allSubjects: [],
        isLoading: false,
      ));
    }

    return Rx.combineLatest4(
      subjectRepo.watchAll(semester.id),
      scheduleRepo.watchAll(semester.id),
      attendanceRepo.watchAll(semester.id),
      plannerRepo.watchAllTasks(semester.id),
      (List<Subject> subjects, List<Schedule> schedules,
          List<Attendance> attendances, List<AcademicTask> tasks) {
        if (subjects.isEmpty) {
          return CalendarState(
            selectedDate: selectedDate,
            focusedDate: focusedDate,
            attendanceMarkers: CalendarEngine.generateMarkers([]),
            taskMarkers: CalendarEngine.generateTaskMarkers([]),
            selectedDayDetails: DailyAttendanceDetails(date: selectedDate),
            selectedDayTasks: [],
            allSubjects: [],
            isLoading: false,
          );
        }

        final markers = CalendarEngine.generateMarkers(attendances);
        final taskMarkersMap = CalendarEngine.generateTaskMarkers(tasks);
        final details = CalendarEngine.buildDailyDetails(
          selectedDate,
          subjects,
          schedules,
          attendances,
          semesterStartDate: semester.startDate,
          semesterEndDate: semester.endDate,
        );
        final tasksForDay = CalendarEngine.getTasksForDate(selectedDate, tasks);

        return CalendarState(
          selectedDate: selectedDate,
          focusedDate: focusedDate,
          attendanceMarkers: markers,
          taskMarkers: taskMarkersMap,
          selectedDayDetails: details,
          selectedDayTasks: tasksForDay,
          allSubjects: subjects,
          isLoading: false,
        );
      },
    );
  }
}

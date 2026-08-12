import 'dart:collection';
import 'package:attendify/core/enums/attendance_status.dart';
import 'package:attendify/core/enums/day_of_week.dart';
import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/features/calendar/models/daily_attendance_details.dart';
import 'package:attendify/features/calendar/models/daily_attendance_item.dart';
import 'package:attendify/database/collections/academic_task_collection.dart';

class CalendarEngine {
  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static UnmodifiableMapView<DateTime, List<AttendanceStatus>> generateMarkers(
      List<Attendance> attendances) {
    final Map<DateTime, List<AttendanceStatus>> map = {};
    for (final a in attendances) {
      final date = _normalizeDate(a.date);
      if (!map.containsKey(date)) {
        map[date] = [];
      }
      map[date]!.add(a.status);
    }
    return UnmodifiableMapView(map);
  }

  static UnmodifiableMapView<DateTime, List<AcademicTask>> generateTaskMarkers(
      List<AcademicTask> tasks) {
    final Map<DateTime, List<AcademicTask>> map = {};
    for (final t in tasks) {
      final date = _normalizeDate(t.dueDate);
      if (!map.containsKey(date)) {
        map[date] = [];
      }
      map[date]!.add(t);
    }
    return UnmodifiableMapView(map);
  }

  static List<AcademicTask> getTasksForDate(
      DateTime targetDate, List<AcademicTask> tasks) {
    final date = _normalizeDate(targetDate);
    return tasks.where((t) => _normalizeDate(t.dueDate) == date).toList();
  }

  static DailyAttendanceDetails buildDailyDetails(
    DateTime targetDate,
    List<Subject> subjects,
    List<Schedule> schedules,
    List<Attendance> attendances, {
    DateTime? semesterStartDate,
    DateTime? semesterEndDate,
  }) {
    final date = _normalizeDate(targetDate);
    final dayOfWeek = DayOfWeek.fromInt(date.weekday).value;

    final isWithinSemester = (semesterStartDate == null ||
            !date.isBefore(_normalizeDate(semesterStartDate))) &&
        (semesterEndDate == null ||
            !date.isAfter(_normalizeDate(semesterEndDate)));

    final todaysSchedules = isWithinSemester
        ? schedules.where((s) => s.dayOfWeek == dayOfWeek).toList()
        : <Schedule>[];
    final todaysAttendances =
        attendances.where((a) => _normalizeDate(a.date) == date).toList();

    final List<DailyAttendanceItem> items = [];
    final Set<int> usedAttendanceIds = {};

    for (final schedule in todaysSchedules) {
      final subject =
          subjects.where((s) => s.id == schedule.subjectId).firstOrNull;
      if (subject == null) continue; // Skip if subject is deleted

      // Find attendance specifically for this schedule
      final attendance = todaysAttendances
          .where((a) => a.scheduleId == schedule.id)
          .firstOrNull;

      if (attendance != null) {
        usedAttendanceIds.add(attendance.id);
      }

      items.add(DailyAttendanceItem(
        subject: subject,
        schedule: schedule,
        attendance: attendance,
        isManual: false,
      ));
    }

    // Process manual attendances (those without a schedule, or schedule that was deleted)
    for (final attendance in todaysAttendances) {
      if (!usedAttendanceIds.contains(attendance.id)) {
        final subject =
            subjects.where((s) => s.id == attendance.subjectId).firstOrNull;
        if (subject == null) continue;

        items.add(DailyAttendanceItem(
          subject: subject,
          schedule:
              null, // It's manual because it doesn't match any schedule for today
          attendance: attendance,
          isManual: true,
        ));
      }
    }

    items.sort((a, b) => a.compareTo(b));

    return DailyAttendanceDetails(
      date: date,
      items: List.unmodifiable(items),
    );
  }
}

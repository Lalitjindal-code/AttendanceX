import 'dart:convert';

import 'package:attendify/core/enums/attendance_status.dart';
import 'package:attendify/core/enums/day_of_week.dart';
import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/database/collections/semester_collection.dart';
import 'package:attendify/features/notifications/models/scheduled_notification.dart';
import 'package:attendify/features/settings/models/app_settings.dart';

class NotificationEngine {
  static const int _typeLecture = 1;
  static const int _typeDaily = 2;
  static const int _schedulingWindowDays = 7;

  /// Pure method to generate a list of notifications to be scheduled locally.
  static List<ScheduledNotification> generateNotifications({
    required List<Subject> subjects,
    required List<Schedule> schedules,
    required List<Attendance> attendances,
    required AppSettings settings,
    required Semester? semester,
    required DateTime now,
  }) {
    if (!settings.notificationsEnabled) {
      return [];
    }

    final notifications = <ScheduledNotification>[];
    final startOfToday = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < _schedulingWindowDays; i++) {
      final targetDate = startOfToday.add(Duration(days: i));

      // 1. Generate Lecture Reminders
      notifications.addAll(_generateLectureAlertsForDate(
        targetDate: targetDate,
        subjects: subjects,
        schedules: schedules,
        attendances: attendances,
        settings: settings,
        semester: semester,
        now: now,
      ));

      // 2. Generate Daily Missed Attendance Reminder
      if (settings.dailyReminderEnabled) {
        final reminder = _generateDailyReminderForDate(
          targetDate: targetDate,
          subjects: subjects,
          schedules: schedules,
          attendances: attendances,
          settings: settings,
          semester: semester,
          now: now,
        );
        if (reminder != null) {
          notifications.add(reminder);
        }
      }
    }

    return notifications;
  }

  static List<ScheduledNotification> _generateLectureAlertsForDate({
    required DateTime targetDate,
    required List<Subject> subjects,
    required List<Schedule> schedules,
    required List<Attendance> attendances,
    required AppSettings settings,
    required Semester? semester,
    required DateTime now,
  }) {
    final alerts = <ScheduledNotification>[];

    // Check if target date is within semester
    if (semester != null) {
      if (targetDate.isBefore(_normalizeDate(semester.startDate)))
        return alerts;
      if (semester.endDate != null &&
          targetDate.isAfter(_normalizeDate(semester.endDate!))) return alerts;
    }

    final dayOfWeek = DayOfWeek.fromInt(targetDate.weekday).value;
    final todaysSchedules =
        schedules.where((s) => s.dayOfWeek == dayOfWeek).toList();
    final todaysAttendances =
        attendances.where((a) => _normalizeDate(a.date) == targetDate).toList();

    for (final schedule in todaysSchedules) {
      // Find subject
      final subject =
          subjects.where((s) => s.id == schedule.subjectId).firstOrNull;
      if (subject == null) continue;

      // Skip if class notifications are disabled for this subject
      if (!subject.classNotificationsEnabled) continue;

      // Ensure no attendance already marked for this schedule
      final attendance = todaysAttendances
          .where((a) => a.scheduleId == schedule.id)
          .firstOrNull;
      if (attendance != null && attendance.status != AttendanceStatus.pending) {
        continue;
      }

      // Calculate start time
      final timeParts = schedule.startTime.split(':');
      if (timeParts.length != 2) continue;
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      final lectureTime = DateTime(
          targetDate.year, targetDate.month, targetDate.day, hour, minute);
      final alertTime = lectureTime
          .subtract(Duration(minutes: settings.lectureReminderMinutes));

      if (alertTime.isAfter(now)) {
        final id = _generateLectureId(schedule.id, targetDate);
        final payload = jsonEncode({
          'type': 'lecture',
          'scheduleId': schedule.id,
          'subjectId': schedule.subjectId,
          'date':
              '${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}',
        });

        alerts.add(ScheduledNotification(
          id: id,
          title: 'Upcoming Class: ${subject.name}',
          body: 'Starts at ${schedule.startTime} in ${schedule.room}',
          scheduledDate: alertTime,
          payload: payload,
        ));
      }
    }

    return alerts;
  }

  static ScheduledNotification? _generateDailyReminderForDate({
    required DateTime targetDate,
    required List<Subject> subjects,
    required List<Schedule> schedules,
    required List<Attendance> attendances,
    required AppSettings settings,
    required Semester? semester,
    required DateTime now,
  }) {
    // Check if target date is within semester
    if (semester != null) {
      if (targetDate.isBefore(_normalizeDate(semester.startDate))) return null;
      if (semester.endDate != null &&
          targetDate.isAfter(_normalizeDate(semester.endDate!))) return null;
    }

    // Parse daily reminder time
    final timeParts = settings.dailyReminderTime.split(':');
    if (timeParts.length != 2) return null;
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    final reminderTime = DateTime(
        targetDate.year, targetDate.month, targetDate.day, hour, minute);

    if (!reminderTime.isAfter(now)) {
      return null; // Already passed
    }

    // Now, pretend it's `reminderTime`. Would we have any missed attendances?
    // We scan all scheduled lectures on `targetDate` that END before `reminderTime`
    // (or just start before it, let's say "start before reminder time")
    // Wait, the user said "lecture time has already passed".
    // We will consider a lecture passed if its `endTime` is before `reminderTime`.

    final dayOfWeek = DayOfWeek.fromInt(targetDate.weekday).value;
    final todaysSchedules =
        schedules.where((s) => s.dayOfWeek == dayOfWeek).toList();
    final todaysAttendances =
        attendances.where((a) => _normalizeDate(a.date) == targetDate).toList();

    int missedCount = 0;

    for (final schedule in todaysSchedules) {
      final endTimeParts = schedule.endTime.split(':');
      if (endTimeParts.length != 2) continue;
      final endHour = int.tryParse(endTimeParts[0]) ?? 0;
      final endMinute = int.tryParse(endTimeParts[1]) ?? 0;

      final endTime = DateTime(targetDate.year, targetDate.month,
          targetDate.day, endHour, endMinute);

      // If the lecture ends before or exactly at the reminder time
      if (endTime.isBefore(reminderTime) ||
          endTime.isAtSameMomentAs(reminderTime)) {
        // Is attendance missing or pending?
        final attendance = todaysAttendances
            .where((a) => a.scheduleId == schedule.id)
            .firstOrNull;
        if (attendance == null ||
            attendance.status == AttendanceStatus.pending) {
          missedCount++;
        }
      }
    }

    // Since a daily reminder scans past lectures, should we also scan days BEFORE targetDate?
    // "Missed Attendance Reminders: Reminders if the user missed marking attendance for a completed lecture."
    // If we only scan `targetDate`, then if they miss Monday's lecture, they get a reminder Monday at 20:00.
    // On Tuesday at 20:00, if Tuesday has no missed lectures, they won't get a reminder, even though Monday is still missed.
    // To strictly check if ANY past lecture is unmarked across the 7-day window leading up to targetDate:
    if (missedCount == 0) {
      // Let's check previous 6 days from `targetDate` for any unmarked past lectures.
      for (int i = 1; i <= 6; i++) {
        final checkDate = targetDate.subtract(Duration(days: i));

        // We only care if `checkDate` is on or after the semester start date?
        if (semester != null &&
            checkDate.isBefore(_normalizeDate(semester.startDate))) {
          continue;
        }

        final dow = DayOfWeek.fromInt(checkDate.weekday).value;
        final pastSchedules =
            schedules.where((s) => s.dayOfWeek == dow).toList();
        final pastAttendances = attendances
            .where((a) => _normalizeDate(a.date) == checkDate)
            .toList();

        for (final schedule in pastSchedules) {
          final attendance = pastAttendances
              .where((a) => a.scheduleId == schedule.id)
              .firstOrNull;
          if (attendance == null ||
              attendance.status == AttendanceStatus.pending) {
            // Lecture from a past day is completely in the past relative to `targetDate`'s reminder time.
            missedCount++;
          }
        }
      }
    }

    if (missedCount > 0) {
      final id = _generateDailyId(targetDate);
      final payload = jsonEncode({
        'type': 'daily_reminder',
        'missedCount': missedCount,
        'date':
            '${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}',
      });

      return ScheduledNotification(
        id: id,
        title: 'Missed Attendance',
        body:
            'You have $missedCount unmarked lecture${missedCount > 1 ? 's' : ''}. Please update your attendance.',
        scheduledDate: reminderTime,
        payload: payload,
      );
    }

    return null;
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static int _generateLectureId(int scheduleId, DateTime date) {
    final dateInt = date.year * 10000 + date.month * 100 + date.day;
    // Object.hash is not stable across app restarts. Use XOR and primes for a stable hash.
    return (scheduleId.hashCode ^ dateInt.hashCode ^ _typeLecture.hashCode) & 0x7FFFFFFF;
  }

  static int _generateDailyId(DateTime date) {
    final dateInt = date.year * 10000 + date.month * 100 + date.day;
    return (dateInt.hashCode ^ _typeDaily.hashCode) & 0x7FFFFFFF;
  }
}

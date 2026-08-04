import 'package:attendancex/core/enums/attendance_status.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/features/notifications/engines/notification_engine.dart';
import 'package:attendancex/features/settings/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationEngine Tests', () {
    final now =
        DateTime(2026, 1, 1, 12, 0); // Thursday, Jan 1, 2026 at 12:00 PM

    // Thursday is weekday 4 in Dart

    final dummySubject = Subject()
      ..id = 1
      ..name = 'Math';

    final upcomingSchedule = Schedule()
      ..id = 101
      ..subjectId = 1
      ..dayOfWeek = 4 // Thursday
      ..startTime = '14:00'
      ..endTime = '15:00'
      ..room = '101';

    final passedSchedule = Schedule()
      ..id = 102
      ..subjectId = 1
      ..dayOfWeek = 4 // Thursday
      ..startTime = '09:00'
      ..endTime = '10:00'
      ..room = '102';

    test('Returns empty when notifications are disabled', () {
      const settings = AppSettings(notificationsEnabled: false);
      final result = NotificationEngine.generateNotifications(
        subjects: [dummySubject],
        schedules: [upcomingSchedule],
        attendances: [],
        settings: settings,
        now: now,
      );
      expect(result, isEmpty);
    });

    test('Generates lecture reminder for upcoming lecture', () {
      const settings = AppSettings(
        notificationsEnabled: true,
        lectureReminderMinutes: 10,
        dailyReminderEnabled: false,
      );

      final result = NotificationEngine.generateNotifications(
        subjects: [dummySubject],
        schedules: [upcomingSchedule],
        attendances: [],
        settings: settings,
        now: now,
      );

      expect(result.length, 1);
      final notification = result.first;
      expect(notification.title, contains('Math'));
      expect(notification.scheduledDate,
          DateTime(2026, 1, 1, 13, 50)); // 10 mins before 14:00
    });

    test('Does not generate lecture reminder if it is already in the past', () {
      const settings = AppSettings(
        notificationsEnabled: true,
        lectureReminderMinutes: 10,
        dailyReminderEnabled: false,
      );

      final result = NotificationEngine.generateNotifications(
        subjects: [dummySubject],
        schedules: [passedSchedule],
        attendances: [],
        settings: settings,
        now: now,
      );

      expect(result, isEmpty);
    });

    test('Generates daily reminder if missed attendance exists', () {
      const settings = AppSettings(
        notificationsEnabled: true,
        dailyReminderEnabled: true,
        dailyReminderTime: '20:00',
        lectureReminderMinutes: 10,
      );

      final result = NotificationEngine.generateNotifications(
        subjects: [dummySubject],
        schedules: [passedSchedule],
        attendances: [],
        settings: settings,
        now: now,
      );

      expect(result.length, 7); // One reminder for each day in the 7-day window
      expect(result.first.title, contains('Missed Attendance'));
      expect(result.first.scheduledDate,
          DateTime(2026, 1, 1, 20, 0)); // 20:00 today
    });

    test('Does not generate daily reminder if all attendances are marked', () {
      const settings = AppSettings(
        notificationsEnabled: true,
        dailyReminderEnabled: true,
        dailyReminderTime: '20:00',
        lectureReminderMinutes: 10,
      );

      final markedAttendance = Attendance()
        ..id = 1
        ..scheduleId = passedSchedule.id
        ..subjectId = dummySubject.id
        ..date = DateTime(2026, 1, 1)
        ..status = AttendanceStatus.present;

      final result = NotificationEngine.generateNotifications(
        subjects: [dummySubject],
        schedules: [passedSchedule],
        attendances: [markedAttendance],
        settings: settings,
        now: now,
      );

      expect(result, isEmpty);
    });

    test('Generates deterministic IDs for the same input', () {
      const settings = AppSettings(
        notificationsEnabled: true,
        lectureReminderMinutes: 10,
        dailyReminderEnabled: true,
        dailyReminderTime: '20:00',
      );

      final result1 = NotificationEngine.generateNotifications(
        subjects: [dummySubject],
        schedules: [upcomingSchedule, passedSchedule],
        attendances: [],
        settings: settings,
        now: now,
      );

      final result2 = NotificationEngine.generateNotifications(
        subjects: [dummySubject],
        schedules: [upcomingSchedule, passedSchedule],
        attendances: [],
        settings: settings,
        now: now,
      );

      expect(result1.length, 8); // 1 lecture alert + 7 daily reminders
      expect(result1.map((n) => n.id).toList(),
          equals(result2.map((n) => n.id).toList()));
    });
  });
}

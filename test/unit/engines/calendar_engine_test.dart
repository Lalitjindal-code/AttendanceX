import 'package:flutter_test/flutter_test.dart';
import 'package:attendancex/core/enums/attendance_status.dart';
import 'package:attendancex/core/enums/day_of_week.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/features/calendar/engines/calendar_engine.dart';

void main() {
  group('CalendarEngine', () {
    final now = DateTime(2023, 10, 10); // A Tuesday

    test('generateMarkers groups correctly and normalizes dates', () {
      final a1 = Attendance()
        ..date = DateTime(2023, 10, 10, 10, 0)
        ..status = AttendanceStatus.present;
      final a2 = Attendance()
        ..date = DateTime(2023, 10, 10, 11, 0)
        ..status = AttendanceStatus.absent;
      final a3 = Attendance()
        ..date = DateTime(2023, 10, 11, 10, 0)
        ..status = AttendanceStatus.medical;

      final markers = CalendarEngine.generateMarkers([a1, a2, a3]);
      expect(markers.length, 2);

      final oct10 = DateTime(2023, 10, 10);
      final oct11 = DateTime(2023, 10, 11);

      expect(markers[oct10]?.length, 2);
      expect(markers[oct10]?.contains(AttendanceStatus.present), isTrue);
      expect(markers[oct10]?.contains(AttendanceStatus.absent), isTrue);

      expect(markers[oct11]?.length, 1);
      expect(markers[oct11]?.contains(AttendanceStatus.medical), isTrue);
    });

    test('buildDailyDetails handles scheduled and manual attendance properly',
        () {
      final s1 = Subject()
        ..id = 1
        ..name = 'Math';
      final s2 = Subject()
        ..id = 2
        ..name = 'Physics';

      // 2023-10-10 is Tuesday.
      final sch1 = Schedule()
        ..id = 1
        ..subjectId = 1
        ..dayOfWeek = DayOfWeek.tuesday.value
        ..startTime = '09:00'
        ..endTime = '10:00';

      final sch2 = Schedule()
        ..id = 2
        ..subjectId = 2
        ..dayOfWeek = DayOfWeek.tuesday.value
        ..startTime = '10:00'
        ..endTime = '11:00';

      final sch3 = Schedule()
        ..id = 3
        ..subjectId = 1
        ..dayOfWeek = DayOfWeek.wednesday.value
        ..startTime = '10:00'
        ..endTime = '11:00';

      final a1 = Attendance()
        ..id = 1
        ..subjectId = 1
        ..scheduleId = 1
        ..date = DateTime(2023, 10, 10, 9, 30)
        ..status = AttendanceStatus.present;

      // Manual attendance (no schedule)
      final a2 = Attendance()
        ..id = 2
        ..subjectId = 2
        ..scheduleId = -1
        ..date = DateTime(2023, 10, 10, 14, 0)
        ..status = AttendanceStatus.holiday;

      final details = CalendarEngine.buildDailyDetails(
        now,
        [s1, s2],
        [sch1, sch2, sch3],
        [a1, a2],
      );

      expect(details.date, DateTime(2023, 10, 10));
      expect(details.items.length, 3); // 2 schedules + 1 manual

      // Should be sorted:
      // 09:00 - Math (Scheduled + Attended)
      // 10:00 - Physics (Scheduled, No attendance)
      // Manual - Physics (Manual, Holiday)

      final i0 = details.items[0];
      expect(i0.subject.name, 'Math');
      expect(i0.schedule?.id, 1);
      expect(i0.attendance?.id, 1);
      expect(i0.isManual, isFalse);

      final i1 = details.items[1];
      expect(i1.subject.name, 'Physics');
      expect(i1.schedule?.id, 2);
      expect(i1.attendance, isNull);
      expect(i1.isManual, isFalse);

      final i2 = details.items[2];
      expect(i2.subject.name, 'Physics');
      expect(i2.schedule, isNull);
      expect(i2.attendance?.id, 2);
      expect(i2.isManual, isTrue);
    });

    test('buildDailyDetails handles leap year and month boundary', () {
      final leapDay = DateTime(2024, 2, 29); // Thursday

      final sub = Subject()
        ..id = 1
        ..name = 'Bio';
      final sch = Schedule()
        ..id = 1
        ..subjectId = 1
        ..dayOfWeek = DayOfWeek.thursday.value
        ..startTime = '09:00';

      final att = Attendance()
        ..id = 1
        ..subjectId = 1
        ..scheduleId = 1
        ..date = leapDay
        ..status = AttendanceStatus.present;

      final details =
          CalendarEngine.buildDailyDetails(leapDay, [sub], [sch], [att]);
      expect(details.items.length, 1);
      expect(details.items.first.attendance?.status, AttendanceStatus.present);
    });
  });
}

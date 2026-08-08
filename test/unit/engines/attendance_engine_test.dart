import 'package:attendify/core/enums/attendance_status.dart';
import 'package:attendify/core/enums/gt_mode.dart';
import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/semester_collection.dart';
import 'package:attendify/engines/attendance_engine.dart';
import 'package:attendify/features/settings/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceEngine Tests', () {
    late AppSettings baseSettings;
    late Semester dummySemester;

    setUp(() {
      baseSettings = const AppSettings(
        themeMode: ThemeMode.system,
        defaultGoalPercentage: 75.0,
        medicalCountsAsPresent: false,
        gtMode: GtMode.exclude,
        notificationsEnabled: false,
        dailyReminderEnabled: false,
        dailyReminderTime: '20:00',
        lectureReminderMinutes: 10,
      );
      dummySemester = Semester()
        ..id = 1
        ..startDate = DateTime(2023, 1, 1)
        ..endDate = DateTime(2030, 1, 1);
    });

    Attendance createAttendance(AttendanceStatus status, {int subjectId = 1}) {
      return Attendance()
        ..subjectId = subjectId
        ..date = DateTime(2025, 6, 1)
        ..status = status;
    }

    test('calculateSubjectSummary with no attendance records', () {
      final summary =
          AttendanceEngine.calculateSubjectSummary(1, [], baseSettings, dummySemester);
      expect(summary.effectiveTotal, 0);
      expect(summary.effectivePresent, 0);
      expect(summary.attendancePercentage, 0.0);
    });

    test('calculateSubjectSummary with 100% attendance', () {
      final records = [
        createAttendance(AttendanceStatus.present),
        createAttendance(AttendanceStatus.present),
      ];
      final summary =
          AttendanceEngine.calculateSubjectSummary(1, records, baseSettings, dummySemester);

      expect(summary.effectiveTotal, 2);
      expect(summary.effectivePresent, 2);
      expect(summary.attendancePercentage, 100.0);
      expect(summary.totalPresentRecords, 2);
    });

    test('calculateSubjectSummary with 0% attendance', () {
      final records = [
        createAttendance(AttendanceStatus.absent),
        createAttendance(AttendanceStatus.absent),
      ];
      final summary =
          AttendanceEngine.calculateSubjectSummary(1, records, baseSettings, dummySemester);

      expect(summary.effectiveTotal, 2);
      expect(summary.effectivePresent, 0);
      expect(summary.attendancePercentage, 0.0);
      expect(summary.totalAbsentRecords, 2);
    });

    test('calculateSubjectSummary safely ignores Holidays', () {
      final records = [
        createAttendance(AttendanceStatus.present),
        createAttendance(AttendanceStatus.holiday),
        createAttendance(AttendanceStatus.holiday),
      ];
      final summary =
          AttendanceEngine.calculateSubjectSummary(1, records, baseSettings, dummySemester);

      expect(summary.effectiveTotal, 1);
      expect(summary.effectivePresent, 1);
      expect(summary.attendancePercentage, 100.0);
      expect(summary.totalHolidayRecords, 2);
    });

    test('calculateSubjectSummary safely ignores Pending', () {
      final records = [
        createAttendance(AttendanceStatus.present),
        createAttendance(AttendanceStatus.pending),
      ];
      final summary =
          AttendanceEngine.calculateSubjectSummary(1, records, baseSettings, dummySemester);

      expect(summary.effectiveTotal, 1);
      expect(summary.effectivePresent, 1);
      expect(summary.attendancePercentage, 100.0);
      expect(summary.totalPendingRecords, 1);
    });

    group('Medical Rules', () {
      test('medicalCountsAsPresent = true -> counts as Present', () {
        final settings = baseSettings.copyWith(medicalCountsAsPresent: true);
        final records = [createAttendance(AttendanceStatus.medical)];

        final summary =
            AttendanceEngine.calculateSubjectSummary(1, records, settings, dummySemester);
        expect(summary.effectiveTotal, 1);
        expect(summary.effectivePresent, 1);
        expect(summary.attendancePercentage, 100.0);
        expect(summary.totalMedicalRecords, 1);
      });

      test('medicalCountsAsPresent = false -> completely excluded', () {
        final settings = baseSettings.copyWith(medicalCountsAsPresent: false);
        final records = [createAttendance(AttendanceStatus.medical)];

        final summary =
            AttendanceEngine.calculateSubjectSummary(1, records, settings, dummySemester);
        expect(summary.effectiveTotal, 0);
        expect(summary.effectivePresent, 0);
        expect(summary.attendancePercentage, 0.0);
        expect(summary.totalMedicalRecords, 1);
      });
    });

    group('GT Rules', () {
      test('GtMode.exclude -> completely excluded', () {
        final settings = baseSettings.copyWith(gtMode: GtMode.exclude);
        final records = [createAttendance(AttendanceStatus.gt)];

        final summary =
            AttendanceEngine.calculateSubjectSummary(1, records, settings, dummySemester);
        expect(summary.effectiveTotal, 0);
        expect(summary.effectivePresent, 0);
        expect(summary.attendancePercentage, 0.0);
        expect(summary.totalGTRecords, 1);
      });

      test('GtMode.countAsPresent -> counts as Present', () {
        final settings = baseSettings.copyWith(gtMode: GtMode.countAsPresent);
        final records = [createAttendance(AttendanceStatus.gt)];

        final summary =
            AttendanceEngine.calculateSubjectSummary(1, records, settings, dummySemester);
        expect(summary.effectiveTotal, 1);
        expect(summary.effectivePresent, 1);
        expect(summary.attendancePercentage, 100.0);
        expect(summary.totalGTRecords, 1);
      });

      test('GtMode.countAsAbsent -> counts as Absent', () {
        final settings = baseSettings.copyWith(gtMode: GtMode.countAsAbsent);
        final records = [createAttendance(AttendanceStatus.gt)];

        final summary =
            AttendanceEngine.calculateSubjectSummary(1, records, settings, dummySemester);
        expect(summary.effectiveTotal, 1);
        expect(summary.effectivePresent, 0);
        expect(summary.attendancePercentage, 0.0);
        expect(summary.totalGTRecords, 1);
      });
    });

    test('Overall Summary calculates correctly across subjects', () {
      final records = [
        createAttendance(AttendanceStatus.present, subjectId: 1),
        createAttendance(AttendanceStatus.absent, subjectId: 2),
      ];
      final summary =
          AttendanceEngine.calculateOverallSummary(records, baseSettings, dummySemester);

      expect(summary.effectiveTotal, 2);
      expect(summary.effectivePresent, 1);
      expect(summary.attendancePercentage, 50.0);
    });
  });
}

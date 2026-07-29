import 'package:flutter_test/flutter_test.dart';
import 'package:attendancex/features/analytics/engines/analytics_engine.dart';
import 'package:attendancex/features/analytics/models/analytics_trend.dart';
import 'package:attendancex/features/dashboard/models/attendance_summary.dart';
import 'package:attendancex/features/settings/models/app_settings.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/core/enums/attendance_status.dart';

void main() {
  group('AnalyticsEngine.calculateMonthlyTrends', () {
    final settings = AppSettings();

    test('Empty dataset returns empty list', () {
      final trends = AnalyticsEngine.calculateMonthlyTrends([], settings);
      expect(trends, isEmpty);
    });

    test('Single month grouping works correctly', () {
      final a1 = Attendance()..date = DateTime.utc(2023, 10, 1)..status = AttendanceStatus.present;
      final a2 = Attendance()..date = DateTime.utc(2023, 10, 2)..status = AttendanceStatus.absent;
      
      final trends = AnalyticsEngine.calculateMonthlyTrends([a1, a2], settings);
      expect(trends.length, 1);
      expect(trends[0].year, 2023);
      expect(trends[0].month, 10);
      expect(trends[0].presentCount, 1);
      expect(trends[0].totalCount, 2);
      expect(trends[0].percentage, 0.5);
    });

    test('Multiple months and cross-year grouping works correctly', () {
      final a1 = Attendance()..date = DateTime.utc(2023, 12, 31)..status = AttendanceStatus.present;
      final a2 = Attendance()..date = DateTime.utc(2024, 1, 1)..status = AttendanceStatus.present;
      
      final trends = AnalyticsEngine.calculateMonthlyTrends([a1, a2], settings);
      expect(trends.length, 2);
      
      expect(trends[0].year, 2023);
      expect(trends[0].month, 12);
      expect(trends[0].percentage, 1.0);
      
      expect(trends[1].year, 2024);
      expect(trends[1].month, 1);
      expect(trends[1].percentage, 1.0);
    });
  });

  group('AnalyticsEngine.calculateTrend', () {
    test('Returns insufficientData when total is 0', () {
      final current = SubjectAttendanceSummary(
        subjectId: 1,
        effectivePresent: 0, effectiveTotal: 0,
        totalPresentRecords: 0, totalAbsentRecords: 0,
        totalHolidayRecords: 0, totalMedicalRecords: 0,
        totalGTRecords: 0, totalPendingRecords: 0,
      );
      final prev = SubjectAttendanceSummary(
        subjectId: 1,
        effectivePresent: 1, effectiveTotal: 1,
        totalPresentRecords: 1, totalAbsentRecords: 0,
        totalHolidayRecords: 0, totalMedicalRecords: 0,
        totalGTRecords: 0, totalPendingRecords: 0,
      );
      
      expect(AnalyticsEngine.calculateTrend(current, prev), AnalyticsTrend.insufficientData);
      expect(AnalyticsEngine.calculateTrend(prev, current), AnalyticsTrend.insufficientData); // when prev is 0
    });

    test('Returns improving when percentage increases', () {
      final current = SubjectAttendanceSummary(
        subjectId: 1,
        effectivePresent: 2, effectiveTotal: 2,
        totalPresentRecords: 2, totalAbsentRecords: 0,
        totalHolidayRecords: 0, totalMedicalRecords: 0,
        totalGTRecords: 0, totalPendingRecords: 0,
      );
      final prev = SubjectAttendanceSummary(
        subjectId: 1,
        effectivePresent: 1, effectiveTotal: 2,
        totalPresentRecords: 1, totalAbsentRecords: 1,
        totalHolidayRecords: 0, totalMedicalRecords: 0,
        totalGTRecords: 0, totalPendingRecords: 0,
      );
      expect(AnalyticsEngine.calculateTrend(current, prev), AnalyticsTrend.improving);
    });

    test('Returns declining when percentage decreases', () {
      final current = SubjectAttendanceSummary(
        subjectId: 1,
        effectivePresent: 1, effectiveTotal: 2,
        totalPresentRecords: 1, totalAbsentRecords: 1,
        totalHolidayRecords: 0, totalMedicalRecords: 0,
        totalGTRecords: 0, totalPendingRecords: 0,
      );
      final prev = SubjectAttendanceSummary(
        subjectId: 1,
        effectivePresent: 2, effectiveTotal: 2,
        totalPresentRecords: 2, totalAbsentRecords: 0,
        totalHolidayRecords: 0, totalMedicalRecords: 0,
        totalGTRecords: 0, totalPendingRecords: 0,
      );
      expect(AnalyticsEngine.calculateTrend(current, prev), AnalyticsTrend.declining);
    });

    test('Returns stable when percentage is same', () {
      final summary = SubjectAttendanceSummary(
        subjectId: 1,
        effectivePresent: 1, effectiveTotal: 2,
        totalPresentRecords: 1, totalAbsentRecords: 1,
        totalHolidayRecords: 0, totalMedicalRecords: 0,
        totalGTRecords: 0, totalPendingRecords: 0,
      );
      expect(AnalyticsEngine.calculateTrend(summary, summary), AnalyticsTrend.stable);
    });
  });

  group('AnalyticsEngine.calculateForecast', () {
    SubjectAttendanceSummary createSummary(int present, int total) {
      return SubjectAttendanceSummary(
        subjectId: 1,
        effectivePresent: present, effectiveTotal: total,
        totalPresentRecords: present, totalAbsentRecords: total - present,
        totalHolidayRecords: 0, totalMedicalRecords: 0,
        totalGTRecords: 0, totalPendingRecords: 0,
      );
    }

    test('Forecast with 0% goal', () {
      final summary = createSummary(5, 10); // 50%
      final forecast = AnalyticsEngine.calculateForecast(summary, 0.0);
      expect(forecast.safeBunksRemaining, 999);
      expect(forecast.classesNeededToReachGoal, 0);
    });

    test('Forecast with 100% goal impossible', () {
      final summary = createSummary(5, 10); // 50%, missed 5
      final forecast = AnalyticsEngine.calculateForecast(summary, 1.0);
      expect(forecast.classesNeededToReachGoal, -1);
      expect(forecast.safeBunksRemaining, 0);
    });

    test('Forecast with 100% goal still possible (no misses yet)', () {
      final summary = createSummary(5, 5); // 100%, missed 0
      final forecast = AnalyticsEngine.calculateForecast(summary, 1.0);
      expect(forecast.classesNeededToReachGoal, 0);
      expect(forecast.safeBunksRemaining, 0);
    });

    test('Forecast logic math is correct', () {
      final summary = createSummary(6, 10); // 60%
      final forecast = AnalyticsEngine.calculateForecast(summary, 0.75); // goal 75%
      
      expect(forecast.projectedPercentageIfAttendNext, 7 / 11);
      expect(forecast.projectedPercentageIfBunkNext, 6 / 11);
      
      // Need (0.75 * 10 - 6) / 0.25 = (7.5 - 6) / 0.25 = 1.5 / 0.25 = 6 classes
      expect(forecast.classesNeededToReachGoal, 6);
      
      // Safe bunks = 6 / 0.75 - 10 = 8 - 10 = -2 => 0
      expect(forecast.safeBunksRemaining, 0);
    });

    test('Safe bunks remaining is correct when ahead of goal', () {
      final summary = createSummary(9, 10); // 90%
      final forecast = AnalyticsEngine.calculateForecast(summary, 0.75); // goal 75%
      
      // Safe bunks = 9 / 0.75 - 10 = 12 - 10 = 2
      expect(forecast.safeBunksRemaining, 2);
      expect(forecast.classesNeededToReachGoal, 0);
    });
  });
}

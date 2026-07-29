import 'package:attendancex/features/dashboard/models/attendance_summary.dart';
import 'package:attendancex/features/settings/models/app_settings.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/engines/attendance_engine.dart';

import '../models/analytics_trend.dart';
import '../models/monthly_trend.dart';
import '../models/attendance_forecast.dart';

class AnalyticsEngine {
  /// Calculates monthly trends for the given list of attendances.
  /// 
  /// Reuses [AttendanceEngine] to ensure calculation rules remain consistent.
  static List<MonthlyTrend> calculateMonthlyTrends(
    List<Attendance> attendances,
    AppSettings settings,
  ) {
    if (attendances.isEmpty) return [];

    // Group by year and month
    final Map<String, List<Attendance>> grouped = {};
    for (var a in attendances) {
      final date = a.date; // assuming UTC DateTime
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(a);
    }

    final List<MonthlyTrend> trends = [];

    for (var entry in grouped.entries) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final summary = AttendanceEngine.calculateOverallSummary(entry.value, settings);

      trends.add(MonthlyTrend(
        year: year,
        month: month,
        presentCount: summary.effectivePresent,
        totalCount: summary.effectiveTotal,
        percentage: summary.attendancePercentage / 100.0,
      ));
    }

    // Sort chronologically
    trends.sort((a, b) {
      final cmpYear = a.year.compareTo(b.year);
      if (cmpYear != 0) return cmpYear;
      return a.month.compareTo(b.month);
    });

    return trends;
  }

  /// Calculates the trend by comparing current and previous periods.
  static AnalyticsTrend calculateTrend(
    SubjectAttendanceSummary currentPeriod,
    SubjectAttendanceSummary previousPeriod,
  ) {
    if (previousPeriod.effectiveTotal == 0 || currentPeriod.effectiveTotal == 0) {
      return AnalyticsTrend.insufficientData;
    }

    final diff = currentPeriod.attendancePercentage - previousPeriod.attendancePercentage;
    
    // Use a small epsilon to avoid floating point precision issues
    if (diff > 0.001) return AnalyticsTrend.improving;
    if (diff < -0.001) return AnalyticsTrend.declining;
    return AnalyticsTrend.stable;
  }

  /// Calculates the forecast for attendance based on the current summary and goal.
  static AttendanceForecast calculateForecast(
    SubjectAttendanceSummary summary,
    double goalPercentage, // as a decimal, e.g. 0.75
  ) {
    final int present = summary.effectivePresent;
    final int total = summary.effectiveTotal;
    
    final currentPercentage = summary.attendancePercentage / 100.0;
    
    double ifAttend = 0.0;
    double ifBunk = 0.0;

    if (total + 1 > 0) {
      ifAttend = (present + 1) / (total + 1);
      ifBunk = present / (total + 1);
    } else {
      ifAttend = 1.0;
      ifBunk = 0.0;
    }

    int safeBunks = 0;
    int classesNeeded = 0;

    if (goalPercentage > 0.0) {
      if (goalPercentage >= 1.0) {
        safeBunks = 0;
        if (currentPercentage < 1.0 && total > 0) {
           classesNeeded = -1; // impossible
        } else {
           classesNeeded = 0;
        }
      } else {
        final double rawSafe = (present / goalPercentage) - total;
        safeBunks = rawSafe.isFinite && rawSafe > 0 ? rawSafe.floor() : 0;

        final double rawNeeded = (goalPercentage * total - present) / (1 - goalPercentage);
        if (rawNeeded > 0) {
          classesNeeded = rawNeeded.ceil();
        } else {
          classesNeeded = 0;
        }
      }
    } else {
      safeBunks = 999; // effectively infinite if goal is 0
      classesNeeded = 0;
    }

    return AttendanceForecast(
      currentPercentage: currentPercentage,
      projectedPercentageIfAttendNext: ifAttend,
      projectedPercentageIfBunkNext: ifBunk,
      classesNeededToReachGoal: classesNeeded,
      safeBunksRemaining: safeBunks,
    );
  }
}

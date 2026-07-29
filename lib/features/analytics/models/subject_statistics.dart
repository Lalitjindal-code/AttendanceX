import 'package:attendancex/features/dashboard/models/attendance_summary.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'analytics_trend.dart';
import 'attendance_forecast.dart';

class SubjectStatistics {
  final Subject subject;
  final SubjectAttendanceSummary summary;
  final AttendanceForecast forecast;
  final AnalyticsTrend trend;

  const SubjectStatistics({
    required this.subject,
    required this.summary,
    required this.forecast,
    required this.trend,
  });
}

import 'package:attendify/features/dashboard/models/attendance_summary.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'analytics_trend.dart';
import 'attendance_forecast.dart';

class SubjectStatistics {
  final Subject subject;
  final SubjectAttendanceSummary summary;
  final SubjectAttendanceSummary lectureSummary;
  final SubjectAttendanceSummary labSummary;
  final AttendanceForecast forecast;
  final AnalyticsTrend trend;

  const SubjectStatistics({
    required this.subject,
    required this.summary,
    required this.lectureSummary,
    required this.labSummary,
    required this.forecast,
    required this.trend,
  });
}

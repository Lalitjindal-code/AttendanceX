import 'package:attendify/database/collections/attendance_collection.dart';
import 'monthly_trend.dart';
import 'subject_statistics.dart';
import 'attendance_forecast.dart';
import 'planner_metrics.dart';
import 'day_of_week_trend.dart';
import 'package:attendify/features/dashboard/models/attendance_summary.dart';

class AnalyticsState {
  final bool isLoading;
  final String? errorMessage;
  final List<MonthlyTrend> monthlyTrends;
  final List<SubjectStatistics> subjectStats;
  final List<DayOfWeekTrend> dayOfWeekTrends;
  final Map<DateTime, int> bunkHeatmap;
  final AttendanceForecast? overallForecast;
  final OverallAttendanceSummary? overallSummary;
  final PlannerMetrics? plannerMetrics;
  final List<Attendance> allAttendances;

  const AnalyticsState({
    this.isLoading = true,
    this.errorMessage,
    this.monthlyTrends = const [],
    this.subjectStats = const [],
    this.dayOfWeekTrends = const [],
    this.bunkHeatmap = const {},
    this.overallForecast,
    this.overallSummary,
    this.plannerMetrics,
    this.allAttendances = const [],
  });

  AnalyticsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MonthlyTrend>? monthlyTrends,
    List<SubjectStatistics>? subjectStats,
    List<DayOfWeekTrend>? dayOfWeekTrends,
    Map<DateTime, int>? bunkHeatmap,
    AttendanceForecast? overallForecast,
    OverallAttendanceSummary? overallSummary,
    PlannerMetrics? plannerMetrics,
    List<Attendance>? allAttendances,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      monthlyTrends: monthlyTrends ?? this.monthlyTrends,
      subjectStats: subjectStats ?? this.subjectStats,
      dayOfWeekTrends: dayOfWeekTrends ?? this.dayOfWeekTrends,
      bunkHeatmap: bunkHeatmap ?? this.bunkHeatmap,
      overallForecast: overallForecast ?? this.overallForecast,
      overallSummary: overallSummary ?? this.overallSummary,
      plannerMetrics: plannerMetrics ?? this.plannerMetrics,
      allAttendances: allAttendances ?? this.allAttendances,
    );
  }
}

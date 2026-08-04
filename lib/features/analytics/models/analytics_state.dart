import 'monthly_trend.dart';
import 'subject_statistics.dart';
import 'attendance_forecast.dart';
import 'planner_metrics.dart';
import 'package:attendancex/features/dashboard/models/attendance_summary.dart';

class AnalyticsState {
  final bool isLoading;
  final String? errorMessage;
  final List<MonthlyTrend> monthlyTrends;
  final List<SubjectStatistics> subjectStats;
  final AttendanceForecast? overallForecast;
  final OverallAttendanceSummary? overallSummary;
  final PlannerMetrics? plannerMetrics;

  const AnalyticsState({
    this.isLoading = true,
    this.errorMessage,
    this.monthlyTrends = const [],
    this.subjectStats = const [],
    this.overallForecast,
    this.overallSummary,
    this.plannerMetrics,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MonthlyTrend>? monthlyTrends,
    List<SubjectStatistics>? subjectStats,
    AttendanceForecast? overallForecast,
    OverallAttendanceSummary? overallSummary,
    PlannerMetrics? plannerMetrics,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      monthlyTrends: monthlyTrends ?? this.monthlyTrends,
      subjectStats: subjectStats ?? this.subjectStats,
      overallForecast: overallForecast ?? this.overallForecast,
      overallSummary: overallSummary ?? this.overallSummary,
      plannerMetrics: plannerMetrics ?? this.plannerMetrics,
    );
  }
}

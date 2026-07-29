import 'monthly_trend.dart';
import 'subject_statistics.dart';
import 'attendance_forecast.dart';

class AnalyticsState {
  final bool isLoading;
  final String? errorMessage;
  final List<MonthlyTrend> monthlyTrends;
  final List<SubjectStatistics> subjectStats;
  final AttendanceForecast? overallForecast;

  const AnalyticsState({
    this.isLoading = true,
    this.errorMessage,
    this.monthlyTrends = const [],
    this.subjectStats = const [],
    this.overallForecast,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MonthlyTrend>? monthlyTrends,
    List<SubjectStatistics>? subjectStats,
    AttendanceForecast? overallForecast,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      monthlyTrends: monthlyTrends ?? this.monthlyTrends,
      subjectStats: subjectStats ?? this.subjectStats,
      overallForecast: overallForecast ?? this.overallForecast,
    );
  }
}

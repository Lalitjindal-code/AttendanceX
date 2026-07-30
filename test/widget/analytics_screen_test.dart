import 'package:attendancex/features/analytics/models/analytics_state.dart';
import 'package:attendancex/features/analytics/models/attendance_forecast.dart';
import 'package:attendancex/features/analytics/models/monthly_trend.dart';
import 'package:attendancex/features/analytics/models/subject_statistics.dart';
import 'package:attendancex/features/analytics/providers/analytics_provider.dart';
import 'package:attendancex/features/analytics/screens/analytics_screen.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAnalyticsNotifier extends AnalyticsNotifier {
  final AnalyticsState _mockState;

  FakeAnalyticsNotifier(this._mockState);

  @override
  Stream<AnalyticsState> build() async* {
    yield _mockState;
  }
}

void main() {
  Widget createWidget(AnalyticsState state) {
    return ProviderScope(
      overrides: [
        analyticsNotifierProvider.overrideWith(() => FakeAnalyticsNotifier(state)),
      ],
      child: const MaterialApp(
        home: AnalyticsScreen(),
      ),
    );
  }

  testWidgets('Analytics renders empty state', (WidgetTester tester) async {
    const state = AnalyticsState(
      isLoading: false,
      overallPercentage: null,
      monthlyTrends: [],
      subjectStats: [],
      forecast: null,
      globalGoal: 75.0,
    );

    await tester.pumpWidget(createWidget(state));
    await tester.pumpAndSettle();

    expect(find.text('Not enough data for analytics.'), findsOneWidget);
  });

  testWidgets('Analytics renders loaded state with charts and forecast', (WidgetTester tester) async {
    final state = AnalyticsState(
      isLoading: false,
      overallPercentage: 85.0,
      globalGoal: 75.0,
      monthlyTrends: [
        const MonthlyTrend(
          month: 1,
          year: 2026,
          presentCount: 20,
          totalCount: 25,
          percentage: 0.80,
        ),
      ],
      subjectStats: [
        SubjectStatistics(
          subject: Subject()..name = 'Physics'..colorValue = Colors.blue.value,
          attendancePercentage: 0.90,
          trend: 0.05,
          totalPresent: 45,
          totalClasses: 50,
        ),
      ],
      forecast: const AttendanceForecast(
        currentPercentage: 85.0,
        projectedPercentageIfAttendNext: 86.0,
        projectedPercentageIfBunkNext: 84.0,
        classesNeededToReachGoal: 0,
        safeBunksRemaining: 5,
      ),
    );

    await tester.pumpWidget(createWidget(state));
    await tester.pumpAndSettle();

    expect(find.text('85.0%'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('5 Safe Bunks Remaining'), findsOneWidget);
  });
}

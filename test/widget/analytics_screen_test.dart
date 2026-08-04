import 'package:attendancex/features/analytics/models/analytics_state.dart';
import 'package:attendancex/features/analytics/models/attendance_forecast.dart';
import 'package:attendancex/features/analytics/models/monthly_trend.dart';
import 'package:attendancex/features/analytics/models/subject_statistics.dart';
import 'package:attendancex/features/analytics/models/analytics_trend.dart';
import 'package:attendancex/features/analytics/providers/analytics_provider.dart';
import 'package:attendancex/features/analytics/screens/analytics_screen.dart';
import 'package:attendancex/features/dashboard/models/attendance_summary.dart';
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
      monthlyTrends: [],
      subjectStats: [],
    );

    await tester.pumpWidget(createWidget(state));
    await tester.pumpAndSettle();

    expect(find.text('Nothing to analyse yet.'), findsOneWidget);
  });

  testWidgets('Analytics renders loaded state with subject stats', (WidgetTester tester) async {
    final mockSummary = const SubjectAttendanceSummary(
      subjectId: 1,
      effectivePresent: 45,
      effectiveTotal: 50,
      totalPresentRecords: 45,
      totalAbsentRecords: 5,
      totalHolidayRecords: 0,
      totalMedicalRecords: 0,
      totalGTRecords: 0,
      totalPendingRecords: 0,
    );
    final mockOverallSummary = const OverallAttendanceSummary(
      effectivePresent: 45,
      effectiveTotal: 50,
      totalPresentRecords: 45,
      totalAbsentRecords: 5,
      totalHolidayRecords: 0,
      totalMedicalRecords: 0,
      totalGTRecords: 0,
      totalPendingRecords: 0,
    );
    final mockForecast = const AttendanceForecast(
      currentPercentage: 0.90,
      projectedPercentageIfAttendNext: 0.91,
      projectedPercentageIfBunkNext: 0.89,
      classesNeededToReachGoal: 0,
      safeBunksRemaining: 5,
    );

    final state = AnalyticsState(
      isLoading: false,
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
          subject: Subject()
            ..name = 'Physics'
            ..colorValue = Colors.blue.value,
          summary: mockSummary,
          forecast: mockForecast,
          trend: AnalyticsTrend.stable,
        ),
      ],
      overallForecast: const AttendanceForecast(
        currentPercentage: 0.90,
        projectedPercentageIfAttendNext: 0.91,
        projectedPercentageIfBunkNext: 0.89,
        classesNeededToReachGoal: 0,
        safeBunksRemaining: 5,
      ),
      overallSummary: mockOverallSummary,
    );

    await tester.pumpWidget(createWidget(state));
    await tester.pumpAndSettle();

    expect(find.text('Overview', skipOffstage: false), findsOneWidget);
    expect(find.text('Attendance Trend', skipOffstage: false), findsOneWidget);
    expect(find.text('Subject Breakdown', skipOffstage: false), findsOneWidget);
    expect(find.text('Phy', skipOffstage: false), findsOneWidget); // Truncated subject name
    expect(find.text('90%', skipOffstage: false), findsOneWidget); // Donut chart overall percentage
    expect(find.text('Bunks Available', skipOffstage: false), findsOneWidget);
    expect(find.text('5', skipOffstage: false), findsOneWidget); // Bunks value
  });
}

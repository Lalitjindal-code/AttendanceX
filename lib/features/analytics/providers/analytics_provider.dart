import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/engines/attendance_engine.dart';
import 'package:attendancex/features/analytics/engines/analytics_engine.dart';
import 'package:attendancex/features/analytics/models/analytics_state.dart';
import 'package:attendancex/features/analytics/models/subject_statistics.dart';
import 'package:attendancex/features/dashboard/models/attendance_summary.dart';
import 'package:attendancex/features/settings/providers/settings_provider.dart';
import 'package:attendancex/features/attendance/providers/attendance_providers.dart';
import 'package:attendancex/features/planner/providers/planner_provider.dart';
import 'package:attendancex/database/collections/academic_task_collection.dart';
import 'package:attendancex/core/enums/task_status.dart';
import 'package:attendancex/engines/planner_engine.dart';
import 'package:attendancex/features/analytics/models/planner_metrics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart' hide Subject;
import 'package:attendancex/features/subjects/providers/subject_providers.dart';

part 'analytics_provider.g.dart';

@riverpod
class AnalyticsNotifier extends _$AnalyticsNotifier {
  @override
  Stream<AnalyticsState> build() {
    final subjectRepo = ref.watch(subjectRepositoryProvider);
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    final plannerRepo = ref.watch(plannerRepositoryProvider);
    final settings = ref.watch(settingsProvider);

    return Rx.combineLatest3(
      subjectRepo.watchAll(),
      attendanceRepo.watchAll(),
      plannerRepo.watchAllTasks(),
      (List<Subject> subjects, List<Attendance> allAttendances, List<AcademicTask> allTasks) {
        if (subjects.isEmpty) {
          return const AnalyticsState(isLoading: false);
        }

        // 1. Overall Monthly Trends
        final monthlyTrends = AnalyticsEngine.calculateMonthlyTrends(allAttendances, settings);

        // 2. Overall Forecast
        final overallSummary = AttendanceEngine.calculateOverallSummary(allAttendances, settings);
        
        double avgGoal = 0.0;
        for (var sub in subjects) {
           avgGoal += sub.goalPercentage / 100.0;
        }
        avgGoal /= subjects.length;

        final dummySubjectSummary = SubjectAttendanceSummary(
          subjectId: -1,
          effectivePresent: overallSummary.effectivePresent,
          effectiveTotal: overallSummary.effectiveTotal,
          totalPresentRecords: overallSummary.totalPresentRecords,
          totalAbsentRecords: overallSummary.totalAbsentRecords,
          totalHolidayRecords: overallSummary.totalHolidayRecords,
          totalMedicalRecords: overallSummary.totalMedicalRecords,
          totalGTRecords: overallSummary.totalGTRecords,
          totalPendingRecords: overallSummary.totalPendingRecords,
        );

        final overallForecast = AnalyticsEngine.calculateForecast(dummySubjectSummary, avgGoal);

        // 3. Subject Stats
        final subjectStats = <SubjectStatistics>[];
        final now = DateTime.now();
        final currentMonth = now.month;
        final currentYear = now.year;
        final prevMonth = currentMonth == 1 ? 12 : currentMonth - 1;
        final prevYear = currentMonth == 1 ? currentYear - 1 : currentYear;

        for (final subject in subjects) {
          final subjectAttendances = allAttendances.where((a) => a.subjectId == subject.id).toList();
          
          final summary = AttendanceEngine.calculateSubjectSummary(subject.id, subjectAttendances, settings);
          final forecast = AnalyticsEngine.calculateForecast(summary, subject.goalPercentage / 100.0);

          final currentMonthAttendances = subjectAttendances.where((a) => a.date.year == currentYear && a.date.month == currentMonth).toList();
          final prevMonthAttendances = subjectAttendances.where((a) => a.date.year == prevYear && a.date.month == prevMonth).toList();

          final currentSummary = AttendanceEngine.calculateSubjectSummary(subject.id, currentMonthAttendances, settings);
          final prevSummary = AttendanceEngine.calculateSubjectSummary(subject.id, prevMonthAttendances, settings);

          final trend = AnalyticsEngine.calculateTrend(currentSummary, prevSummary);

          subjectStats.add(SubjectStatistics(
            subject: subject,
            summary: summary,
            forecast: forecast,
            trend: trend,
          ));
        }

        // 4. Planner Metrics
        final completedTasks = allTasks.where((t) => t.status == TaskStatus.completed).length;
        final overdueTasks = allTasks.where(PlannerEngine.isOverdue).length;
        final upcomingTasks = PlannerEngine.getDashboardUpcomingDeadlines(allTasks).length;
        
        final plannerMetrics = PlannerMetrics(
          totalTasks: allTasks.length,
          completedTasks: completedTasks,
          overdueTasks: overdueTasks,
          upcomingTasks: upcomingTasks,
        );

        return AnalyticsState(
          isLoading: false,
          monthlyTrends: monthlyTrends,
          subjectStats: subjectStats,
          overallForecast: overallForecast,
          overallSummary: overallSummary,
          plannerMetrics: plannerMetrics,
        );
      },
    );
  }
}

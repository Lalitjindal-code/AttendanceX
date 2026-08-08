import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/engines/attendance_engine.dart';
import 'package:attendify/features/analytics/engines/analytics_engine.dart';
import 'package:attendify/features/analytics/models/analytics_state.dart';
import 'package:attendify/features/analytics/models/subject_statistics.dart';
import 'package:attendify/features/dashboard/models/attendance_summary.dart';
import 'package:attendify/features/settings/providers/settings_provider.dart';
import 'package:attendify/features/settings/providers/semester_provider.dart';
import 'package:attendify/features/attendance/providers/attendance_providers.dart';
import 'package:attendify/features/planner/providers/planner_provider.dart';
import 'package:attendify/database/collections/academic_task_collection.dart';
import 'package:attendify/core/enums/task_status.dart';
import 'package:attendify/engines/planner_engine.dart';
import 'package:attendify/features/analytics/models/planner_metrics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart' hide Subject;
import 'package:attendify/features/subjects/providers/subject_providers.dart';

import 'package:attendify/core/enums/lecture_type.dart';
import 'package:attendify/features/schedule/providers/schedule_providers.dart';
import 'package:attendify/database/collections/schedule_collection.dart';

part 'analytics_provider.g.dart';

@riverpod
class AnalyticsNotifier extends _$AnalyticsNotifier {
  @override
  Stream<AnalyticsState> build() {
    final subjectRepo = ref.watch(subjectRepositoryProvider);
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    final plannerRepo = ref.watch(plannerRepositoryProvider);
    final scheduleRepo = ref.watch(scheduleRepositoryProvider);
    final settings = ref.watch(settingsProvider);
    final semester = ref.watch(semesterStateProvider);

    if (semester == null) {
      return Stream.value(const AnalyticsState(isLoading: false));
    }

    return Rx.combineLatest4(
      subjectRepo.watchAll(semester.id),
      attendanceRepo.watchAll(semester.id),
      plannerRepo.watchAllTasks(semester.id),
      scheduleRepo.watchAll(semester.id),
      (List<Subject> subjects, List<Attendance> allAttendances,
          List<AcademicTask> allTasks, List<Schedule> allSchedules) {
        if (subjects.isEmpty) {
          return const AnalyticsState(isLoading: false);
        }

        // 1. Overall Monthly Trends
        final monthlyTrends =
            AnalyticsEngine.calculateMonthlyTrends(allAttendances, settings, semester);

        // 1.5. Day of Week Trends & Bunk Heatmap
        final dayOfWeekTrends =
            AnalyticsEngine.calculateDayOfWeekTrends(allAttendances, settings, semester);
        final bunkHeatmap =
            AnalyticsEngine.calculateBunkHeatmap(allAttendances);

        // 2. Overall Forecast
        final overallSummary =
            AttendanceEngine.calculateOverallSummary(allAttendances, settings, semester);

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

        final overallForecast =
            AnalyticsEngine.calculateForecast(dummySubjectSummary, avgGoal);

        // 3. Subject Stats
        final subjectStats = <SubjectStatistics>[];
        final now = DateTime.now();
        final currentMonth = now.month;
        final currentYear = now.year;
        final prevMonth = currentMonth == 1 ? 12 : currentMonth - 1;
        final prevYear = currentMonth == 1 ? currentYear - 1 : currentYear;

        for (final subject in subjects) {
          final subjectAttendances =
              allAttendances.where((a) => a.subjectId == subject.id).toList();

          final summary = AttendanceEngine.calculateSubjectSummary(
              subject.id, subjectAttendances, settings, semester);
          final lectureSummary = AttendanceEngine.calculateSubjectSummaryByType(
              subject.id,
              LectureType.lecture,
              subjectAttendances,
              allSchedules,
              settings,
              semester);
          final labSummary = AttendanceEngine.calculateSubjectSummaryByType(
              subject.id,
              LectureType.lab,
              subjectAttendances,
              allSchedules,
              settings,
              semester);

          final forecast = AnalyticsEngine.calculateForecast(
              summary, subject.goalPercentage / 100.0);

          final currentMonthAttendances = subjectAttendances
              .where((a) =>
                  a.date.year == currentYear && a.date.month == currentMonth)
              .toList();
          final prevMonthAttendances = subjectAttendances
              .where(
                  (a) => a.date.year == prevYear && a.date.month == prevMonth)
              .toList();

          final currentSummary = AttendanceEngine.calculateSubjectSummary(
              subject.id, currentMonthAttendances, settings, semester);
          final prevSummary = AttendanceEngine.calculateSubjectSummary(
              subject.id, prevMonthAttendances, settings, semester);

          final trend =
              AnalyticsEngine.calculateTrend(currentSummary, prevSummary);

          subjectStats.add(SubjectStatistics(
            subject: subject,
            summary: summary,
            lectureSummary: lectureSummary,
            labSummary: labSummary,
            forecast: forecast,
            trend: trend,
          ));
        }

        // 4. Planner Metrics
        final completedTasks =
            allTasks.where((t) => t.status == TaskStatus.completed).length;
        final overdueTasks = allTasks.where(PlannerEngine.isOverdue).length;
        final upcomingTasks =
            PlannerEngine.getDashboardUpcomingDeadlines(allTasks).length;

        final plannerMetrics = PlannerMetrics(
          totalTasks: allTasks.length,
          completedTasks: completedTasks,
          overdueTasks: overdueTasks,
          upcomingTasks: upcomingTasks,
        );

        return AnalyticsState(
          isLoading: false,
          monthlyTrends: monthlyTrends,
          dayOfWeekTrends: dayOfWeekTrends,
          bunkHeatmap: bunkHeatmap,
          subjectStats: subjectStats,
          overallForecast: overallForecast,
          overallSummary: overallSummary,
          plannerMetrics: plannerMetrics,
        );
      },
    );
  }
}

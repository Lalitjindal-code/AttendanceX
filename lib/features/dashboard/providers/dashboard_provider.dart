import 'dart:async';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart' hide Subject;

import '../../../core/enums/attendance_status.dart';
import '../../../core/enums/gt_mode.dart';
import '../../../core/enums/day_of_week.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../engines/attendance_engine.dart';
import '../../settings/providers/settings_provider.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../subjects/providers/subject_providers.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../../planner/providers/planner_provider.dart';
import '../../../engines/planner_engine.dart';
import '../../../database/collections/academic_task_collection.dart';
import '../models/dashboard_state.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  Stream<DashboardState> build() {
    final settings = ref.watch(settingsProvider);
    
    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final dayOfWeek = DayOfWeek.fromInt(now.weekday);

    final scheduleStream = ref.watch(scheduleRepositoryProvider).watchByDaySortedByTime(dayOfWeek.value);
    final subjectStream = ref.watch(subjectRepositoryProvider).watchAllActive();
    final attendanceStream = ref.watch(attendanceRepositoryProvider).watchAll();
    final plannerStream = ref.watch(plannerRepositoryProvider).watchAllTasks();
    
    return Rx.combineLatest4(
      scheduleStream,
      subjectStream,
      attendanceStream,
      plannerStream,
      (List<Schedule> schedules, List<Subject> subjects, List<Attendance> allAttendances, List<AcademicTask> tasks) {
        
        final overallSummary = AttendanceEngine.calculateOverallSummary(allAttendances, settings);
        
        final overallSuggestion = AttendanceEngine.calculateSmartSuggestion(
          effectivePresent: overallSummary.effectivePresent,
          effectiveTotal: overallSummary.effectiveTotal,
          goalPercentage: settings.defaultGoalPercentage,
        );

        final todaysAttendances = allAttendances.where((a) => a.date.isAtSameMomentAs(todayUtc) || (a.date.year == now.year && a.date.month == now.month && a.date.day == now.day)).toList();
        
        final todaysLectures = schedules.map((schedule) {
          final subject = subjects.firstWhereOrNull((s) => s.id == schedule.subjectId);
          if (subject == null) return null;
          
          final attendanceForThisSlot = todaysAttendances.firstWhereOrNull((a) => a.scheduleId == schedule.id);
          
          final subjectSummary = AttendanceEngine.calculateSubjectSummary(
            subject.id,
            allAttendances,
            settings,
          );
          
          final suggestion = AttendanceEngine.calculateSmartSuggestion(
            subjectId: subject.id,
            effectivePresent: subjectSummary.effectivePresent,
            effectiveTotal: subjectSummary.effectiveTotal,
            goalPercentage: subject.goalPercentage,
          );

          return LectureCardModel(
            schedule: schedule,
            subject: subject,
            attendance: attendanceForThisSlot,
            summary: subjectSummary,
            suggestion: suggestion,
          );
        }).nonNulls.toList();

        final pendingLectures = todaysLectures
            .where((l) => l.attendance == null || l.attendance!.status == AttendanceStatus.pending)
            .toList();
            
        final markedLectures = todaysLectures
            .where((l) => l.attendance != null && l.attendance!.status != AttendanceStatus.pending)
            .toList();
            
        // Sorting
        // pendingLectures are already sorted by time due to scheduleRepositoryProvider
        // markedLectures maintain chronological order from the same repository query

        // Progress Calculation
        final totalClasses = todaysLectures.length;
        final markedCount = markedLectures.length;
        final todayProgressPercentage = totalClasses == 0 ? 0.0 : (markedCount / totalClasses);
        final todayProgressText = '$markedCount / $totalClasses Classes Marked';

        // Upcoming tasks
        final upcomingTasks = PlannerEngine.getDashboardUpcomingDeadlines(tasks);

        // Quick Stats calculation
        int attendedToday = 0;
        int totalToday = 0;
        int attendedThisWeek = 0;
        int totalThisWeek = 0;
        int attendedThisMonth = 0;
        int totalThisMonth = 0;
        
        final startOfWeek = todayUtc.subtract(Duration(days: todayUtc.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        
        for (final attendance in allAttendances) {
          if (attendance.status == AttendanceStatus.pending || attendance.status == AttendanceStatus.holiday) continue;
          
          bool isPresent = attendance.status == AttendanceStatus.present || 
            (attendance.status == AttendanceStatus.medical && settings.medicalCountsAsPresent) ||
            (attendance.status == AttendanceStatus.gt && settings.gtMode == GtMode.countAsPresent);
            
          bool isCounted = attendance.status == AttendanceStatus.present || 
            attendance.status == AttendanceStatus.absent ||
            (attendance.status == AttendanceStatus.medical && settings.medicalCountsAsPresent) ||
            (attendance.status == AttendanceStatus.gt && settings.gtMode != GtMode.exclude);

          if (!isCounted) continue;

          // Today
          if (attendance.date.year == todayUtc.year && attendance.date.month == todayUtc.month && attendance.date.day == todayUtc.day) {
            totalToday++;
            if (isPresent) attendedToday++;
          }
          
          // This week
          if (attendance.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && attendance.date.isBefore(endOfWeek.add(const Duration(seconds: 1)))) {
            totalThisWeek++;
            if (isPresent) attendedThisWeek++;
          }
          
          // This month
          if (attendance.date.year == todayUtc.year && attendance.date.month == todayUtc.month) {
            totalThisMonth++;
            if (isPresent) attendedThisMonth++;
          }
        }
        
        final quickStats = QuickStats(
          attendedToday: attendedToday,
          totalToday: totalToday,
          attendedThisWeek: attendedThisWeek,
          totalThisWeek: totalThisWeek,
          attendedThisMonth: attendedThisMonth,
          totalThisMonth: totalThisMonth,
        );

        return DashboardState(
          isLoading: false,
          pendingLectures: pendingLectures,
          markedLectures: markedLectures,
          todayProgressText: todayProgressText,
          todayProgressPercentage: todayProgressPercentage,
          overallSummary: overallSummary,
          overallSuggestion: overallSuggestion,
          upcomingTasks: upcomingTasks,
          quickStats: quickStats,
        );
      },
    ).handleError((error) {
      return DashboardState(isLoading: false, errorMessage: error.toString());
    });
  }

  Future<void> markAttendance(int scheduleId, int subjectId, AttendanceStatus status) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    
    final attendance = Attendance()
      ..scheduleId = scheduleId
      ..subjectId = subjectId
      ..date = todayUtc
      ..status = status;
      
    await repo.upsertAttendance(attendance);
  }
}

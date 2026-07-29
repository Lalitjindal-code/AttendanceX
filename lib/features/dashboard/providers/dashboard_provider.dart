import 'dart:async';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart' hide Subject;

import '../../../core/enums/attendance_status.dart';
import '../../../core/enums/day_of_week.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../engines/attendance_engine.dart';
import '../../settings/providers/settings_provider.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../subjects/providers/subject_providers.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../models/dashboard_state.dart';
import '../models/attendance_summary.dart';

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
    
    return Rx.combineLatest3(
      scheduleStream,
      subjectStream,
      attendanceStream,
      (List<Schedule> schedules, List<Subject> subjects, List<Attendance> allAttendances) {
        
        final overallSummary = AttendanceEngine.calculateOverallSummary(allAttendances, settings);
        
        final overallSuggestion = AttendanceEngine.calculateSmartSuggestion(
          effectivePresent: overallSummary.effectivePresent,
          effectiveTotal: overallSummary.effectiveTotal,
          goalPercentage: settings.defaultGoalPercentage,
        );

        final todaysAttendances = allAttendances.where((a) => a.date == todayUtc).toList();
        
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

        return DashboardState(
          isLoading: false,
          todaysLectures: todaysLectures,
          overallSummary: overallSummary,
          overallSuggestion: overallSuggestion,
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

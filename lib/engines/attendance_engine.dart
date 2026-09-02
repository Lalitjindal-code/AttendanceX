import '../core/enums/attendance_status.dart';
import '../core/enums/lecture_type.dart';
import '../database/collections/attendance_collection.dart';
import '../database/collections/schedule_collection.dart';
import '../features/dashboard/models/attendance_summary.dart';
import '../features/dashboard/models/smart_suggestion.dart';
import '../features/settings/models/app_settings.dart';

import '../database/collections/semester_collection.dart';

/// Pure business logic engine for calculating attendance percentages.
/// Never stores anything in the database.
class AttendanceEngine {
  /// Filters attendances based on semester boundaries (local calendar dates).
  static bool isWithinSemester(DateTime date, Semester semester) {
    final recordDate = DateTime(date.year, date.month, date.day);
    final start = DateTime(semester.startDate.year, semester.startDate.month,
        semester.startDate.day);

    if (recordDate.isBefore(start)) return false;

    if (semester.endDate != null) {
      final end = DateTime(semester.endDate!.year, semester.endDate!.month,
          semester.endDate!.day);
      if (recordDate.isAfter(end)) return false;
    }
    return true;
  }

  /// Calculates the attendance summary for a specific subject based on the
  /// given [attendances] and global [settings].
  static SubjectAttendanceSummary calculateSubjectSummary(
    int subjectId,
    List<Attendance> attendances,
    AppSettings settings,
    Semester semester,
  ) {
    int effectivePresent = 0;
    int effectiveTotal = 0;

    int totalPresentRecords = 0;
    int totalAbsentRecords = 0;
    int totalHolidayRecords = 0;
    int totalMedicalRecords = 0;
    int totalGTRecords = 0;
    int totalExamRecords = 0;
    int totalPendingRecords = 0;

    for (final attendance in attendances) {
      if (attendance.subjectId != subjectId) continue;
      if (!isWithinSemester(attendance.date, semester)) continue;

      switch (attendance.status) {
        case AttendanceStatus.present:
          totalPresentRecords++;
          effectivePresent++;
          effectiveTotal++;
          break;
        case AttendanceStatus.absent:
          totalAbsentRecords++;
          effectiveTotal++;
          break;
        case AttendanceStatus.holiday:
          totalHolidayRecords++;
          // Always excluded
          break;
        case AttendanceStatus.exam:
          totalExamRecords++;
          // Always excluded from calculation
          break;
        case AttendanceStatus.pending:
          totalPendingRecords++;
          // Excluded (not yet held)
          break;
        case AttendanceStatus.medical:
          totalMedicalRecords++;
          // Medical always counts as Present
          effectivePresent++;
          effectiveTotal++;
          break;
        case AttendanceStatus.gt:
          totalGTRecords++;
          // GT is always excluded from calculations (ignored like Holiday)
          break;
      }
    }

    return SubjectAttendanceSummary(
      subjectId: subjectId,
      effectivePresent: effectivePresent,
      effectiveTotal: effectiveTotal,
      totalPresentRecords: totalPresentRecords,
      totalAbsentRecords: totalAbsentRecords,
      totalHolidayRecords: totalHolidayRecords,
      totalMedicalRecords: totalMedicalRecords,
      totalGTRecords: totalGTRecords,
      totalExamRecords: totalExamRecords,
      totalPendingRecords: totalPendingRecords,
    );
  }

  /// Calculates the attendance summary for a specific subject AND specific lecture type.
  static SubjectAttendanceSummary calculateSubjectSummaryByType(
    int subjectId,
    LectureType type,
    List<Attendance> attendances,
    List<Schedule> schedules,
    AppSettings settings,
    Semester semester,
  ) {
    // Map schedule ID to its LectureType for quick lookup
    final scheduleTypeMap = {for (var s in schedules) s.id: s.type};

    // Filter attendances that match the subject and the desired lecture type
    final filteredAttendances = attendances.where((a) {
      if (a.subjectId != subjectId) return false;
      final aType = scheduleTypeMap[a.scheduleId] ?? LectureType.lecture;
      return aType == type;
    }).toList();

    return calculateSubjectSummary(
        subjectId, filteredAttendances, settings, semester);
  }

  /// Calculates the overall attendance summary aggregated across all subjects.
  static OverallAttendanceSummary calculateOverallSummary(
    List<Attendance> allAttendances,
    AppSettings settings,
    Semester semester,
  ) {
    int effectivePresent = 0;
    int effectiveTotal = 0;

    int totalPresentRecords = 0;
    int totalAbsentRecords = 0;
    int totalHolidayRecords = 0;
    int totalMedicalRecords = 0;
    int totalGTRecords = 0;
    int totalExamRecords = 0;
    int totalPendingRecords = 0;

    for (final attendance in allAttendances) {
      if (!isWithinSemester(attendance.date, semester)) continue;

      switch (attendance.status) {
        case AttendanceStatus.present:
          totalPresentRecords++;
          effectivePresent++;
          effectiveTotal++;
          break;
        case AttendanceStatus.absent:
          totalAbsentRecords++;
          effectiveTotal++;
          break;
        case AttendanceStatus.holiday:
          totalHolidayRecords++;
          break;
        case AttendanceStatus.exam:
          totalExamRecords++;
          break;
        case AttendanceStatus.pending:
          totalPendingRecords++;
          break;
        case AttendanceStatus.medical:
          totalMedicalRecords++;
          // Medical always counts as Present
          effectivePresent++;
          effectiveTotal++;
          break;
        case AttendanceStatus.gt:
          totalGTRecords++;
          // GT is always excluded from calculations (ignored like Holiday)
          break;
      }
    }

    return OverallAttendanceSummary(
      effectivePresent: effectivePresent,
      effectiveTotal: effectiveTotal,
      totalPresentRecords: totalPresentRecords,
      totalAbsentRecords: totalAbsentRecords,
      totalHolidayRecords: totalHolidayRecords,
      totalMedicalRecords: totalMedicalRecords,
      totalGTRecords: totalGTRecords,
      totalExamRecords: totalExamRecords,
      totalPendingRecords: totalPendingRecords,
    );
  }

  /// Calculates a smart suggestion (Safe Bunks or Required Classes).
  ///
  /// Safe bunks: floor((Present / Goal) - Total)
  /// Required classes: ceil((Goal * Total - Present) / (1 - Goal))
  static SmartSuggestion calculateSmartSuggestion({
    int? subjectId,
    required int effectivePresent,
    required int effectiveTotal,
    required double goalPercentage,
  }) {
    if (effectiveTotal == 0) {
      return SmartSuggestion(
        type: SmartSuggestionType.noData,
        subjectId: subjectId,
        classes: 0,
        message: 'No classes held yet.',
      );
    }

    if (goalPercentage <= 0.0) {
      return SmartSuggestion(
        type: SmartSuggestionType.onTrack,
        subjectId: subjectId,
        classes: 0,
        message: 'Goal is 0%. You are always on track.',
      );
    }

    final double goal = goalPercentage / 100.0;
    final double currentPercentage = effectivePresent / effectiveTotal;

    if (currentPercentage >= goal) {
      // Safe bunks
      final double safeBunksDouble = (effectivePresent / goal) - effectiveTotal;
      final int safeBunks = safeBunksDouble.floor();

      if (safeBunks > 0) {
        return SmartSuggestion(
          type: SmartSuggestionType.safeBunk,
          subjectId: subjectId,
          classes: safeBunks,
          message:
              'You can safely bunk $safeBunks class${safeBunks == 1 ? '' : 'es'}.',
        );
      } else {
        return SmartSuggestion(
          type: SmartSuggestionType.onTrack,
          subjectId: subjectId,
          classes: 0,
          message: 'You are exactly on track.',
        );
      }
    } else {
      // Required classes
      if (goal >= 1.0) {
        return SmartSuggestion(
          type: SmartSuggestionType.attendMore,
          subjectId: subjectId,
          classes: -1, // Impossible to reach 100% if already below
          message: 'Impossible to reach 100% attendance.',
        );
      }

      final double requiredClassesDouble =
          ((goal * effectiveTotal) - effectivePresent) / (1.0 - goal);
      final int requiredClasses = requiredClassesDouble.ceil();

      return SmartSuggestion(
        type: SmartSuggestionType.attendMore,
        subjectId: subjectId,
        classes: requiredClasses,
        message:
            'Attend $requiredClasses more class${requiredClasses == 1 ? '' : 'es'} to reach your goal.',
      );
    }
  }
}

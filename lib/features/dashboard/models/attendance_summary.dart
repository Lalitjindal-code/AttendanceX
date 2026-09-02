/// Pure data models representing calculated attendance summaries.
/// These contain no UI logic and are strictly for consumption by the Dashboard.
class SubjectAttendanceSummary {
  final int subjectId;
  final int effectivePresent;
  final int effectiveTotal;
  final int totalPresentRecords;
  final int totalAbsentRecords;
  final int totalHolidayRecords;
  final int totalMedicalRecords;
  final int totalGTRecords;
  final int totalExamRecords;
  final int totalPendingRecords;

  const SubjectAttendanceSummary({
    required this.subjectId,
    required this.effectivePresent,
    required this.effectiveTotal,
    required this.totalPresentRecords,
    required this.totalAbsentRecords,
    required this.totalHolidayRecords,
    required this.totalMedicalRecords,
    required this.totalGTRecords,
    this.totalExamRecords = 0,
    required this.totalPendingRecords,
  });

  double get attendancePercentage {
    if (effectiveTotal == 0) return 0.0;
    return (effectivePresent / effectiveTotal) * 100.0;
  }
}

class OverallAttendanceSummary {
  final int effectivePresent;
  final int effectiveTotal;
  final int totalPresentRecords;
  final int totalAbsentRecords;
  final int totalHolidayRecords;
  final int totalMedicalRecords;
  final int totalGTRecords;
  final int totalExamRecords;
  final int totalPendingRecords;

  const OverallAttendanceSummary({
    required this.effectivePresent,
    required this.effectiveTotal,
    required this.totalPresentRecords,
    required this.totalAbsentRecords,
    required this.totalHolidayRecords,
    required this.totalMedicalRecords,
    required this.totalGTRecords,
    this.totalExamRecords = 0,
    required this.totalPendingRecords,
  });

  double get attendancePercentage {
    if (effectiveTotal == 0) return 0.0;
    return (effectivePresent / effectiveTotal) * 100.0;
  }
}

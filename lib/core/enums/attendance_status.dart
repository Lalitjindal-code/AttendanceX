/// Represents the attendance status for a single lecture slot on a given date.
///
/// Only raw status values are stored in the database. Derived attendance
/// percentages are always computed by [AttendanceEngine] using these raw values.
enum AttendanceStatus {
  /// Student attended the lecture.
  present,

  /// Student was absent without reason.
  absent,

  /// Absence due to a medical reason.
  /// Behaviour is configurable via [AppSettings.medicalCountsAsPresent].
  medical,

  /// Granted Leave — college-sanctioned absence.
  /// Behaviour is configurable via [AppSettings.gtMode] ([GtMode]).
  gt,

  /// Entire day or specific slot is a holiday.
  /// Always excluded from attendance calculation. Never configurable.
  holiday,

  /// Status has not been marked yet by the student.
  pending,
}

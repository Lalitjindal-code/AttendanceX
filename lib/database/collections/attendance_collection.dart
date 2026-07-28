import 'package:isar/isar.dart';
import '../../core/enums/attendance_status.dart';

part 'attendance_collection.g.dart';

/// Isar collection for a single attendance record.
///
/// Each record corresponds to one [Schedule] slot on one specific [date].
///
/// **Critical Rule:** Only raw [status] data is stored here.
/// Percentages, safe bunks, predictions — all derived values — are computed
/// by [AttendanceEngine] on demand and are NEVER persisted.
@collection
class Attendance {
  /// Auto-incremented primary key.
  Id id = Isar.autoIncrement;

  /// The calendar date this record belongs to (stored at UTC midnight).
  @Index()
  late DateTime date;

  /// Foreign key referencing [Subject.id].
  @Index()
  int subjectId = 0;

  /// Foreign key referencing [Schedule.id].
  @Index()
  int scheduleId = 0;

  /// The student-chosen attendance status for this slot.
  @Enumerated(EnumType.name)
  AttendanceStatus status = AttendanceStatus.pending;

  /// Optional note (e.g., reason for absence). Max 300 characters.
  String? notes;

  /// Reason for the holiday if [status] is [AttendanceStatus.holiday].
  String? holidayReason;

  /// Timestamp when this record was first created.
  DateTime createdAt = DateTime.now();

  /// Timestamp of the most recent status change.
  ///
  /// Updated on every [upsertAttendance] call. Used for audit trail
  /// correlation with [AttendanceHistory] and for backup delta detection.
  DateTime updatedAt = DateTime.now();
}

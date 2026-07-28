import 'package:isar/isar.dart';
import '../../core/enums/attendance_status.dart';

part 'attendance_history_collection.g.dart';

/// Isar collection for the attendance status change audit trail.
///
/// Every time an [Attendance] record's status changes via
/// [AttendanceRepository.upsertAttendance], a new [AttendanceHistory] entry
/// is appended. This provides a complete, immutable log of all status changes.
///
/// **Immutability rule:** History entries are created once and never updated.
/// They are only deleted when the parent [Attendance] is deleted (cascade).
///
/// Use cases:
/// - Debug: "Why did this attendance change?"
/// - Analytics: Status-flip patterns over time.
/// - Backup: Full history included in JSON export.
@collection
class AttendanceHistory {
  /// Auto-incremented primary key.
  Id id = Isar.autoIncrement;

  /// Foreign key referencing [Attendance.id] this change belongs to.
  @Index()
  int attendanceId = 0;

  /// Foreign key referencing [Subject.id] for direct per-subject queries.
  @Index()
  int subjectId = 0;

  /// Copy of [Attendance.date] — allows querying history by date
  /// without joining through the attendance record.
  @Index()
  late DateTime date;

  /// The attendance status immediately before this change.
  @Enumerated(EnumType.name)
  AttendanceStatus previousStatus = AttendanceStatus.pending;

  /// The new attendance status set by this change.
  @Enumerated(EnumType.name)
  AttendanceStatus newStatus = AttendanceStatus.pending;

  /// Exact timestamp when this status change occurred.
  DateTime changedAt = DateTime.now();
}

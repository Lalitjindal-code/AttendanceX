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
  Attendance();

  /// Auto-incremented primary key.
  Id id = Isar.autoIncrement;

  /// Foreign key referencing [Semester.id].
  @Index()
  int semesterId = 0;

  /// The local calendar date this record belongs to.
  @Index()
  late DateTime date;

  /// Foreign key referencing [Subject.id].
  @Index()
  int subjectId = 0;

  /// Foreign key referencing [Schedule.id]. Nullable for manual attendance.
  @Index()
  int? scheduleId;

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'semesterId': semesterId,
      'date': date.millisecondsSinceEpoch,
      'subjectId': subjectId,
      'scheduleId': scheduleId,
      'status': status.name,
      'notes': notes,
      'holidayReason': holidayReason,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance()
      ..id = map['id'] ?? Isar.autoIncrement
      ..semesterId = map['semesterId'] ?? 0
      ..date = map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : DateTime.now()
      ..subjectId = map['subjectId'] ?? 0
      ..scheduleId = map['scheduleId']
      ..status = AttendanceStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => AttendanceStatus.pending)
      ..notes = map['notes']
      ..holidayReason = map['holidayReason']
      ..createdAt = map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now()
      ..updatedAt = map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now();
  }
}

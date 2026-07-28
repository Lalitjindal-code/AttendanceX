import 'package:isar/isar.dart';

part 'subject_collection.g.dart';

/// Isar collection representing an academic subject (course).
///
/// Only raw metadata is stored here. Attendance percentages, safe bunks,
/// required classes, and all other derived values are computed by
/// [AttendanceEngine] on demand and never persisted.
@collection
class Subject {
  /// Auto-incremented primary key.
  Id id = Isar.autoIncrement;

  /// Subject name — unique (case-insensitive), max 60 characters.
  @Index(unique: true, replace: false, caseSensitive: false)
  late String name;

  /// Faculty or instructor name. Optional.
  String? facultyName;

  /// Faculty email address. Optional.
  String? facultyEmail;

  /// Faculty phone number. Optional.
  String? facultyPhone;

  /// Academic credits for this subject. Range: 1–10.
  int credits = 3;

  /// Subject colour stored as ARGB integer (e.g., 0xFF1565C0 = blue).
  int colorValue = 0xFF1565C0;

  /// Student's personal attendance goal (%). Range: 1.0–100.0.
  double goalPercentage = 75.0;

  /// Institution-mandated minimum attendance (%). Range: 1.0–100.0.
  double minimumPercentage = 75.0;

  /// Optional personal notes about the subject. Max 300 characters.
  String? notes;

  /// Whether the subject is active (not archived).
  ///
  /// Set to [false] to archive without deleting — supports future archive feature.
  bool isActive = true;

  /// Timestamp when this subject was created.
  DateTime createdAt = DateTime.now();

  /// Timestamp when this subject was last modified.
  DateTime updatedAt = DateTime.now();
}

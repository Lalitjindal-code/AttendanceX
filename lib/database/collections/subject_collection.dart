import 'package:isar/isar.dart';

part 'subject_collection.g.dart';

/// Isar collection representing an academic subject (course).
///
/// Only raw metadata is stored here. Attendance percentages, safe bunks,
/// required classes, and all other derived values are computed by
/// [AttendanceEngine] on demand and never persisted.
@collection
class Subject {
  Subject();

  /// Auto-incremented primary key.
  Id id = Isar.autoIncrement;

  /// Foreign key referencing [Semester.id].
  @Index()
  int semesterId = 0;

  /// Subject name — unique (case-insensitive), max 60 characters.
  @Index(unique: false, replace: false, caseSensitive: false)
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

  /// Whether the subject's attendance is calculated in the overall percentage.
  bool isIncludedInOverall = true;

  /// Whether the subject is active (not archived).
  ///
  /// Set to [false] to archive without deleting — supports future archive feature.
  bool isActive = true;

  /// Timestamp when this subject was created.
  DateTime createdAt = DateTime.now();

  /// Timestamp when this subject was last modified.
  DateTime updatedAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'semesterId': semesterId,
      'name': name,
      'facultyName': facultyName,
      'facultyEmail': facultyEmail,
      'facultyPhone': facultyPhone,
      'credits': credits,
      'colorValue': colorValue,
      'goalPercentage': goalPercentage,
      'minimumPercentage': minimumPercentage,
      'notes': notes,
      'isIncludedInOverall': isIncludedInOverall,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject()
      ..id = map['id'] ?? Isar.autoIncrement
      ..semesterId = map['semesterId'] ?? 0
      ..name = map['name'] ?? 'Unknown'
      ..facultyName = map['facultyName']
      ..facultyEmail = map['facultyEmail']
      ..facultyPhone = map['facultyPhone']
      ..credits = map['credits'] ?? 3
      ..colorValue = map['colorValue'] ?? 0xFF1565C0
      ..goalPercentage = map['goalPercentage'] ?? 75.0
      ..minimumPercentage = map['minimumPercentage'] ?? 75.0
      ..notes = map['notes']
      ..isIncludedInOverall = map['isIncludedInOverall'] ?? true
      ..isActive = map['isActive'] ?? true
      ..createdAt = map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now()
      ..updatedAt = map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now();
  }
}

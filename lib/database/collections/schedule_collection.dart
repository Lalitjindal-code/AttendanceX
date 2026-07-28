import 'package:isar/isar.dart';
import '../../core/enums/lecture_type.dart';

part 'schedule_collection.g.dart';

/// Isar collection representing a single recurring weekly lecture slot.
///
/// Each [Schedule] entry defines one slot on a specific [dayOfWeek].
/// Slots repeat every week automatically — there is only one set of
/// entries, not one per week.
///
/// **Sort rules:**
/// - Dashboard, Calendar, and Notifications always sort by [startTime].
/// - The [order] field is only used for drag-and-drop in the Schedule editing screen.
@collection
class Schedule {
  /// Auto-incremented primary key.
  Id id = Isar.autoIncrement;

  /// Day of week (1 = Monday … 7 = Sunday), matching [DateTime.weekday].
  @Index()
  int dayOfWeek = 1;

  /// Foreign key referencing [Subject.id].
  @Index()
  int subjectId = 0;

  /// Start time in 24-hour format — "HH:mm" (e.g., "09:00").
  late String startTime;

  /// End time in 24-hour format — "HH:mm" (e.g., "10:00").
  late String endTime;

  /// Room or venue. Optional.
  String? room;

  /// Override faculty for this slot only.
  ///
  /// If set, shown instead of [Subject.facultyName].
  /// Useful when a different teacher takes the same subject's lab.
  String? facultyOverride;

  /// Type of lecture slot (lecture, lab, tutorial).
  @Enumerated(EnumType.name)
  LectureType type = LectureType.lecture;

  /// Display order within a day — used ONLY for the Schedule editing screen.
  ///
  /// Dashboard, Calendar, and Notifications always sort by [startTime], not [order].
  int order = 0;

  /// Timestamp when this schedule entry was created.
  DateTime createdAt = DateTime.now();
}

import 'package:isar/isar.dart';
import '../../core/enums/gt_mode.dart';

part 'profile_collection.g.dart';

@collection
class Profile {
  Profile();

  Id id = Isar.autoIncrement;

  late String name;

  bool isDefault = false;

  /// Default attendance goal percentage for this profile.
  double defaultGoalPercentage = 75.0;

  /// Whether medical absences count as present.
  bool medicalCountsAsPresent = false;

  /// How to handle GT (Guest Teacher/Duty) classes.
  @Enumerated(EnumType.name)
  GtMode gtMode = GtMode.exclude;

  /// Global notification toggle.
  bool notificationsEnabled = true;

  /// Toggle for daily summaries.
  bool dailyReminderEnabled = true;

  /// Time for daily summary (HH:mm format).
  String dailyReminderTime = '08:00';

  /// Minutes before a lecture to send a notification.
  int lectureReminderMinutes = 10;

  /// Default notification offsets for tasks (in minutes).
  List<int> defaultTaskReminderOffsets = [60, 1440];

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isDefault': isDefault,
      'defaultGoalPercentage': defaultGoalPercentage,
      'medicalCountsAsPresent': medicalCountsAsPresent,
      'gtMode': gtMode.key,
      'notificationsEnabled': notificationsEnabled,
      'dailyReminderEnabled': dailyReminderEnabled,
      'dailyReminderTime': dailyReminderTime,
      'lectureReminderMinutes': lectureReminderMinutes,
      'defaultTaskReminderOffsets': defaultTaskReminderOffsets,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile()
      ..id = map['id'] ?? Isar.autoIncrement
      ..name = map['name'] ?? 'Unknown'
      ..isDefault = map['isDefault'] ?? false
      ..defaultGoalPercentage = map['defaultGoalPercentage'] ?? 75.0
      ..medicalCountsAsPresent = map['medicalCountsAsPresent'] ?? false
      ..gtMode = GtMode.fromKey(map['gtMode'] ?? GtMode.exclude.key)
      ..notificationsEnabled = map['notificationsEnabled'] ?? true
      ..dailyReminderEnabled = map['dailyReminderEnabled'] ?? true
      ..dailyReminderTime = map['dailyReminderTime'] ?? '08:00'
      ..lectureReminderMinutes = map['lectureReminderMinutes'] ?? 10
      ..defaultTaskReminderOffsets =
          List<int>.from(map['defaultTaskReminderOffsets'] ?? [60, 1440])
      ..createdAt = map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now()
      ..updatedAt = map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now();
  }
}

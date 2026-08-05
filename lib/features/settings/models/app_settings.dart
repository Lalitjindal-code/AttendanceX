import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/enums/gt_mode.dart';

/// Immutable model representing the current user configuration state.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.isAmoled = false,
    this.defaultGoalPercentage = AppConfig.defaultGoalPercentage,
    this.medicalCountsAsPresent = false,
    this.isOnboardingComplete = false,
    this.gtMode = GtMode.exclude,
    this.semesterStartDate,
    this.semesterEndDate,
    this.notificationsEnabled = true,
    this.dailyReminderEnabled = true,
    this.dailyReminderTime = AppConfig.defaultDailyReminderTime,
    this.lectureReminderMinutes = AppConfig.defaultLectureReminderMinutes,
    this.defaultTaskReminderOffsets = const [60, 1440], // 1 hour, 1 day
    this.lastBackupDate,
    this.isAppLockEnabled = false,
  });

  final ThemeMode themeMode;

  /// Whether to use the AMOLED (true-black) dark theme.
  /// Only applies when [themeMode] is [ThemeMode.dark] or [ThemeMode.system] in dark.
  final bool isAmoled;

  final double defaultGoalPercentage;
  final bool medicalCountsAsPresent;
  final bool isOnboardingComplete;
  final GtMode gtMode;
  final DateTime? semesterStartDate;
  final DateTime? semesterEndDate;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final String dailyReminderTime;
  final int lectureReminderMinutes;
  final List<int> defaultTaskReminderOffsets;
  final DateTime? lastBackupDate;
  final bool isAppLockEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? isAmoled,
    double? defaultGoalPercentage,
    bool? medicalCountsAsPresent,
    bool? isOnboardingComplete,
    GtMode? gtMode,
    DateTime? semesterStartDate,
    DateTime? semesterEndDate,
    bool? notificationsEnabled,
    bool? dailyReminderEnabled,
    String? dailyReminderTime,
    int? lectureReminderMinutes,
    List<int>? defaultTaskReminderOffsets,
    DateTime? lastBackupDate,
    bool? isAppLockEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      isAmoled: isAmoled ?? this.isAmoled,
      defaultGoalPercentage:
          defaultGoalPercentage ?? this.defaultGoalPercentage,
      medicalCountsAsPresent:
          medicalCountsAsPresent ?? this.medicalCountsAsPresent,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      gtMode: gtMode ?? this.gtMode,
      semesterStartDate: semesterStartDate ?? this.semesterStartDate,
      semesterEndDate: semesterEndDate ?? this.semesterEndDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      lectureReminderMinutes:
          lectureReminderMinutes ?? this.lectureReminderMinutes,
      defaultTaskReminderOffsets:
          defaultTaskReminderOffsets ?? this.defaultTaskReminderOffsets,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'isAmoled': isAmoled,
      'defaultGoalPercentage': defaultGoalPercentage,
      'medicalCountsAsPresent': medicalCountsAsPresent,
      'isOnboardingComplete': isOnboardingComplete,
      'gtMode': gtMode.key,
      'semesterStartDate': semesterStartDate?.millisecondsSinceEpoch,
      'semesterEndDate': semesterEndDate?.millisecondsSinceEpoch,
      'notificationsEnabled': notificationsEnabled,
      'dailyReminderEnabled': dailyReminderEnabled,
      'dailyReminderTime': dailyReminderTime,
      'lectureReminderMinutes': lectureReminderMinutes,
      'defaultTaskReminderOffsets': defaultTaskReminderOffsets,
      'lastBackupDate': lastBackupDate?.millisecondsSinceEpoch,
      'isAppLockEnabled': isAppLockEnabled,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere((e) => e.name == map['themeMode'],
          orElse: () => ThemeMode.system),
      isAmoled: map['isAmoled'] ?? false,
      defaultGoalPercentage:
          map['defaultGoalPercentage'] ?? AppConfig.defaultGoalPercentage,
      medicalCountsAsPresent: map['medicalCountsAsPresent'] ?? false,
      isOnboardingComplete: map['isOnboardingComplete'] ?? false,
      gtMode: GtMode.fromKey(map['gtMode'] ?? GtMode.exclude.key),
      semesterStartDate: map['semesterStartDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['semesterStartDate'])
          : null,
      semesterEndDate: map['semesterEndDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['semesterEndDate'])
          : null,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      dailyReminderEnabled: map['dailyReminderEnabled'] ?? true,
      dailyReminderTime:
          map['dailyReminderTime'] ?? AppConfig.defaultDailyReminderTime,
      lectureReminderMinutes: map['lectureReminderMinutes'] ??
          AppConfig.defaultLectureReminderMinutes,
      defaultTaskReminderOffsets:
          List<int>.from(map['defaultTaskReminderOffsets'] ?? [60, 1440]),
      lastBackupDate: map['lastBackupDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastBackupDate'])
          : null,
      isAppLockEnabled: map['isAppLockEnabled'] ?? false,
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/enums/gt_mode.dart';

/// Immutable model representing the current user configuration state.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.defaultGoalPercentage = AppConfig.defaultGoalPercentage,
    this.medicalCountsAsPresent = false,
    this.gtMode = GtMode.exclude,
    this.semesterStartDate,
    this.semesterEndDate,
    this.notificationsEnabled = true,
    this.dailyReminderEnabled = true,
    this.dailyReminderTime = AppConfig.defaultDailyReminderTime,
    this.lectureReminderMinutes = AppConfig.defaultLectureReminderMinutes,
  });

  final ThemeMode themeMode;
  final double defaultGoalPercentage;
  final bool medicalCountsAsPresent;
  final GtMode gtMode;
  final DateTime? semesterStartDate;
  final DateTime? semesterEndDate;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final String dailyReminderTime;
  final int lectureReminderMinutes;

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? defaultGoalPercentage,
    bool? medicalCountsAsPresent,
    GtMode? gtMode,
    DateTime? semesterStartDate,
    DateTime? semesterEndDate,
    bool? notificationsEnabled,
    bool? dailyReminderEnabled,
    String? dailyReminderTime,
    int? lectureReminderMinutes,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultGoalPercentage: defaultGoalPercentage ?? this.defaultGoalPercentage,
      medicalCountsAsPresent: medicalCountsAsPresent ?? this.medicalCountsAsPresent,
      gtMode: gtMode ?? this.gtMode,
      semesterStartDate: semesterStartDate ?? this.semesterStartDate,
      semesterEndDate: semesterEndDate ?? this.semesterEndDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      lectureReminderMinutes: lectureReminderMinutes ?? this.lectureReminderMinutes,
    );
  }
}

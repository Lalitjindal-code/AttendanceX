import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/config/app_config.dart';
import '../../../core/enums/gt_mode.dart';
import '../../../services/preferences_service.dart';
import '../models/app_settings.dart';

part 'settings_provider.g.dart';

/// Riverpod provider managing application settings state.
///
/// Reads from and writes to [PreferencesService]. Changes to state immediately
/// trigger UI rebuilds (e.g., ThemeMode changes).
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  late PreferencesService _prefs;

  @override
  AppSettings build() {
    _prefs = PreferencesService.instance;
    return _loadSettings();
  }

  AppSettings get currentSettings => state;

  AppSettings _loadSettings() {
    final themeStr = _prefs.getString(PreferencesService.keyThemeMode,
        defaultValue: 'system');
    final ThemeMode themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final startStr =
        _prefs.getStringNullable(PreferencesService.keySemesterStart);
    final endStr = _prefs.getStringNullable(PreferencesService.keySemesterEnd);
    final lastBackupStr =
        _prefs.getStringNullable(PreferencesService.keyLastBackupDate);

    return AppSettings(
      themeMode: themeMode,
      defaultGoalPercentage: _prefs.getDouble(
        PreferencesService.keyDefaultGoal,
        defaultValue: AppConfig.defaultGoalPercentage,
      ),
      medicalCountsAsPresent: _prefs.getBool(
        PreferencesService.keyMedicalCountsAsPresent,
        defaultValue: false,
      ),
      isOnboardingComplete: _prefs.getBool(
        PreferencesService.keyIsOnboardingComplete,
        defaultValue: false,
      ),
      gtMode: GtMode.fromKey(_prefs.getString(
        PreferencesService.keyGtMode,
        defaultValue: GtMode.exclude.key,
      )),
      semesterStartDate: startStr != null ? DateTime.tryParse(startStr) : null,
      semesterEndDate: endStr != null ? DateTime.tryParse(endStr) : null,
      notificationsEnabled: _prefs.getBool(
        PreferencesService.keyNotificationsEnabled,
        defaultValue: true,
      ),
      dailyReminderEnabled: _prefs.getBool(
        PreferencesService.keyDailyReminderEnabled,
        defaultValue: true,
      ),
      dailyReminderTime: _prefs.getString(
        PreferencesService.keyDailyReminderTime,
        defaultValue: AppConfig.defaultDailyReminderTime,
      ),
      lectureReminderMinutes: _prefs.getInt(
        PreferencesService.keyLectureReminderMinutes,
        defaultValue: AppConfig.defaultLectureReminderMinutes,
      ),
      defaultTaskReminderOffsets: _prefs
          .getStringList(
            PreferencesService.keyDefaultTaskReminderOffsets,
            defaultValue: ['60', '1440'],
          )
          .map((e) => int.tryParse(e) ?? 0)
          .toList(),
      isAmoled: _prefs.getBool(
        PreferencesService.keyIsAmoled,
        defaultValue: false,
      ),
      lastBackupDate:
          lastBackupStr != null ? DateTime.tryParse(lastBackupStr) : null,
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(PreferencesService.keyThemeMode, mode.name);
  }

  Future<void> updateDefaultGoal(double goal) async {
    state = state.copyWith(defaultGoalPercentage: goal);
    await _prefs.setDouble(PreferencesService.keyDefaultGoal, goal);
  }

  Future<void> updateMedicalPolicy(bool countsAsPresent) async {
    state = state.copyWith(medicalCountsAsPresent: countsAsPresent);
    await _prefs.setBool(
        PreferencesService.keyMedicalCountsAsPresent, countsAsPresent);
  }

  Future<void> updateGtMode(GtMode mode) async {
    state = state.copyWith(gtMode: mode);
    await _prefs.setString(PreferencesService.keyGtMode, mode.key);
  }

  Future<void> updateSemesterDates(DateTime? start, DateTime? end) async {
    final normalizedStart =
        start != null ? DateTime(start.year, start.month, start.day) : null;
    final normalizedEnd =
        end != null ? DateTime(end.year, end.month, end.day) : null;

    state = state.copyWith(
        semesterStartDate: normalizedStart, semesterEndDate: normalizedEnd);

    if (normalizedStart != null) {
      await _prefs.setString(PreferencesService.keySemesterStart,
          normalizedStart.toIso8601String());
    } else {
      await _prefs.remove(PreferencesService.keySemesterStart);
    }

    if (normalizedEnd != null) {
      await _prefs.setString(
          PreferencesService.keySemesterEnd, normalizedEnd.toIso8601String());
    } else {
      await _prefs.remove(PreferencesService.keySemesterEnd);
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _prefs.setBool(PreferencesService.keyNotificationsEnabled, enabled);
  }

  Future<void> updateDailyReminderEnabled(bool enabled) async {
    state = state.copyWith(dailyReminderEnabled: enabled);
    await _prefs.setBool(PreferencesService.keyDailyReminderEnabled, enabled);
  }

  Future<void> updateDailyReminderTime(String time) async {
    state = state.copyWith(dailyReminderTime: time);
    await _prefs.setString(PreferencesService.keyDailyReminderTime, time);
  }

  Future<void> updatePlannerReminderTime(String time) async {
    // Note: not currently used, but kept for future compatibility
    await _prefs.setString(PreferencesService.keyPlannerReminderTime, time);
  }

  Future<void> updateLectureReminderMinutes(int minutes) async {
    state = state.copyWith(lectureReminderMinutes: minutes);
    await _prefs.setInt(PreferencesService.keyLectureReminderMinutes, minutes);
  }

  Future<void> updateDefaultTaskReminderOffsets(List<int> offsets) async {
    state = state.copyWith(defaultTaskReminderOffsets: offsets);
    await _prefs.setStringList(
      PreferencesService.keyDefaultTaskReminderOffsets,
      offsets.map((e) => e.toString()).toList(),
    );
  }

  /// Toggle the AMOLED true-black theme.
  /// Only takes visual effect when [ThemeMode] is dark.
  Future<void> updateIsAmoled(bool isAmoled) async {
    state = state.copyWith(isAmoled: isAmoled);
    await _prefs.setBool(PreferencesService.keyIsAmoled, isAmoled);
  }

  Future<void> updateLastBackupDate(DateTime date) async {
    state = state.copyWith(lastBackupDate: date);
    await _prefs.setString(
        PreferencesService.keyLastBackupDate, date.toIso8601String());
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isOnboardingComplete: true);
    await _prefs.setBool(PreferencesService.keyIsOnboardingComplete, true);
  }
}

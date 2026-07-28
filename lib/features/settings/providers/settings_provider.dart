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

  AppSettings _loadSettings() {
    final themeStr = _prefs.getString(PreferencesService.keyThemeMode, defaultValue: 'system');
    final ThemeMode themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final startStr = _prefs.getStringNullable(PreferencesService.keySemesterStart);
    final endStr = _prefs.getStringNullable(PreferencesService.keySemesterEnd);

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
    await _prefs.setBool(PreferencesService.keyMedicalCountsAsPresent, countsAsPresent);
  }

  Future<void> updateGtMode(GtMode mode) async {
    state = state.copyWith(gtMode: mode);
    await _prefs.setString(PreferencesService.keyGtMode, mode.key);
  }

  // Other update methods to be implemented as needed.
}

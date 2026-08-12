import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../../core/enums/gt_mode.dart';
import '../../../services/preferences_service.dart';
import '../../../database/database_providers.dart';
import '../../../database/collections/profile_collection.dart';
import '../../../database/repositories/profile_repository.dart';
import '../models/app_settings.dart';
import '../../../services/widget_service.dart';

part 'settings_provider.g.dart';

/// Riverpod provider managing application settings state.
///
/// Reads from and writes to [PreferencesService] and Isar [Profile].
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  late PreferencesService _prefs;
  late Isar _isar;
  late Profile _activeProfile;

  @override
  AppSettings build() {
    _prefs = PreferencesService.instance;
    _isar = ref.watch(isarProvider);
    return _loadSettings();
  }

  AppSettings get currentSettings => state;

  AppSettings _loadSettings() {
    final themeStr = _prefs.getString(PreferencesService.keyThemeMode, defaultValue: 'system');
    final ThemeMode themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final lastBackupStr = _prefs.getStringNullable(PreferencesService.keyLastBackupDate);
    final activeProfileId = _prefs.getInt('active_profile_id', defaultValue: 1);
    
    _activeProfile = _isar.profiles.getSync(activeProfileId) ?? Profile();

    final enabledTaskTypes = _prefs.getStringList(
      'enabled_task_types',
      defaultValue: const [
        'assignment',
        'homework',
        'quiz',
        'labFile',
        'practical',
        'viva',
        'assessment',
        'midSem',
        'endSem',
        'project',
        'presentation',
        'seminar',
        'internship',
        'other',
      ],
    );

    return AppSettings(
      themeMode: themeMode,
      defaultGoalPercentage: _activeProfile.defaultGoalPercentage,
      medicalCountsAsPresent: _activeProfile.medicalCountsAsPresent,
      isOnboardingComplete: _prefs.getBool(PreferencesService.keyIsOnboardingComplete, defaultValue: false),
      gtMode: _activeProfile.gtMode,
      semesterStartDate: null, // Removed from AppSettings (now in Semester)
      semesterEndDate: null,   // Removed from AppSettings (now in Semester)

      notificationsEnabled: _activeProfile.notificationsEnabled,
      dailyReminderEnabled: _activeProfile.dailyReminderEnabled,
      dailyReminderTime: _activeProfile.dailyReminderTime,
      lectureReminderMinutes: _activeProfile.lectureReminderMinutes,
      defaultTaskReminderOffsets: _activeProfile.defaultTaskReminderOffsets,
      isAmoled: _prefs.getBool(
        PreferencesService.keyIsAmoled,
        defaultValue: false,
      ),
      lastBackupDate:
          lastBackupStr != null ? DateTime.tryParse(lastBackupStr) : null,
      isAppLockEnabled: _prefs.getBool(
        PreferencesService.keyIsAppLockEnabled,
        defaultValue: false,
      ),
      enabledTaskTypes: enabledTaskTypes,
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(PreferencesService.keyThemeMode, mode.name);
    WidgetService.instance.updateWidget();
  }

  Future<void> updateDefaultGoal(double goal) async {
    state = state.copyWith(defaultGoalPercentage: goal);
    _activeProfile.defaultGoalPercentage = goal;
    await ref.read(profileRepositoryProvider).upsertProfile(_activeProfile);
    WidgetService.instance.updateWidget();
  }

  Future<void> updateMedicalPolicy(bool countsAsPresent) async {
    state = state.copyWith(medicalCountsAsPresent: countsAsPresent);
    _activeProfile.medicalCountsAsPresent = countsAsPresent;
    await ref.read(profileRepositoryProvider).upsertProfile(_activeProfile);
  }

  Future<void> updateGtMode(GtMode mode) async {
    state = state.copyWith(gtMode: mode);
    _activeProfile.gtMode = mode;
    await ref.read(profileRepositoryProvider).upsertProfile(_activeProfile);
  }

  Future<void> updateSemesterDates(DateTime? start, DateTime? end) async {
    // Deprecated in SettingsProvider, now managed by SemesterProvider.
    // Keeping method signature to prevent breakage until fully migrated.
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    _activeProfile.notificationsEnabled = enabled;
    await ref.read(profileRepositoryProvider).upsertProfile(_activeProfile);
    await _prefs.setBool(PreferencesService.keyNotificationsEnabled, enabled);
  }

  Future<void> updateDailyReminderEnabled(bool enabled) async {
    state = state.copyWith(dailyReminderEnabled: enabled);
    _activeProfile.dailyReminderEnabled = enabled;
    await ref.read(profileRepositoryProvider).upsertProfile(_activeProfile);
  }

  Future<void> updateDailyReminderTime(String time) async {
    state = state.copyWith(dailyReminderTime: time);
    _activeProfile.dailyReminderTime = time;
    await ref.read(profileRepositoryProvider).upsertProfile(_activeProfile);
  }

  Future<void> updatePlannerReminderTime(String time) async {
    // Note: not currently used, but kept for future compatibility
  }

  Future<void> updateLectureReminderMinutes(int minutes) async {
    state = state.copyWith(lectureReminderMinutes: minutes);
    _activeProfile.lectureReminderMinutes = minutes;
    await ref.read(profileRepositoryProvider).upsertProfile(_activeProfile);
  }

  Future<void> updateDefaultTaskReminderOffsets(List<int> offsets) async {
    state = state.copyWith(defaultTaskReminderOffsets: offsets);
    _activeProfile.defaultTaskReminderOffsets = offsets;
    await ref.read(profileRepositoryProvider).upsertProfile(_activeProfile);
  }

  /// Toggle the AMOLED true-black theme.
  /// Only takes visual effect when [ThemeMode] is dark.
  Future<void> updateIsAmoled(bool isAmoled) async {
    state = state.copyWith(isAmoled: isAmoled);
    await _prefs.setBool(PreferencesService.keyIsAmoled, isAmoled);
    WidgetService.instance.updateWidget();
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

  Future<void> updateIsAppLockEnabled(bool enabled) async {
    state = state.copyWith(isAppLockEnabled: enabled);
    await _prefs.setBool(PreferencesService.keyIsAppLockEnabled, enabled);
  }

  Future<void> setOnboardingStatus(bool isComplete) async {
    state = state.copyWith(isOnboardingComplete: isComplete);
    await _prefs.setBool(PreferencesService.keyIsOnboardingComplete, isComplete);
  }

  Future<void> updateEnabledTaskTypes(List<String> types) async {
    state = state.copyWith(enabledTaskTypes: types);
    await _prefs.setStringList('enabled_task_types', types);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service wrapping [SharedPreferences].
///
/// Must be initialized via [initialize] before use. Provides synchronous
/// access to typed preferences.
class PreferencesService {
  PreferencesService._();

  static final PreferencesService _instance = PreferencesService._();
  static PreferencesService get instance => _instance;

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    assert(
      _prefs != null,
      'PreferencesService.initialize() must be called before accessing prefs.',
    );
    return _prefs!;
  }

  // ── Keys ──────────────────────────────────────────────────────────────────────
  static const String keyThemeMode = 'theme_mode';
  static const String keyDefaultGoal = 'default_goal_percentage';
  static const String keyMedicalCountsAsPresent = 'medical_counts_as_present';
  static const String keyGtMode = 'gt_mode';
  static const String keySemesterStart = 'semester_start_date';
  static const String keySemesterEnd = 'semester_end_date';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyDailyReminderEnabled = 'daily_reminder_enabled';
  static const String keyDailyReminderTime = 'daily_reminder_time';
  static const String keyLectureReminderMinutes = 'lecture_reminder_minutes';
  static const String keyPlannerReminderTime = 'planner_reminder_time';
  static const String keyDefaultTaskReminderOffsets =
      'default_task_reminder_offsets';
  static const String keyIsAmoled = 'is_amoled';
  static const String keyLastBackupDate = 'last_backup_date';
  static const String keyIsOnboardingComplete = 'is_onboarding_complete';
  static const String keyIsAppLockEnabled = 'is_app_lock_enabled';
  static const String keyHasShownDashboardTutorial = 'has_shown_dashboard_tutorial';

  // Ad-related keys
  static const String keyAdFreeUntil = 'ad_free_until';
  static const String keyLastInterstitialTime = 'last_interstitial_time';

  // ── Contains ──────────────────────────────────────────────────────────────────
  bool containsKey(String key) => prefs.containsKey(key);

  // ── Getters ───────────────────────────────────────────────────────────────────
  String getString(String key, {required String defaultValue}) {
    return prefs.getString(key) ?? defaultValue;
  }

  String? getStringNullable(String key) {
    return prefs.getString(key);
  }

  bool getBool(String key, {required bool defaultValue}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  double getDouble(String key, {required double defaultValue}) {
    return prefs.getDouble(key) ?? defaultValue;
  }

  int getInt(String key, {required int defaultValue}) {
    return prefs.getInt(key) ?? defaultValue;
  }

  List<String> getStringList(String key, {required List<String> defaultValue}) {
    return prefs.getStringList(key) ?? defaultValue;
  }

  // ── Setters ───────────────────────────────────────────────────────────────────
  Future<void> setString(String key, String value) =>
      prefs.setString(key, value);
  Future<void> setBool(String key, bool value) => prefs.setBool(key, value);
  Future<void> setDouble(String key, double value) =>
      prefs.setDouble(key, value);
  Future<void> setInt(String key, int value) => prefs.setInt(key, value);
  Future<void> setStringList(String key, List<String> value) =>
      prefs.setStringList(key, value);
  Future<void> remove(String key) => prefs.remove(key);
}

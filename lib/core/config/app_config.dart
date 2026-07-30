/// Global compile-time constants for the AttendanceX application.
///
/// These are fixed at build time. User-overridable preferences are
/// managed by [PreferencesService] and exposed via [AppSettings].
abstract final class AppConfig {
  AppConfig._();

  // ── Identity ────────────────────────────────────────────────────────────────
  static const String appName = 'Attendify';
  static const String packageName = 'com.lalitjindal.attendify';
  static const String version = '1.0.0';
  static const int buildNumber = 1;

  // ── Attendance Defaults ──────────────────────────────────────────────────────
  /// Default attendance goal percentage (75%).
  static const double defaultGoalPercentage = 75.0;

  /// Institution-mandated minimum attendance percentage (75%).
  static const double defaultMinimumPercentage = 75.0;

  // ── Thresholds ───────────────────────────────────────────────────────────────
  /// Below this → low-attendance warning (amber).
  static const double riskThreshold = 75.0;

  /// Below this → critical attendance warning (red).
  static const double dangerThreshold = 65.0;

  // ── Notification Defaults ─────────────────────────────────────────────────────
  static const int defaultLectureReminderMinutes = 15;
  static const String defaultDailyReminderTime = '20:00';

  // ── Validation Limits ────────────────────────────────────────────────────────
  static const int maxSubjectNameLength = 60;
  static const int maxNotesLength = 300;
  static const int minCredits = 1;
  static const int maxCredits = 10;
  static const double minGoalPercentage = 1.0;
  static const double maxGoalPercentage = 100.0;

  // ── Database ─────────────────────────────────────────────────────────────────
  static const String isarDbName = 'attendify_db';
}

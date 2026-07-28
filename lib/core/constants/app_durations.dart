/// Animation duration tokens.
///
/// All animated widgets must reference these constants.
/// Never use arbitrary [Duration] literals in widget files.
abstract final class AppDurations {
  AppDurations._();

  /// 100ms — instant tap feedback (ripple, icon swap).
  static const Duration instant = Duration(milliseconds: 100);

  /// 150ms — fast micro-animations (status button highlight).
  static const Duration fast = Duration(milliseconds: 150);

  /// 200ms — standard transitions (color change, scale).
  static const Duration normal = Duration(milliseconds: 200);

  /// 300ms — card expansions, route transitions.
  static const Duration medium = Duration(milliseconds: 300);

  /// 400ms — complex enter animations (chart bar reveal).
  static const Duration slow = Duration(milliseconds: 400);

  /// 600ms — full-page hero transitions.
  static const Duration xSlow = Duration(milliseconds: 600);

  // ── Snackbar Durations ────────────────────────────────────────────────────────

  /// 2 seconds — standard snackbar.
  static const Duration snackbar = Duration(seconds: 2);

  /// 3 seconds — long snackbar with action.
  static const Duration snackbarLong = Duration(seconds: 3);

  // ── Skeleton Loading ──────────────────────────────────────────────────────────

  /// 1200ms — skeleton shimmer loop cycle.
  static const Duration shimmer = Duration(milliseconds: 1200);
}

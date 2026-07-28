/// 8-point grid spacing system.
///
/// All padding and gap values must come from this class.
/// Never use arbitrary numeric literals for spacing in widget files.
abstract final class AppSpacing {
  AppSpacing._();

  /// 4dp — tight gap (icon-to-text, badge padding).
  static const double xs = 4.0;

  /// 8dp — small gap (within card content, list item gap).
  static const double sm = 8.0;

  /// 12dp — compact padding (chip, tag).
  static const double md = 12.0;

  /// 16dp — standard screen horizontal/vertical padding.
  static const double lg = 16.0;

  /// 20dp — medium-large gap.
  static const double xl = 20.0;

  /// 24dp — section separation.
  static const double xxl = 24.0;

  /// 32dp — large layout gaps.
  static const double xxxl = 32.0;

  /// 40dp — hero element spacing.
  static const double huge = 40.0;

  /// 48dp — maximum standard spacing.
  static const double massive = 48.0;

  // ── Named Semantic Values ────────────────────────────────────────────────────

  /// Standard horizontal screen edge padding (16dp).
  static const double screenH = lg;

  /// Standard vertical screen padding (16dp).
  static const double screenV = lg;

  /// Card internal content padding (16dp).
  static const double cardPadding = lg;

  /// Gap between list items (8dp).
  static const double listGap = sm;

  /// Minimum touch target per accessibility guidelines (48dp).
  static const double touchTarget = 48.0;
}

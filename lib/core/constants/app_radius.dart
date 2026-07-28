/// Corner radius tokens for the design system.
///
/// All [BorderRadius] values in the application must reference these constants
/// to maintain visual consistency.
abstract final class AppRadius {
  AppRadius._();

  /// 4dp — micro-radius (badge, indicator dot).
  static const double xs = 4.0;

  /// 8dp — small component radius (chips, small buttons).
  static const double sm = 8.0;

  /// 12dp — input fields.
  static const double md = 12.0;

  /// 14dp — buttons.
  static const double button = 14.0;

  /// 16dp — cards and FAB.
  static const double card = 16.0;

  /// 20dp — confirmation dialogs.
  static const double dialog = 20.0;

  /// 24dp — bottom sheets (top corners only).
  static const double bottomSheet = 24.0;

  /// 28dp — large hero cards (analytics, dashboard ring card).
  static const double largeCard = 28.0;

  /// 999dp — fully circular (avatar, progress ring, icon button).
  static const double circular = 999.0;
}

import 'package:flutter/material.dart';

/// Seed color and generated [ColorScheme]s for AttendanceX.
///
/// Uses Material 3's [ColorScheme.fromSeed] to derive a harmonious
/// full palette (primary, secondary, tertiary, surface, error, etc.)
/// from a single [seedColor] for both light and dark modes.
abstract final class AppColorScheme {
  AppColorScheme._();

  /// Primary brand seed color — Deep Blue 800 (#1565C0).
  ///
  /// All theme colors are algorithmically derived from this single value
  /// by Material 3's tone-mapping system.
  static const Color seedColor = Color(0xFF1565C0);

  /// Light theme [ColorScheme], derived from [seedColor].
  static final ColorScheme light = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  /// Dark theme [ColorScheme], derived from [seedColor].
  static final ColorScheme dark = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
}

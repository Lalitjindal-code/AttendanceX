import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 type scale using Plus Jakarta Sans — Meridian design language.
///
/// Call [AppTextTheme.build] with the platform-default [TextTheme] to
/// produce a Plus Jakarta Sans-based theme preserving M3 role semantics.
///
/// Scale logic:
///   - Display      → 400 weight, tight letter-spacing (expressive hero stats)
///   - Headline     → 700 weight, normal spacing (bold section titles)
///   - Title        → 600 weight, slight tracking (card/dialog heads)
///   - Body         → 400 weight, comfortable leading (readable content)
///   - Label        → 600 weight, wide tracking (buttons, chips, nav)
abstract final class AppTextTheme {
  AppTextTheme._();

  /// Builds a Plus Jakarta Sans [TextTheme] from the given [base] theme.
  static TextTheme build(TextTheme base) {
    return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
      // ── Display ─────────────────────────────────────────────────────────────
      // Large hero stats, percentage numbers, dashboard big text
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.0,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.22,
      ),

      // ── Headline ─────────────────────────────────────────────────────────────
      // Screen titles, modal titles, section heads
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
      ),

      // ── Title ────────────────────────────────────────────────────────────────
      // Card headings, dialog titles, section labels
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // ── Body ─────────────────────────────────────────────────────────────────
      // Primary reading content, descriptions, list items
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.33,
      ),

      // ── Label ────────────────────────────────────────────────────────────────
      // Buttons, chips, navigation labels, badges
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }
}

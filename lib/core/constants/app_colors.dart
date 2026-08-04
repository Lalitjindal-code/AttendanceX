import 'package:flutter/material.dart';

/// Semantic color tokens for attendance status, risk levels, and task priority.
///
/// These are fixed semantic colors independent of the theme seed generation.
/// Theme-adaptive surface/background colors come from [Theme.of(context).colorScheme].
///
/// All values are aligned with [AppColorScheme]'s semantic override tokens.
abstract final class AppColors {
  AppColors._();

  // ── Attendance Status — Light ────────────────────────────────────────────────

  /// ✓ Present — Emerald (#10B981)
  static const Color present = Color(0xFF10B981);
  static const Color presentContainer = Color(0xFFD1FAE5);
  static const Color presentContainerDark = Color(0xFF064E3B);

  /// ✗ Absent — Rose red (#EF4444)
  static const Color absent = Color(0xFFEF4444);
  static const Color absentContainer = Color(0xFFFEE2E2);
  static const Color absentContainerDark = Color(0xFF7F1D1D);

  /// 🏥 Medical — Amber (#F59E0B)
  static const Color medical = Color(0xFFF59E0B);
  static const Color medicalContainer = Color(0xFFFEF3C7);
  static const Color medicalContainerDark = Color(0xFF78350F);

  /// 🎖 GT / Duty — Violet (#8B5CF6)
  static const Color gt = Color(0xFF8B5CF6);
  static const Color gtContainer = Color(0xFFEDE9FE);
  static const Color gtContainerDark = Color(0xFF3B0764);

  /// 🏖 Holiday — Indigo (#6366F1)
  static const Color holiday = Color(0xFF6366F1);
  static const Color holidayContainer = Color(0xFFE0E7FF);
  static const Color holidayContainerDark = Color(0xFF312E81);

  /// ⏳ Pending — Slate (#94A3B8)
  static const Color pending = Color(0xFF94A3B8);
  static const Color pendingContainer = Color(0xFFF1F5F9);
  static const Color pendingContainerDark = Color(0xFF1E293B);

  // ── Attendance Status — Dark (lighter variants) ──────────────────────────────

  static const Color presentDark = Color(0xFF34D399);
  static const Color absentDark = Color(0xFFF87171);
  static const Color medicalDark = Color(0xFFFCD34D);
  static const Color gtDark = Color(0xFFA78BFA);
  static const Color holidayDark = Color(0xFF818CF8);
  static const Color pendingDark = Color(0xFF94A3B8);

  // ── Risk Levels ───────────────────────────────────────────────────────────────

  /// Attendance at or above goal. (≥ goal%)
  static const Color safe = Color(0xFF10B981);

  /// Attendance below goal but above 75%. (goal% > x ≥ 75%)
  static const Color atRisk = Color(0xFFF59E0B);

  /// Attendance below 75%.
  static const Color danger = Color(0xFFEF4444);

  // ── Task Priority ─────────────────────────────────────────────────────────────

  static const Color taskCritical = Color(0xFFEF4444);
  static const Color taskHigh = Color(0xFFF97316);
  static const Color taskMedium = Color(0xFF3B82F6);
  static const Color taskLow = Color(0xFF10B981);
}

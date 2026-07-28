import 'package:flutter/material.dart';

/// Semantic color tokens for status and meaning — separate from theme colors.
///
/// Theme-adaptive colors (surfaces, backgrounds, etc.) must come from
/// [Theme.of(context).colorScheme]. Only use [AppColors] for attendance-status
/// colors and semantic indicators that must remain constant across themes.
abstract final class AppColors {
  AppColors._();

  // ── Attendance Status ────────────────────────────────────────────────────────

  static const Color present = Color(0xFF2E7D32);
  static const Color presentContainer = Color(0xFFE8F5E9);
  static const Color presentContainerDark = Color(0xFF1B3A1B);

  static const Color absent = Color(0xFFC62828);
  static const Color absentContainer = Color(0xFFFFEBEE);
  static const Color absentContainerDark = Color(0xFF3A1B1B);

  static const Color medical = Color(0xFFE65100);
  static const Color medicalContainer = Color(0xFFFFF3E0);
  static const Color medicalContainerDark = Color(0xFF3A2A1B);

  static const Color gt = Color(0xFF0277BD);
  static const Color gtContainer = Color(0xFFE1F5FE);
  static const Color gtContainerDark = Color(0xFF1B2A3A);

  static const Color holiday = Color(0xFF546E7A);
  static const Color holidayContainer = Color(0xFFECEFF1);
  static const Color holidayContainerDark = Color(0xFF2A2E30);

  static const Color pending = Color(0xFF78909C);
  static const Color pendingContainer = Color(0xFFF5F5F5);
  static const Color pendingContainerDark = Color(0xFF2A2E30);

  // ── Risk Levels ───────────────────────────────────────────────────────────────

  /// Attendance at or above goal.
  static const Color safe = Color(0xFF2E7D32);

  /// Attendance below goal but above danger threshold.
  static const Color atRisk = Color(0xFFE65100);

  /// Attendance below danger threshold.
  static const Color danger = Color(0xFFC62828);
}

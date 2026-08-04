import 'package:flutter/services.dart';

/// A utility class for providing consistent haptic feedback across the app.
class Haptics {
  const Haptics._();

  /// Triggered on small interactions like toggling a switch or selecting a chip.
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Triggered on successful actions like marking attendance or completing a task.
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Triggered on more significant actions, like opening a bottom sheet.
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Triggered on destructive actions or errors.
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }
}

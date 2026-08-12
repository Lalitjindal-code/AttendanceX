import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ad_eligibility_service.dart';

/// Provider exposing the current Ad-Free state to the UI.
///
/// Refreshes automatically to keep the UI in sync if the timer expires
/// or if invalidated when a reward is earned.
final adFreeProvider = StateNotifierProvider<AdFreeNotifier, bool>((ref) {
  return AdFreeNotifier();
});

class AdFreeNotifier extends StateNotifier<bool> {
  Timer? _timer;

  AdFreeNotifier() : super(AdEligibilityService.isAdFree) {
    _startTimer();
  }

  void _startTimer() {
    // Check every minute if the status has changed (expired).
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final currentStatus = AdEligibilityService.isAdFree;
      if (state != currentStatus) {
        state = currentStatus;
      }
    });
  }

  /// Manually force a re-evaluation (e.g. immediately after reward is earned)
  void refresh() {
    state = AdEligibilityService.isAdFree;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

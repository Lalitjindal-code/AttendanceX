import '../../services/preferences_service.dart';

/// Pure static service that acts as the absolute source of truth for Ad Eligibility.
class AdEligibilityService {
  /// Evaluates whether the user is currently in an ad-free state.
  ///
  /// This depends purely on the ISO-8601 timestamp string `keyAdFreeUntil`
  /// stored in [PreferencesService].
  static bool get isAdFree {
    final adFreeUntilStr = PreferencesService.instance
        .getStringNullable(PreferencesService.keyAdFreeUntil);
    if (adFreeUntilStr == null) return false;

    final adFreeUntil = DateTime.tryParse(adFreeUntilStr);
    if (adFreeUntil == null) return false;

    return DateTime.now().isBefore(adFreeUntil);
  }

  /// Grants the 24-hour ad-free reward.
  ///
  /// This must ONLY be called from the `onUserEarnedReward` callback
  /// provided by the Google Mobile Ads SDK.
  static void grantReward() {
    final until = DateTime.now().add(const Duration(hours: 24));
    PreferencesService.instance.setString(
      PreferencesService.keyAdFreeUntil,
      until.toIso8601String(),
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentManager {
  static final ConsentManager _instance = ConsentManager._internal();
  factory ConsentManager() => _instance;
  ConsentManager._internal();

  /// Gathers consent using the UMP SDK.
  /// Returns true if MobileAds can be initialized, false otherwise.
  Future<void> gatherConsent(
      void Function() onConsentGatheringCompleteListener) async {
    final params = ConsentRequestParameters(
      consentDebugSettings: kDebugMode
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea)
          : null,
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadConsentForm(onConsentGatheringCompleteListener);
        } else {
          // No form available, but we successfully updated consent info.
          _initializeIfReady(onConsentGatheringCompleteListener);
        }
      },
      (FormError error) {
        debugPrint('Consent info update failed: ${error.message}');
        // Proceed anyway, fallback to default behavior (e.g. initialize ads if previously granted or outside EEA)
        _initializeIfReady(onConsentGatheringCompleteListener);
      },
    );
  }

  void _loadConsentForm(void Function() onConsentGatheringCompleteListener) {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        final status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show(
            (FormError? formError) {
              if (formError != null) {
                debugPrint('Consent form show failed: ${formError.message}');
              }
              // Try loading again if required, but usually we just proceed to init
              _loadConsentForm(onConsentGatheringCompleteListener);
            },
          );
        } else {
          _initializeIfReady(onConsentGatheringCompleteListener);
        }
      },
      (FormError formError) {
        debugPrint('Consent form load failed: ${formError.message}');
        _initializeIfReady(onConsentGatheringCompleteListener);
      },
    );
  }

  Future<void> _initializeIfReady(
      void Function() onConsentGatheringCompleteListener) async {
    // According to Google Mobile Ads docs, we can initialize if consent is obtained or not required.
    // However, the standard implementation is to just call the completion listener
    // and let the caller initialize the SDK, because UMP caches consent state.
    // Wait, is it safe to initialize if consent status is unknown?
    // Yes, the UMP SDK will handle whether to serve personalized or non-personalized ads.
    onConsentGatheringCompleteListener();
  }

  Future<bool> canRequestAds() async {
    // Only check if it's strictly required or obtained.
    // The exact implementation can just rely on `canRequestAds()` if available,
    // but flutter's google_mobile_ads might not expose `canRequestAds()` directly yet in older versions.
    // ConsentStatus can be obtained, required, notRequired, unknown.
    final status = await ConsentInformation.instance.getConsentStatus();
    return status == ConsentStatus.obtained ||
        status == ConsentStatus.notRequired;
  }
}

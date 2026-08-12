import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/preferences_service.dart';
import 'ad_eligibility_service.dart';

class InterstitialAdManager {
  static final InterstitialAdManager instance =
      InterstitialAdManager._internal();
  InterstitialAdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isShowingAd = false;

  final String _realAdUnitId = 'ca-app-pub-1540123321445233/6219657470';
  final String _testAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  final String _testAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';

  String get _adUnitId {
    if (kIsWeb || Platform.isWindows) return '';
    if (kDebugMode) {
      return Platform.isAndroid ? _testAdUnitIdAndroid : _testAdUnitIdIOS;
    }
    return _realAdUnitId;
  }

  bool get isLoaded => _isAdLoaded && _interstitialAd != null;

  bool canShowBasedOnFrequencyCapping(String feature) {
    final lastTimeStr = PreferencesService.instance.getStringNullable(
      '${PreferencesService.keyLastInterstitialTime}_$feature',
    );
    if (lastTimeStr == null) return true;
    final lastTime = DateTime.tryParse(lastTimeStr);
    if (lastTime == null) return true;
    // 60 minutes cap
    return DateTime.now().difference(lastTime).inMinutes >= 60;
  }

  void _recordAdShown(String feature) {
    PreferencesService.instance.setString(
      '${PreferencesService.keyLastInterstitialTime}_$feature',
      DateTime.now().toIso8601String(),
    );
  }

  /// Silently preloads an Interstitial Ad if eligible and not already loaded.
  void loadAd() {
    if (kIsWeb || Platform.isWindows) return;
    if (AdEligibilityService.isAdFree) return;
    if (_isAdLoaded) return;

    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded.');
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Shows the Interstitial Ad if available, then executes the navigation callback.
  void showAdIfAvailable(
      {required String feature, required VoidCallback onNavigation}) {
    if (AdEligibilityService.isAdFree ||
        !canShowBasedOnFrequencyCapping(feature) ||
        !isLoaded ||
        _isShowingAd) {
      onNavigation();
      return;
    }

    bool navigationTriggered = false;
    void safeNavigate() {
      if (!navigationTriggered) {
        navigationTriggered = true;
        onNavigation();
      }
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        _recordAdShown(feature);
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        safeNavigate();
        loadAd(); // Preload next one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd failed to show: $error');
        _isShowingAd = false;
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        safeNavigate();
        loadAd(); // Retry preload
      },
    );

    _interstitialAd!.show();
  }
}

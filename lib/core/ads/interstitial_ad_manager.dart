import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../../services/preferences_service.dart';
import 'ad_eligibility_service.dart';
import 'ad_network_controller.dart';

class InterstitialAdManager {
  static final InterstitialAdManager instance =
      InterstitialAdManager._internal();
  InterstitialAdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isShowingAd = false;

  final String _realAdMobUnitId = 'ca-app-pub-1540123321445233/6219657470';
  final String _testAdMobUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  final String _testAdMobUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';

  final String _unityAdUnitIdAndroid = 'Interstitial_Android';
  final String _unityAdUnitIdIOS = 'Interstitial_iOS';

  String get _adMobUnitId {
    if (kIsWeb || Platform.isWindows) return '';
    if (kDebugMode) {
      return Platform.isAndroid ? _testAdMobUnitIdAndroid : _testAdMobUnitIdIOS;
    }
    return _realAdMobUnitId;
  }

  String get _unityAdUnitId {
    return Platform.isAndroid ? _unityAdUnitIdAndroid : _unityAdUnitIdIOS;
  }

  bool get isLoaded => _isAdLoaded;

  bool canShowBasedOnFrequencyCapping(String feature) {
    final lastTimeStr = PreferencesService.instance.getStringNullable(
      '${PreferencesService.keyLastInterstitialTime}_$feature',
    );
    if (lastTimeStr == null) return true;
    final lastTime = DateTime.tryParse(lastTimeStr);
    if (lastTime == null) return true;
    // 10 minutes cap
    return DateTime.now().difference(lastTime).inMinutes >= 10;
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

    final network = AdNetworkController.instance.activeNetwork;

    if (network == AdNetworkType.admob) {
      _loadAdMobAd();
    } else {
      _loadUnityAd();
    }
  }

  void _loadAdMobAd() {
    InterstitialAd.load(
      adUnitId: _adMobUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdMob InterstitialAd loaded.');
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdMob InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _loadUnityAd() {
    UnityAds.load(
      placementId: _unityAdUnitId,
      onComplete: (placementId) {
        debugPrint('Unity InterstitialAd loaded: $placementId');
        _isAdLoaded = true;
      },
      onFailed: (placementId, error, message) {
        debugPrint('Unity InterstitialAd failed to load: $error $message');
        _isAdLoaded = false;
      },
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

    _isShowingAd = true;
    final network = AdNetworkController.instance.activeNetwork;

    if (network == AdNetworkType.admob) {
      _showAdMobAd(feature, safeNavigate);
    } else {
      _showUnityAd(feature, safeNavigate);
    }
  }

  void _showAdMobAd(String feature, VoidCallback safeNavigate) {
    if (_interstitialAd == null) {
      _isShowingAd = false;
      safeNavigate();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
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
        debugPrint('AdMob InterstitialAd failed to show: $error');
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

  void _showUnityAd(String feature, VoidCallback safeNavigate) {
    UnityAds.showVideoAd(
      placementId: _unityAdUnitId,
      onStart: (placementId) {
        debugPrint('Unity InterstitialAd started');
        _recordAdShown(feature);
      },
      onClick: (placementId) => debugPrint('Unity InterstitialAd clicked'),
      onSkipped: (placementId) {
        debugPrint('Unity InterstitialAd skipped');
        _isShowingAd = false;
        _isAdLoaded = false;
        safeNavigate();
        loadAd();
      },
      onComplete: (placementId) {
        debugPrint('Unity InterstitialAd completed');
        _isShowingAd = false;
        _isAdLoaded = false;
        safeNavigate();
        loadAd();
      },
      onFailed: (placementId, error, message) {
        debugPrint('Unity InterstitialAd failed to show: $message');
        _isShowingAd = false;
        _isAdLoaded = false;
        safeNavigate();
        loadAd();
      },
    );
  }
}

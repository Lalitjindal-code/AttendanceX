import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isFirstLoad = true;
  DateTime? _appOpenLoadTime;

  final String _realAdUnitId = 'ca-app-pub-1540123321445233/1526631786';
  
  // Test IDs provided by Google for development
  final String _testAdUnitIdAndroid = 'ca-app-pub-3940256099942544/9257395921';
  final String _testAdUnitIdIOS = 'ca-app-pub-3940256099942544/5575463023';

  String get _adUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testAdUnitIdAndroid : _testAdUnitIdIOS;
    }
    return _realAdUnitId;
  }

  /// Load an AppOpenAd.
  void loadAd() {
    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AppOpenAd loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          if (_isFirstLoad) {
            _isFirstLoad = false;
            showAdIfAvailable();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  bool _isAdExpired() {
    if (_appOpenLoadTime == null) return true;
    // App Open ads expire after 4 hours
    return DateTime.now().difference(_appOpenLoadTime!).inHours >= 4;
  }

  /// Shows the ad, if one exists and is not already being shown.
  void showAdIfAvailable() {
    if (!isAdAvailable) {
      debugPrint('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }
    if (_isAdExpired()) {
      debugPrint('Ad expired.');
      _appOpenAd?.dispose();
      _appOpenAd = null;
      loadAd();
      return;
    }
    
    // Set the full screen content callback.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Load a new one right away
      },
    );
    _appOpenAd!.show();
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_eligibility_service.dart';

class RewardedAdManager {
  static final RewardedAdManager instance = RewardedAdManager._internal();
  RewardedAdManager._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isShowingAd = false;

  final String _realAdUnitId = 'ca-app-pub-1540123321445233/5445631850'; 
  final String _testAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
  final String _testAdUnitIdIOS = 'ca-app-pub-3940256099942544/1712485313';

  String get _adUnitId {
    if (kIsWeb || Platform.isWindows) return '';
    if (kDebugMode) {
      return Platform.isAndroid ? _testAdUnitIdAndroid : _testAdUnitIdIOS;
    }
    return _realAdUnitId;
  }

  bool get isLoaded => _isAdLoaded && _rewardedAd != null;

  void loadAd() {
    if (kIsWeb || Platform.isWindows) return;
    if (_isAdLoaded) return;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('RewardedAd loaded.');
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  void showAdIfAvailable({
    required VoidCallback onRewardEarned,
    required VoidCallback onCompletion,
  }) {
    if (!isLoaded || _isShowingAd) {
      onCompletion();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        onCompletion();
        loadAd(); // Preload next one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAd failed to show: $error');
        _isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        onCompletion();
        loadAd(); // Retry preload
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onRewardEarned();
    });
  }
}

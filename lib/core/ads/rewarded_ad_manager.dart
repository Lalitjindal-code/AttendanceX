import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'ad_eligibility_service.dart';
import 'ad_network_controller.dart';

class RewardedAdManager {
  static final RewardedAdManager instance = RewardedAdManager._internal();
  RewardedAdManager._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isShowingAd = false;

  final String _realAdMobUnitId = 'ca-app-pub-1540123321445233/5445631850'; 
  final String _testAdMobUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
  final String _testAdMobUnitIdIOS = 'ca-app-pub-3940256099942544/1712485313';

  final String _unityAdUnitIdAndroid = 'Rewarded_Android';
  final String _unityAdUnitIdIOS = 'Rewarded_iOS';

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

  void loadAd() {
    if (kIsWeb || Platform.isWindows) return;
    if (_isAdLoaded) return;

    final network = AdNetworkController.instance.activeNetwork;

    if (network == AdNetworkType.admob) {
      _loadAdMobAd();
    } else {
      _loadUnityAd();
    }
  }

  void _loadAdMobAd() {
    RewardedAd.load(
      adUnitId: _adMobUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdMob RewardedAd loaded.');
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdMob RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _loadUnityAd() {
    UnityAds.load(
      placementId: _unityAdUnitId,
      onComplete: (placementId) {
        debugPrint('Unity RewardedAd loaded: $placementId');
        _isAdLoaded = true;
      },
      onFailed: (placementId, error, message) {
        debugPrint('Unity RewardedAd failed to load: $error $message');
        _isAdLoaded = false;
      },
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

    _isShowingAd = true;
    final network = AdNetworkController.instance.activeNetwork;

    if (network == AdNetworkType.admob) {
      _showAdMobAd(onRewardEarned, onCompletion);
    } else {
      _showUnityAd(onRewardEarned, onCompletion);
    }
  }

  void _showAdMobAd(VoidCallback onRewardEarned, VoidCallback onCompletion) {
    if (_rewardedAd == null) {
      _isShowingAd = false;
      onCompletion();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        onCompletion();
        loadAd(); // Preload next one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdMob RewardedAd failed to show: $error');
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

  void _showUnityAd(VoidCallback onRewardEarned, VoidCallback onCompletion) {
    UnityAds.showVideoAd(
      placementId: _unityAdUnitId,
      onStart: (placementId) => debugPrint('Unity ad started'),
      onClick: (placementId) => debugPrint('Unity ad clicked'),
      onSkipped: (placementId) {
        debugPrint('Unity ad skipped');
        _isShowingAd = false;
        _isAdLoaded = false;
        onCompletion();
        loadAd();
      },
      onComplete: (placementId) {
        debugPrint('Unity ad completed');
        _isShowingAd = false;
        _isAdLoaded = false;
        onRewardEarned();
        onCompletion();
        loadAd();
      },
      onFailed: (placementId, error, message) {
        debugPrint('Unity ad failed to show: $message');
        _isShowingAd = false;
        _isAdLoaded = false;
        onCompletion();
        loadAd();
      },
    );
  }
}

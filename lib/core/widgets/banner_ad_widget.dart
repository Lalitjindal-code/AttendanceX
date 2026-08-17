import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../ads/providers/ad_free_provider.dart';
import '../ads/ad_network_controller.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _admobBannerAd;
  bool _isAdmobLoaded = false;
  bool _isUnityLoaded = true; // Unity banner handles its own loading state visually

  final String _realAdMobUnitId = 'ca-app-pub-1540123321445233/9516802444';
  final String _testAdMobUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  final String _testAdMobUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';

  final String _unityAdUnitIdAndroid = 'Banner_Android';
  final String _unityAdUnitIdIOS = 'Banner_iOS';

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

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isWindows) return;
  }

  void _loadAdMobAd() {
    if (_admobBannerAd != null) return;
    _admobBannerAd = BannerAd(
      adUnitId: _adMobUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isAdmobLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _admobBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdFree = ref.watch(adFreeProvider);
    if (isAdFree) {
      if (_admobBannerAd != null) {
        _admobBannerAd?.dispose();
        _admobBannerAd = null;
        _isAdmobLoaded = false;
      }
      return const SizedBox(); // Completely hide ad space
    }

    final network = AdNetworkController.instance.activeNetwork;

    if (network == AdNetworkType.admob) {
      if (!_isAdmobLoaded && _admobBannerAd == null) {
        _loadAdMobAd();
      }

      if (_isAdmobLoaded && _admobBannerAd != null) {
        return Container(
          width: _admobBannerAd!.size.width.toDouble(),
          height: _admobBannerAd!.size.height.toDouble(),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          alignment: Alignment.center,
          child: AdWidget(ad: _admobBannerAd!),
        );
      }
    } else {
      // Unity Network
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        alignment: Alignment.center,
        child: UnityBannerAd(
          placementId: _unityAdUnitId,
          onLoad: (placementId) => debugPrint('Unity Banner loaded: $placementId'),
          onClick: (placementId) => debugPrint('Unity Banner clicked: $placementId'),
          onFailed: (placementId, error, message) => debugPrint('Unity Banner failed: $error $message'),
        ),
      );
    }
    
    return const SizedBox(); // Empty space if ad isn't loaded yet
  }
}

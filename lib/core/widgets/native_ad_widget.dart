import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ads/providers/ad_free_provider.dart';
import '../ads/ad_eligibility_service.dart';

class NativeAdWidget extends ConsumerStatefulWidget {
  const NativeAdWidget({super.key});

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final String _realAdUnitId = 'ca-app-pub-1540123321445233/3965029224'; // Using a generic one
  final String _testAdUnitIdAndroid = 'ca-app-pub-3940256099942544/2247696110';
  final String _testAdUnitIdIOS = 'ca-app-pub-3940256099942544/3986624511';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (kIsWeb || Platform.isWindows) return;
    if (AdEligibilityService.isAdFree) return;

    _nativeAd = NativeAd(
      adUnitId: kDebugMode ? (Platform.isAndroid ? _testAdUnitIdAndroid : _testAdUnitIdIOS) : _realAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('NativeAd loaded.');
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => debugPrint('NativeAd onAdOpened.'),
        onAdClosed: (Ad ad) => debugPrint('NativeAd onAdClosed.'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xFF1E1E2C),
        callToActionTextStyle: NativeTemplateTextStyle(
          size: 16.0,
          textColor: Colors.white,
          backgroundColor: const Color(0xFF42A5F5),
          style: NativeTemplateFontStyle.bold,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.transparent,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white70,
          backgroundColor: Colors.transparent,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white70,
          backgroundColor: Colors.transparent,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdFree = ref.watch(adFreeProvider);
    if (isAdFree || !_nativeAdIsLoaded || _nativeAd == null || kIsWeb || Platform.isWindows) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 320,
        minHeight: 320,
        maxWidth: 400,
        maxHeight: 400,
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

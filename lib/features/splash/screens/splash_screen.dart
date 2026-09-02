import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/ads/app_open_ad_manager.dart';
import '../../../core/ads/app_lifecycle_reactor.dart';
import '../../../core/ads/consent_manager.dart';
import '../../../core/ads/ad_network_controller.dart';
import '../../../navigation/app_routes.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Mobile Ads are only supported on Android/iOS (not web)
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _navigateToDashboard();
      return;
    }

    // 2. Gather consent (UMP)
    ConsentManager().gatherConsent(() async {
      // 3. Initialize Ads and Remote Config
      await AdNetworkController.instance.initialize();
      await MobileAds.instance.initialize();
      
      UnityAds.init(
        gameId: '800356638', 
        testMode: kDebugMode,
        onComplete: () => debugPrint('Unity initialized'),
        onFailed: (error, message) => debugPrint('Unity failed: $error $message'),
      );

      // If the active network is Unity, we don't need to show an AdMob App Open Ad.
      // Navigate to dashboard immediately to speed up startup.
      if (AdNetworkController.instance.activeNetwork == AdNetworkType.unity) {
        if (mounted) _navigateToDashboard();
        return;
      }

      // 4. Start loading App Open Ad and set up lifecycle reactor for warm starts
      AppLifecycleReactor.instance.listenToAppStateChanges();

      // 5. Try to load and show the ad on cold start with a timeout
      bool adShown = await _tryShowAppOpenAdWithTimeout();

      // 6. If ad was not shown (failed or timed out), navigate immediately.
      // If it WAS shown, the ad's onAdDismissedFullScreenContent callback
      // will handle the navigation to the dashboard.
      if (!adShown && mounted) {
        _navigateToDashboard();
      }
    });
  }

  Future<bool> _tryShowAppOpenAdWithTimeout() async {
    final completer = Completer<bool>();

    // Set a max timeout for loading the ad
    Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        debugPrint('AppOpenAd load timed out during splash screen.');
        completer.complete(false);
      }
    });

    AppOpenAdManager.instance.loadAdWithCallback(
      onAdLoaded: () {
        if (!completer.isCompleted) {
          // If we loaded in time, show the ad!
          debugPrint('AppOpenAd loaded in time. Showing ad.');
          AppOpenAdManager.instance.showAdIfAvailable(
            onAdDismissed: () {
              if (mounted) {
                _navigateToDashboard();
              }
            },
          );
          completer.complete(true);
        }
      },
      onAdFailedToLoad: () {
        if (!completer.isCompleted) {
          debugPrint('AppOpenAd failed to load during splash screen.');
          completer.complete(false);
        }
      },
    );

    return completer.future;
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    // A simple splash UI that matches the native splash screen (flutter_native_splash).
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
      body: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          // Assuming the native splash shows the logo at its natural size or a reasonable centered size
        ),
      ),
    );
  }
}

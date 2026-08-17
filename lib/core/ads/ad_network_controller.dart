import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

enum AdNetworkType {
  admob,
  unity
}

class AdNetworkController {
  static final AdNetworkController instance = AdNetworkController._internal();
  AdNetworkController._internal();

  final _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? const Duration(minutes: 5) : const Duration(hours: 1),
      ));

      await _remoteConfig.setDefaults(const {
        "active_ad_network": "unity", // Default to unity while AdMob is pending
      });

      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config Active Ad Network: ${activeNetwork.name}');
    } catch (e) {
      debugPrint('Failed to initialize Remote Config for Ads: $e');
    }
  }

  AdNetworkType get activeNetwork {
    final networkString = _remoteConfig.getString('active_ad_network').toLowerCase();
    if (networkString == 'admob') {
      return AdNetworkType.admob;
    }
    return AdNetworkType.unity; // Fallback
  }
}

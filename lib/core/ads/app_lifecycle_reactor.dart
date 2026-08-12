import 'package:flutter/material.dart';
import 'app_open_ad_manager.dart';

/// Listens for app foreground events and shows the App Open Ad.
class AppLifecycleReactor extends WidgetsBindingObserver {
  static final AppLifecycleReactor instance = AppLifecycleReactor._internal();
  AppLifecycleReactor._internal();

  bool _isListening = false;
  AppLifecycleState? _previousState;

  void listenToAppStateChanges() {
    if (_isListening) return;
    WidgetsBinding.instance.addObserver(this);
    _isListening = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Show the ad only when the app comes back from being paused.
    // This prevents showing ads repeatedly when just pulling down the notification shade (inactive).
    if (state == AppLifecycleState.resumed &&
        _previousState == AppLifecycleState.paused) {
      AppOpenAdManager.instance.showAdIfAvailable();
    }
    _previousState = state;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendify/features/settings/providers/settings_provider.dart';
import 'package:attendify/features/security/screens/app_lock_screen.dart';

class AppLockWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  ConsumerState<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends ConsumerState<AppLockWrapper>
    with WidgetsBindingObserver {
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial check: if lock is enabled, we lock the app at startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isLockEnabled = ref.read(settingsProvider).isAppLockEnabled;
      if (isLockEnabled) {
        setState(() {
          _isLocked = true;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final isLockEnabled = ref.read(settingsProvider).isAppLockEnabled;
    if (!isLockEnabled) return;

    if (state == AppLifecycleState.paused) {
      // App went to background
      setState(() {
        _isLocked = true;
      });
    }
  }

  void _handleUnlock() {
    setState(() {
      _isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLocked)
          Positioned.fill(
            child: AppLockScreen(
              onUnlocked: _handleUnlock,
            ),
          ),
      ],
    );
  }
}

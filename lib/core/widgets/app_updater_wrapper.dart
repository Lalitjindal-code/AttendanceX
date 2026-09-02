import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/app_router.dart';
import '../../services/update_service.dart';
import '../providers/firebase_provider.dart';
import 'update_dialog.dart';

class AppUpdaterWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppUpdaterWrapper({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<AppUpdaterWrapper> createState() => _AppUpdaterWrapperState();
}

class _AppUpdaterWrapperState extends ConsumerState<AppUpdaterWrapper> {
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    // Start checking after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    if (_hasChecked) return;

    // Wait for Firebase to initialize
    final firebaseApp = await ref.read(firebaseInitProvider.future);
    if (firebaseApp == null) return; // Firebase failed to init

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      final updateService = UpdateService(remoteConfig);
      await updateService.initialize();

      final updateInfo = await updateService.checkForUpdate();
      debugPrint('UPDATE CHECK: isUpdateAvailable=${updateInfo.isUpdateAvailable}, remoteVersion=${updateInfo.latestVersion}, apkUrl=${updateInfo.apkUrl}');

      // Delay slightly to let initial route transitions (splash/dashboard) complete
      await Future.delayed(const Duration(seconds: 2));

      final dialogContext = rootNavigatorKey.currentContext ?? (mounted ? context : null);

      if (updateInfo.isUpdateAvailable && dialogContext != null) {
        showDialog(
          context: dialogContext,
          barrierDismissible: !updateInfo.isMandatory,
          builder: (context) => UpdateDialog(
            updateInfo: updateInfo,
            updateService: updateService,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    } finally {
      if (mounted) {
        setState(() {
          _hasChecked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

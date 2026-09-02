import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateInfo {
  final bool isUpdateAvailable;
  final String latestVersion;
  final String apkUrl;
  final String releaseNotes;
  final bool isMandatory;

  UpdateInfo({
    required this.isUpdateAvailable,
    required this.latestVersion,
    required this.apkUrl,
    required this.releaseNotes,
    this.isMandatory = false,
  });
}

class UpdateService {
  final FirebaseRemoteConfig _remoteConfig;
  
  UpdateService(this._remoteConfig);

  /// Initializes Remote Config and fetches latest values
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: Duration.zero, // Instant fetch on launch
    ));
    await _remoteConfig.setDefaults(const {
      'latest_app_version': '1.0.0',
      'latest_apk_url': '',
      'update_release_notes': '',
      'is_update_mandatory': false,
    });
    
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Failed to fetch remote config for updates: $e');
    }
  }

  /// Checks if an update is available by comparing local and remote versions
  Future<UpdateInfo> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    
    final remoteVersion = _remoteConfig.getString('latest_app_version');
    final apkUrl = _remoteConfig.getString('latest_apk_url');
    final releaseNotes = _remoteConfig.getString('update_release_notes');
    final isMandatory = _remoteConfig.getBool('is_update_mandatory');

    final isAvailable = _isVersionGreaterThan(remoteVersion, currentVersion);
    debugPrint('UPDATE ENGINE: local=$currentVersion, remote=$remoteVersion, isAvailable=$isAvailable, apkUrl=$apkUrl');

    return UpdateInfo(
      isUpdateAvailable: isAvailable && apkUrl.isNotEmpty,
      latestVersion: remoteVersion,
      apkUrl: apkUrl,
      releaseNotes: releaseNotes,
      isMandatory: isMandatory,
    );
  }

  /// Helper to compare version strings like "1.0.1" and "1.0.0"
  bool _isVersionGreaterThan(String remote, String local) {
    if (remote.isEmpty || local.isEmpty) return false;
    
    try {
      // Remove any build numbers if present e.g., 1.0.0+1 -> 1.0.0
      final cleanRemote = remote.split('+')[0];
      final cleanLocal = local.split('+')[0];

      final remoteParts = cleanRemote.split('.').map(int.parse).toList();
      final localParts = cleanLocal.split('.').map(int.parse).toList();
      
      for (int i = 0; i < remoteParts.length; i++) {
        if (i >= localParts.length) return true;
        if (remoteParts[i] > localParts[i]) return true;
        if (remoteParts[i] < localParts[i]) return false;
      }
    } catch (e) {
      debugPrint('Error parsing versions: $e');
    }
    return false;
  }

  /// Downloads the APK and returns progress via callback
  Future<void> downloadAndInstallUpdate({
    required String url,
    required String fileName,
    required Function(double progress) onProgress,
    required VoidCallback onComplete,
    required Function(String error) onError,
  }) async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.requestInstallPackages.status;
        if (!status.isGranted) {
          await Permission.requestInstallPackages.request();
        }
      }

      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      
      if (dir == null) {
        onError('Could not access storage directory');
        return;
      }

      final savePath = '${dir.path}/$fileName';
      final dio = Dio();

      onProgress(0.0);

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      
      onComplete();
      
      // Attempt to install
      if (Platform.isAndroid) {
         final result = await OpenFilex.open(savePath);
         debugPrint('Install result: ${result.message}');
      }
    } catch (e) {
      debugPrint('Download error: $e');
      onError(e.toString());
    }
  }
}

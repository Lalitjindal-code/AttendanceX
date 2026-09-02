import 'package:attendify/services/update_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  late UpdateService updateService;
  late MockFirebaseRemoteConfig mockRemoteConfig;

  setUp(() {
    mockRemoteConfig = MockFirebaseRemoteConfig();
    updateService = UpdateService(mockRemoteConfig);
    
    // Set initial dummy values for package info to avoid platform channel errors
    PackageInfo.setMockInitialValues(
      appName: 'Attendify',
      packageName: 'com.example.attendify',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'buildSignature',
    );
  });

  group('UpdateService', () {
    test('checkForUpdate returns true when remote version is higher', () async {
      when(() => mockRemoteConfig.getString('latest_app_version')).thenReturn('1.1.0');
      when(() => mockRemoteConfig.getString('latest_apk_url')).thenReturn('http://example.com/apk');
      when(() => mockRemoteConfig.getString('update_release_notes')).thenReturn('Bug fixes');
      when(() => mockRemoteConfig.getBool('is_update_mandatory')).thenReturn(false);

      final updateInfo = await updateService.checkForUpdate();

      expect(updateInfo.isUpdateAvailable, isTrue);
      expect(updateInfo.latestVersion, '1.1.0');
      expect(updateInfo.apkUrl, 'http://example.com/apk');
      expect(updateInfo.releaseNotes, 'Bug fixes');
      expect(updateInfo.isMandatory, isFalse);
    });

    test('checkForUpdate returns false when remote version is equal', () async {
      when(() => mockRemoteConfig.getString('latest_app_version')).thenReturn('1.0.0');
      when(() => mockRemoteConfig.getString('latest_apk_url')).thenReturn('http://example.com/apk');
      when(() => mockRemoteConfig.getString('update_release_notes')).thenReturn('Bug fixes');
      when(() => mockRemoteConfig.getBool('is_update_mandatory')).thenReturn(false);

      final updateInfo = await updateService.checkForUpdate();

      expect(updateInfo.isUpdateAvailable, isFalse);
    });

    test('checkForUpdate returns false when remote version is lower', () async {
      when(() => mockRemoteConfig.getString('latest_app_version')).thenReturn('0.9.0');
      when(() => mockRemoteConfig.getString('latest_apk_url')).thenReturn('http://example.com/apk');
      when(() => mockRemoteConfig.getString('update_release_notes')).thenReturn('Bug fixes');
      when(() => mockRemoteConfig.getBool('is_update_mandatory')).thenReturn(false);

      final updateInfo = await updateService.checkForUpdate();

      expect(updateInfo.isUpdateAvailable, isFalse);
    });
  });
}

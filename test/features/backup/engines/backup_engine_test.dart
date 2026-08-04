import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendancex/features/backup/engines/backup_engine.dart';
import 'package:attendancex/features/backup/repositories/local_storage_repository.dart';
import 'package:attendancex/features/settings/models/app_settings.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  group('BackupEngine Tests', () {
    late BackupEngine engine;
    late String testPath;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      engine = BackupEngine(LocalStorageRepository());
      
      // We will use a local file in the test directory
      final dir = Directory.systemTemp.createTempSync('attendify_test');
      testPath = '${dir.path}/test_backup.atfy';
    });

    tearDown(() {
      final file = File(testPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('Export and Parse Backup should work perfectly', () async {
      final dummySubject = Subject()
        ..name = 'Test Subject'
        ..facultyName = 'Dr. Smith'
        ..credits = 4;

      // 1. Export Backup
      await engine.exportBackup(
        path: testPath,
        subjects: [dummySubject],
        schedules: [],
        attendanceRecords: [],
        attendanceHistory: [],
        tasks: [],
        settings: const AppSettings(),
        appVersion: '1.0.0',
        databaseVersion: 1,
      );

      final file = File(testPath);
      expect(file.existsSync(), isTrue);

      // 2. Get Preview
      final preview = await engine.getRestorePreview(testPath);
      expect(preview.appVersion, equals('1.0.0'));
      expect(preview.version, equals(1));
      expect(preview.checksum, isNotEmpty);

      // 3. Parse and Validate
      final parsedModel = await engine.parseAndValidateBackup(testPath);
      expect(parsedModel.subjects.length, equals(1));
      expect(parsedModel.subjects.first.name, equals('Test Subject'));
      expect(parsedModel.settings.themeMode.name, equals('system'));
    });

    test('Corrupted backup should throw checksum error', () async {
      // 1. Export valid backup
      await engine.exportBackup(
        path: testPath,
        subjects: [],
        schedules: [],
        attendanceRecords: [],
        attendanceHistory: [],
        tasks: [],
        settings: const AppSettings(),
        appVersion: '1.0.0',
        databaseVersion: 1,
      );

      // 2. Corrupt the file (flip some bytes)
      final file = File(testPath);
      final bytes = await file.readAsBytes();
      bytes[10] = bytes[10] ^ 0xFF; // Flip a byte in the gzip payload
      await file.writeAsBytes(bytes);

      // 3. Attempt to parse
      expect(
        () async => await engine.parseAndValidateBackup(testPath),
        throwsException, // Either gzip decode throws or checksum throws
      );
    });
  });
}

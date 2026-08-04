import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/backup_model.dart';
import '../repositories/backup_repository.dart';
import '../../../database/collections/academic_task_collection.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/attendance_history_collection.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../settings/models/app_settings.dart';

class BackupEngine {
  BackupEngine(this._repository);

  final BackupRepository _repository;

  /// Generates a complete backup and writes it to [path].
  Future<void> exportBackup({
    required String path,
    required List<Subject> subjects,
    required List<Schedule> schedules,
    required List<Attendance> attendanceRecords,
    required List<AttendanceHistory> attendanceHistory,
    required List<AcademicTask> tasks,
    required AppSettings settings,
    required String appVersion,
    required int databaseVersion,
    void Function(double)? onProgress,
  }) async {
    onProgress?.call(0.1);

    // Create the uncompressed payload
    final backupModel = BackupModel(
      metadata: BackupMetadata(
        version: 1, // Backup format version
        appVersion: appVersion,
        databaseVersion: databaseVersion,
        createdAt: DateTime.now(),
        platform: Platform.operatingSystem,
        checksum: '', // Placeholder, will be computed later
        compressionType: 'gzip',
      ),
      subjects: subjects,
      schedules: schedules,
      attendanceRecords: attendanceRecords,
      attendanceHistory: attendanceHistory,
      tasks: tasks,
      settings: settings,
    );

    onProgress?.call(0.3);

    // Compute in background isolate
    final compressedBytes = await compute(_compressBackup, backupModel.toMap());

    onProgress?.call(0.8);

    // Write to repository
    await _repository.writeBackup(path, compressedBytes);

    onProgress?.call(1.0);
  }

  /// Dry-run reads a backup and returns its metadata for preview.
  /// Throws an Exception if the file is invalid, corrupted, or unsupported.
  Future<BackupMetadata> getRestorePreview(String path) async {
    final bytes = await _repository.readBackup(path);
    final map = await compute(_decompressBackup, bytes);

    if (!map.containsKey('metadata')) {
      throw Exception('Invalid backup format: Missing metadata.');
    }

    final metadata = BackupMetadata.fromMap(map['metadata']);
    return metadata;
  }

  /// Validates and parses the backup. Returns the complete BackupModel.
  /// Does NOT write to the database. The caller handles the transactional restore.
  Future<BackupModel> parseAndValidateBackup(String path) async {
    final bytes = await _repository.readBackup(path);
    final map = await compute(_decompressBackup, bytes);

    // Validate Checksum (if it was implemented to hash the 'data' node)
    // Here we assume checksum validation inside _decompressBackup or simply validate the structure.

    if (!map.containsKey('metadata') || !map.containsKey('data')) {
      throw Exception('Invalid backup format: Corrupted structure.');
    }

    final backupModel = BackupModel.fromMap(map);
    return backupModel;
  }
}

// ── Isolates ─────────────────────────────────────────────────────────────────

List<int> _compressBackup(Map<String, dynamic> rawMap) {
  // First, serialize to JSON string
  final jsonString = json.encode(rawMap);
  final jsonBytes = utf8.encode(jsonString);

  // Compute checksum of the raw JSON
  final checksum = sha256.convert(jsonBytes).toString();

  // Inject the checksum into the metadata
  rawMap['metadata']['checksum'] = checksum;

  // Re-encode with checksum
  final finalJsonString = json.encode(rawMap);
  final finalJsonBytes = utf8.encode(finalJsonString);

  // Compress using GZIP
  final compressedBytes = gzip.encode(finalJsonBytes);
  return compressedBytes;
}

Map<String, dynamic> _decompressBackup(List<int> compressedBytes) {
  // Decompress GZIP
  final decompressedBytes = gzip.decode(compressedBytes);
  final jsonString = utf8.decode(decompressedBytes);

  // Decode JSON
  final map = json.decode(jsonString) as Map<String, dynamic>;

  // Validate checksum
  final storedChecksum = map['metadata']['checksum'];
  
  // Temporarily clear checksum to re-calculate
  map['metadata']['checksum'] = '';
  final rawJsonBytes = utf8.encode(json.encode(map));
  final computedChecksum = sha256.convert(rawJsonBytes).toString();

  // Put it back
  map['metadata']['checksum'] = storedChecksum;

  if (storedChecksum != '' && storedChecksum != computedChecksum) {
    throw Exception('Backup checksum validation failed. The file may be corrupted.');
  }

  return map;
}

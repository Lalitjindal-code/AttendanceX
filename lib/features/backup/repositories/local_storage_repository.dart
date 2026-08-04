import 'dart:io';
import 'backup_repository.dart';

/// Implementation of [BackupRepository] that reads and writes files
/// directly to the local device storage.
class LocalStorageRepository implements BackupRepository {
  @override
  Future<List<int>> readBackup(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Backup file does not exist at path: $path');
    }
    return await file.readAsBytes();
  }

  @override
  Future<void> writeBackup(String path, List<int> data) async {
    final file = File(path);

    // Ensure the parent directory exists
    final parentDir = file.parent;
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }

    await file.writeAsBytes(data, flush: true);
  }

  @override
  Future<bool> backupExists(String path) async {
    final file = File(path);
    return await file.exists();
  }
}

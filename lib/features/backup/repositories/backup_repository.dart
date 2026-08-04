
/// Abstract repository defining the interface for storing and retrieving backups.
/// 
/// This is designed to be platform and storage agnostic. Future implementations
/// can support Google Drive, iCloud, Dropbox, etc.
abstract class BackupRepository {
  /// Reads a backup from the specified [path] or identifier and returns the raw bytes.
  Future<List<int>> readBackup(String path);

  /// Writes the raw [data] bytes to the specified [path] or identifier.
  Future<void> writeBackup(String path, List<int> data);

  /// Checks if a backup exists at the specified [path] or identifier.
  Future<bool> backupExists(String path);
}

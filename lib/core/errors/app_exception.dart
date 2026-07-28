/// Base class for all application-level exceptions.
///
/// All custom exceptions extend [AppException]. Catch at repository
/// boundaries and convert to [Failure] for propagation through providers.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Human-readable description suitable for logging.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when an Isar read, write, or delete operation fails.
final class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

/// Thrown when user input does not pass validation rules.
final class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Thrown when a required record is not found in the database.
final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Thrown when attempting to create a record that already exists.
final class DuplicateException extends AppException {
  const DuplicateException(super.message);
}

/// Thrown when a backup export or restore import fails.
final class BackupException extends AppException {
  const BackupException(super.message);
}

/// Thrown when a time conflict is detected between schedule entries.
final class TimeConflictException extends AppException {
  const TimeConflictException(super.message);
}

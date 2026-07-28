import 'package:flutter/foundation.dart';

/// Typed failure result returned from repository and service operations.
///
/// Providers use [Failure] as the error type in [AsyncValue.error] states.
/// Never throw raw exceptions across the provider boundary — always convert
/// [AppException] to a [Failure] subtype.
@immutable
sealed class Failure {
  const Failure(this.message);

  /// User-safe error message (may be shown in UI).
  final String message;
}

/// Failure from an Isar database operation.
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Failure from input validation.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure when a required record is not found.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Failure when a duplicate resource is detected.
final class DuplicateFailure extends Failure {
  const DuplicateFailure(super.message);
}

/// Failure from backup or restore operations.
final class BackupFailure extends Failure {
  const BackupFailure(super.message);
}

/// Failure from a schedule time conflict.
final class TimeConflictFailure extends Failure {
  const TimeConflictFailure(super.message);
}

/// Catch-all failure for unexpected errors.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

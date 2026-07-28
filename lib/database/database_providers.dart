import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'isar_service.dart';

part 'database_providers.g.dart';

/// Provides the singleton [Isar] database instance to the rest of the app.
///
/// Throws a [StateError] if [IsarService.initialize] was not called
/// and completed before accessing this provider.
@Riverpod(keepAlive: true)
Isar isar(IsarRef ref) {
  return IsarService.instance.isar;
}

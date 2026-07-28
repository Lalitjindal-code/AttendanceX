import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../core/config/app_config.dart';
import 'collections/attendance_collection.dart';
import 'collections/attendance_history_collection.dart';
import 'collections/schedule_collection.dart';
import 'collections/subject_collection.dart';

/// Singleton service that manages the Isar database instance lifecycle.
///
/// Call [initialize] once in [main] before [runApp].
/// Access the database via [isar] from anywhere after initialization.
///
/// The singleton pattern prevents multiple database instances from being
/// opened simultaneously, which Isar does not support.
class IsarService {
  IsarService._();

  static final IsarService _instance = IsarService._();

  /// The global singleton instance.
  static IsarService get instance => _instance;

  Isar? _isar;

  /// The open [Isar] database instance.
  ///
  /// Throws [StateError] if accessed before [initialize] completes.
  Isar get isar {
    assert(
      _isar != null && _isar!.isOpen,
      'IsarService.initialize() must complete before accessing .isar.',
    );
    return _isar!;
  }

  /// Whether the database has been initialized and is currently open.
  bool get isOpen => _isar != null && _isar!.isOpen;

  /// Opens the Isar database with all four registered collections.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops if already open.
  /// Stores the database in [getApplicationDocumentsDirectory].
  Future<void> initialize() async {
    if (isOpen) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        SubjectSchema,
        ScheduleSchema,
        AttendanceSchema,
        AttendanceHistorySchema,
      ],
      directory: dir.path,
      name: AppConfig.isarDbName,
    );
  }

  /// Closes the database connection.
  ///
  /// Should only be called during app disposal or test teardown.
  /// After calling this, [initialize] must be called again before use.
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}

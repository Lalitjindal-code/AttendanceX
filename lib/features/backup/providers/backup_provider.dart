import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../../database/database_providers.dart';
import '../../../database/collections/academic_task_collection.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/attendance_history_collection.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../database/collections/profile_collection.dart';
import '../../../database/collections/semester_collection.dart';
import '../../settings/providers/settings_provider.dart';
import '../engines/backup_engine.dart';
import '../models/backup_model.dart';
import '../repositories/local_storage_repository.dart';
import '../services/backup_restore_service.dart';

part 'backup_provider.g.dart';

@Riverpod(keepAlive: true)
class BackupController extends _$BackupController {
  late BackupRestoreService _restoreService;
  late BackupEngine _engine;

  @override
  double? build() {
    _engine = BackupEngine(LocalStorageRepository());
    final isar = ref.watch(isarProvider);
    final settings = ref.watch(settingsProvider.notifier);
    _restoreService = BackupRestoreService(isar, _engine, settings);
    return null; // null means idle, double means progress 0.0 - 1.0
  }

  Future<void> createBackup(String customPath) async {
    state = 0.0;
    try {
      final isar = ref.read(isarProvider);
      final profiles = await isar.profiles.where().findAll();
      final semesters = await isar.semesters.where().findAll();
      final subjects = await isar.subjects.where().findAll();
      final schedules = await isar.schedules.where().findAll();
      final attendances = await isar.attendances.where().findAll();
      final history = await isar.attendanceHistorys.where().findAll();
      final tasks = await isar.academicTasks.where().findAll();
      final currentSettings = ref.read(settingsProvider);

      await _engine.exportBackup(
        path: customPath,
        profiles: profiles,
        semesters: semesters,
        subjects: subjects,
        schedules: schedules,
        attendanceRecords: attendances,
        attendanceHistory: history,
        tasks: tasks,
        settings: currentSettings,
        appVersion: '1.0.0', // Standardize app version
        databaseVersion: 1,
        onProgress: (progress) {
          state = progress;
        },
      );
    } finally {
      state = null;
    }
  }

  Future<Uint8List> generateBackupBytes() async {
    state = 0.0;
    try {
      final isar = ref.read(isarProvider);
      final profiles = await isar.profiles.where().findAll();
      final semesters = await isar.semesters.where().findAll();
      final subjects = await isar.subjects.where().findAll();
      final schedules = await isar.schedules.where().findAll();
      final attendances = await isar.attendances.where().findAll();
      final history = await isar.attendanceHistorys.where().findAll();
      final tasks = await isar.academicTasks.where().findAll();
      final currentSettings = ref.read(settingsProvider);

      return await _engine.getBackupBytes(
        profiles: profiles,
        semesters: semesters,
        subjects: subjects,
        schedules: schedules,
        attendanceRecords: attendances,
        attendanceHistory: history,
        tasks: tasks,
        settings: currentSettings,
        appVersion: '1.0.0', // Standardize app version
        databaseVersion: 1,
        onProgress: (progress) {
          state = progress;
        },
      );
    } finally {
      state = null;
    }
  }

  Future<void> createJsonBackup(String customPath) async {
    state = 0.0;
    try {
      final isar = ref.read(isarProvider);
      final profiles = await isar.profiles.where().findAll();
      final semesters = await isar.semesters.where().findAll();
      final subjects = await isar.subjects.where().findAll();
      final schedules = await isar.schedules.where().findAll();
      final attendances = await isar.attendances.where().findAll();
      final history = await isar.attendanceHistorys.where().findAll();
      final tasks = await isar.academicTasks.where().findAll();
      final currentSettings = ref.read(settingsProvider);

      await _engine.exportJsonBackup(
        path: customPath,
        profiles: profiles,
        semesters: semesters,
        subjects: subjects,
        schedules: schedules,
        attendanceRecords: attendances,
        attendanceHistory: history,
        tasks: tasks,
        settings: currentSettings,
        appVersion: '1.0.0', // Standardize app version
        databaseVersion: 1,
        onProgress: (progress) {
          state = progress;
        },
      );
    } finally {
      state = null;
    }
  }

  Future<Uint8List> generateJsonBackupBytes() async {
    state = 0.0;
    try {
      final isar = ref.read(isarProvider);
      final profiles = await isar.profiles.where().findAll();
      final semesters = await isar.semesters.where().findAll();
      final subjects = await isar.subjects.where().findAll();
      final schedules = await isar.schedules.where().findAll();
      final attendances = await isar.attendances.where().findAll();
      final history = await isar.attendanceHistorys.where().findAll();
      final tasks = await isar.academicTasks.where().findAll();
      final currentSettings = ref.read(settingsProvider);

      return await _engine.getJsonBackupBytes(
        profiles: profiles,
        semesters: semesters,
        subjects: subjects,
        schedules: schedules,
        attendanceRecords: attendances,
        attendanceHistory: history,
        tasks: tasks,
        settings: currentSettings,
        appVersion: '1.0.0', // Standardize app version
        databaseVersion: 1,
        onProgress: (progress) {
          state = progress;
        },
      );
    } finally {
      state = null;
    }
  }

  Future<BackupMetadata> getPreview(String path) async {
    return await _engine.getRestorePreview(path);
  }

  Future<void> restoreBackup(String path) async {
    state = 0.0;
    try {
      await _restoreService.restoreBackup(
        path,
        onProgress: (progress) {
          state = progress;
        },
      );
    } finally {
      state = null;
    }
  }
}

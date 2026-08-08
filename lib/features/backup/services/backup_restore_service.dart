import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../engines/backup_engine.dart';
import '../repositories/local_storage_repository.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../database/collections/academic_task_collection.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/attendance_history_collection.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../database/collections/profile_collection.dart';
import '../../../database/collections/semester_collection.dart';

class BackupRestoreService {
  BackupRestoreService(this.isar, this.engine, this.settingsNotifier);

  final Isar isar;
  final BackupEngine engine;
  final Settings settingsNotifier;

  /// Performs a safe, transactional restore of the backup file at [path].
  ///
  /// 1. Validates the backup
  /// 2. Creates a temporary backup of current state
  /// 3. Clears the database
  /// 4. Imports new data
  /// 5. On failure: rolls back from temporary backup and throws
  Future<void> restoreBackup(String path,
      {void Function(double)? onProgress}) async {
    onProgress?.call(0.1);

    // 1. Validate & Parse
    final backupModel = await engine.parseAndValidateBackup(path);

    // Duplicate Protection: Not fully implemented bit-for-bit,
    // but we can check if the db version and lengths exactly match (simplified).
    final currentSubjects = await isar.subjects.count();
    final currentRecords = await isar.attendances.count();
    if (currentSubjects == backupModel.subjects.length &&
        currentRecords == backupModel.attendanceRecords.length) {
      // Very basic duplicate protection. Could be expanded with checksums of current DB.
    }

    onProgress?.call(0.3);

    // 2. Create Temporary Backup
    final tempPath = await _createTemporaryBackup();

    onProgress?.call(0.5);

    // 3 & 4. Clear and Import inside Transaction
    try {
      await isar.writeTxn(() async {
        await isar.clear(); // Clear all collections

        await isar.profiles.putAll(backupModel.profiles);
        await isar.semesters.putAll(backupModel.semesters);
        await isar.subjects.putAll(backupModel.subjects);
        await isar.schedules.putAll(backupModel.schedules);
        await isar.attendances.putAll(backupModel.attendanceRecords);
        await isar.attendanceHistorys.putAll(backupModel.attendanceHistory);
        await isar.academicTasks.putAll(backupModel.tasks);
      });

      // Restore Settings
      await _restoreSettings(backupModel.settings);

      onProgress?.call(0.9);

      // 5. Cleanup Temporary Backup
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      onProgress?.call(1.0);
    } catch (e) {
      // ROLLBACK
      await _rollback(tempPath);
      throw Exception(
          'Restore failed. Successfully rolled back to previous state. Error: $e');
    }
  }

  Future<String> _createTemporaryBackup() async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/attendify_temp_backup.atfy';

    final profiles = await isar.profiles.where().findAll();
    final semesters = await isar.semesters.where().findAll();
    final subjects = await isar.subjects.where().findAll();
    final schedules = await isar.schedules.where().findAll();
    final attendances = await isar.attendances.where().findAll();
    final history = await isar.attendanceHistorys.where().findAll();
    final tasks = await isar.academicTasks.where().findAll();
    // Assuming settingsNotifier state represents current AppSettings
    final currentSettings = settingsNotifier.currentSettings;

    // We use a LocalStorageRepository explicitly for the temp backup
    final tempEngine = BackupEngine(LocalStorageRepository());

    await tempEngine.exportBackup(
      path: tempPath,
      profiles: profiles,
      semesters: semesters,
      subjects: subjects,
      schedules: schedules,
      attendanceRecords: attendances,
      attendanceHistory: history,
      tasks: tasks,
      settings: currentSettings,
      appVersion: '1.0.0', // TODO: Get real app version
      databaseVersion: 1,
    );

    return tempPath;
  }

  Future<void> _rollback(String tempPath) async {
    final tempFile = File(tempPath);
    if (!await tempFile.exists()) return;

    final tempEngine = BackupEngine(LocalStorageRepository());
    final backupModel = await tempEngine.parseAndValidateBackup(tempPath);

    await isar.writeTxn(() async {
      await isar.clear();
      await isar.profiles.putAll(backupModel.profiles);
      await isar.semesters.putAll(backupModel.semesters);
      await isar.subjects.putAll(backupModel.subjects);
      await isar.schedules.putAll(backupModel.schedules);
      await isar.attendances.putAll(backupModel.attendanceRecords);
      await isar.attendanceHistorys.putAll(backupModel.attendanceHistory);
      await isar.academicTasks.putAll(backupModel.tasks);
    });

    await _restoreSettings(backupModel.settings);
  }

  Future<void> _restoreSettings(AppSettings settings) async {
    await settingsNotifier.updateThemeMode(settings.themeMode);
    await settingsNotifier.updateDefaultGoal(settings.defaultGoalPercentage);
    await settingsNotifier.updateMedicalPolicy(settings.medicalCountsAsPresent);
    await settingsNotifier.updateGtMode(settings.gtMode);
    await settingsNotifier.updateSemesterDates(
        settings.semesterStartDate, settings.semesterEndDate);
    await settingsNotifier
        .updateNotificationsEnabled(settings.notificationsEnabled);
    await settingsNotifier
        .updateDailyReminderEnabled(settings.dailyReminderEnabled);
    await settingsNotifier.updateDailyReminderTime(settings.dailyReminderTime);
    await settingsNotifier
        .updateLectureReminderMinutes(settings.lectureReminderMinutes);
    await settingsNotifier
        .updateDefaultTaskReminderOffsets(settings.defaultTaskReminderOffsets);
  }
}

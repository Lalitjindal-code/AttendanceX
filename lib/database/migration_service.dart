import 'package:isar/isar.dart';
import '../services/preferences_service.dart';
import 'collections/profile_collection.dart';
import 'collections/semester_collection.dart';
import 'collections/subject_collection.dart';
import 'collections/schedule_collection.dart';
import 'collections/attendance_collection.dart';
import 'collections/attendance_history_collection.dart';
import 'collections/academic_task_collection.dart';

class MigrationService {
  final Isar isar;

  MigrationService(this.isar);

  Future<void> runMigrations() async {
    final prefs = PreferencesService.instance;
    final isMigrated =
        prefs.getBool('v2_migration_complete', defaultValue: false);

    if (isMigrated) return;

    // Capture ID outside writeTxn so it's in scope for the post-txn prefs update
    int profileId = -1;

    await isar.writeTxn(() async {
      // 1. Check if any profile exists. If not, create Default Profile.
      var defaultProfile = await isar.profiles.where().findFirst();
      if (defaultProfile == null) {
        defaultProfile = Profile()
          ..name = 'Default Profile'
          ..isDefault = true
          ..defaultGoalPercentage = prefs
              .getDouble(PreferencesService.keyDefaultGoal, defaultValue: 75.0)
          ..medicalCountsAsPresent = prefs.getBool(
              PreferencesService.keyMedicalCountsAsPresent,
              defaultValue: false);
        await isar.profiles.put(defaultProfile);
      }
      profileId = defaultProfile.id;

      // 2. Create Default Semester if none exist
      var defaultSemester = await isar.semesters.where().findFirst();
      if (defaultSemester == null) {
        final oldStartStr =
            prefs.getStringNullable(PreferencesService.keySemesterStart);
        final oldEndStr =
            prefs.getStringNullable(PreferencesService.keySemesterEnd);

        final startDate =
            oldStartStr != null ? DateTime.parse(oldStartStr) : DateTime.now();
        final endDate = oldEndStr != null ? DateTime.parse(oldEndStr) : null;

        defaultSemester = Semester()
          ..profileId = defaultProfile.id
          ..name = 'Current Semester'
          ..startDate = DateTime(startDate.year, startDate.month, startDate.day)
          ..endDate = endDate != null
              ? DateTime(endDate.year, endDate.month, endDate.day)
              : null;

        await isar.semesters.put(defaultSemester);
      }

      final semesterId = defaultSemester.id;

      // 3. Update all existing records that have semesterId == 0
      final subjects =
          await isar.subjects.filter().semesterIdEqualTo(0).findAll();
      for (var subject in subjects) {
        subject.semesterId = semesterId;
      }
      if (subjects.isNotEmpty) await isar.subjects.putAll(subjects);

      final schedules =
          await isar.schedules.filter().semesterIdEqualTo(0).findAll();
      for (var schedule in schedules) {
        schedule.semesterId = semesterId;
      }
      if (schedules.isNotEmpty) await isar.schedules.putAll(schedules);

      // Clean up attendance duplicates & assign semesterId
      final attendances =
          await isar.attendances.filter().semesterIdEqualTo(0).findAll();
      final Map<String, Attendance> dedupMap = {};
      final List<int> toDelete = [];

      for (var att in attendances) {
        att.semesterId = semesterId;

        if (att.scheduleId != null) {
          final key = '${att.date.millisecondsSinceEpoch}_${att.scheduleId}';
          if (dedupMap.containsKey(key)) {
            final existing = dedupMap[key]!;
            if (att.updatedAt.isAfter(existing.updatedAt)) {
              toDelete.add(existing.id);
              dedupMap[key] = att;
            } else {
              toDelete.add(att.id);
            }
          } else {
            dedupMap[key] = att;
          }
        }
      }

      final toKeep =
          attendances.where((a) => !toDelete.contains(a.id)).toList();
      if (toKeep.isNotEmpty) await isar.attendances.putAll(toKeep);
      if (toDelete.isNotEmpty) await isar.attendances.deleteAll(toDelete);

      final histories =
          await isar.attendanceHistorys.filter().semesterIdEqualTo(0).findAll();
      for (var h in histories) {
        h.semesterId = semesterId;
      }
      if (histories.isNotEmpty) await isar.attendanceHistorys.putAll(histories);

      final tasks =
          await isar.academicTasks.filter().semesterIdEqualTo(0).findAll();
      for (var task in tasks) {
        task.semesterId = semesterId;
      }
      if (tasks.isNotEmpty) await isar.academicTasks.putAll(tasks);
    });

    // 4. Update SharedPreferences AFTER the transaction completes (async-safe)
    if (profileId != -1) {
      await prefs.setInt('active_profile_id', profileId);
    }
    await prefs.setBool('v2_migration_complete', true);
  }
}

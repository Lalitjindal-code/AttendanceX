import 'package:isar/isar.dart';
import '../../core/errors/app_exception.dart';
import '../../engines/subject_validator.dart';
import '../../services/widget_service.dart';
import '../collections/attendance_collection.dart';
import '../collections/attendance_history_collection.dart';
import '../collections/schedule_collection.dart';
import '../collections/subject_collection.dart';
import '../collections/academic_task_collection.dart';

/// Details about how much data will be removed when a subject is deleted.
class SubjectDeletionImpact {
  final int schedulesCount;
  final int attendancesCount;
  final int historyCount;
  final int tasksCount;

  const SubjectDeletionImpact({
    required this.schedulesCount,
    required this.attendancesCount,
    required this.historyCount,
    required this.tasksCount,
  });

  bool get hasAnyData =>
      schedulesCount > 0 ||
      attendancesCount > 0 ||
      historyCount > 0 ||
      tasksCount > 0;
}

/// Repository for [Subject] operations following clean architecture constraints.
///
/// Contains pure CRUD/query/watch operations.
class SubjectRepository {
  final Isar _isar;

  const SubjectRepository(this._isar);

  /// Returns a stream of all active subjects, sorted alphabetically by name.
  Stream<List<Subject>> watchAllActive(int semesterId) {
    return _isar.subjects
        .filter()
        .semesterIdEqualTo(semesterId)
        .and()
        .isActiveEqualTo(true)
        .sortByName()
        .watch(fireImmediately: true);
  }

  /// Returns a stream of all subjects (including inactive), sorted by name.
  Stream<List<Subject>> watchAll(int semesterId) {
    return _isar.subjects
        .filter()
        .semesterIdEqualTo(semesterId)
        .sortByName()
        .watch(fireImmediately: true);
  }

  /// Fetches a specific subject by ID.
  Future<Subject?> getById(int id) async {
    return await _isar.subjects.get(id);
  }

  /// Creates a new subject if the name is not a duplicate.
  Future<void> create(Subject subject) async {
    final normalizedName = SubjectValidator.normalizeName(subject.name);

    // Check for duplicates within the same semester
    final exists = await _isar.subjects
            .filter()
            .semesterIdEqualTo(subject.semesterId)
            .and()
            .nameEqualTo(normalizedName, caseSensitive: false)
            .count() >
        0;

    if (exists) {
      throw const DuplicateException(
          'A subject with this name already exists.');
    }

    subject.name = normalizedName;
    subject.createdAt = DateTime.now();
    subject.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.subjects.put(subject);
    });
    WidgetService.instance.updateWidget();
  }

  /// Updates an existing subject. Prevents renaming to an existing subject's name.
  Future<void> update(Subject subject) async {
    final normalizedName = SubjectValidator.normalizeName(subject.name);

    // Check if another subject has the same name within the same semester
    final existingDuplicate = await _isar.subjects
        .filter()
        .semesterIdEqualTo(subject.semesterId)
        .and()
        .nameEqualTo(normalizedName, caseSensitive: false)
        .and()
        .not()
        .idEqualTo(subject.id)
        .findFirst();

    if (existingDuplicate != null) {
      throw const DuplicateException(
          'Another subject with this name already exists.');
    }

    subject.name = normalizedName;
    subject.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.subjects.put(subject);
    });
    WidgetService.instance.updateWidget();
  }

  /// Calculates how many dependent records will be deleted.
  /// Used for the pre-deletion confirmation dialog.
  Future<SubjectDeletionImpact> getDeletionImpact(int subjectId) async {
    final schedulesCount =
        await _isar.schedules.filter().subjectIdEqualTo(subjectId).count();
    final attendancesCount =
        await _isar.attendances.filter().subjectIdEqualTo(subjectId).count();
    final historyCount = await _isar.attendanceHistorys
        .filter()
        .subjectIdEqualTo(subjectId)
        .count();
    final tasksCount =
        await _isar.academicTasks.filter().subjectIdEqualTo(subjectId).count();

    return SubjectDeletionImpact(
      schedulesCount: schedulesCount,
      attendancesCount: attendancesCount,
      historyCount: historyCount,
      tasksCount: tasksCount,
    );
  }

  /// Permanently deletes a subject and all its related records in an atomic transaction.
  Future<void> deletePermanently(int subjectId) async {
    await _isar.writeTxn(() async {
      // 1. Delete Attendance History
      await _isar.attendanceHistorys
          .filter()
          .subjectIdEqualTo(subjectId)
          .deleteAll();

      // 2. Delete Attendance Records
      await _isar.attendances.filter().subjectIdEqualTo(subjectId).deleteAll();

      // 3. Delete Schedule Entries
      await _isar.schedules.filter().subjectIdEqualTo(subjectId).deleteAll();

      // 4. Delete Academic Tasks
      await _isar.academicTasks.filter().subjectIdEqualTo(subjectId).deleteAll();

      // 5. Delete the Subject
      await _isar.subjects.delete(subjectId);
    });
    WidgetService.instance.updateWidget();
  }

  /// One-time migration: Isar defaults new bool fields to `false` for existing
  /// records. This sets [classNotificationsEnabled] and
  /// [plannerNotificationsEnabled] to `true` for any subject that still has
  /// `false` because it was created before those fields were added.
  Future<void> migrateNotificationDefaults() async {
    final subjects = await _isar.subjects.where().findAll();
    final toFix = subjects
        .where((s) =>
            !s.classNotificationsEnabled || !s.plannerNotificationsEnabled)
        .toList();
    if (toFix.isEmpty) return;

    await _isar.writeTxn(() async {
      for (final s in toFix) {
        s.classNotificationsEnabled = true;
        s.plannerNotificationsEnabled = true;
        await _isar.subjects.put(s);
      }
    });
  }
}

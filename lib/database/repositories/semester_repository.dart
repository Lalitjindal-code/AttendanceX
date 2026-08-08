import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database_providers.dart';
import '../collections/semester_collection.dart';
import '../collections/subject_collection.dart';
import '../collections/schedule_collection.dart';
import '../collections/attendance_collection.dart';
import '../collections/attendance_history_collection.dart';
import '../collections/academic_task_collection.dart';

final semesterRepositoryProvider = Provider((ref) {
  return SemesterRepository(ref.watch(isarProvider));
});

class SemesterRepository {
  final Isar _isar;

  SemesterRepository(this._isar);

  Future<int> upsertSemester(Semester semester) async {
    return _isar.writeTxn(() async {
      semester.updatedAt = DateTime.now();
      return _isar.semesters.put(semester);
    });
  }

  Future<void> deleteSemester(int semesterId) async {
    await _isar.writeTxn(() async {
      // Transactional delete of all semester-owned data
      await _isar.subjects.filter().semesterIdEqualTo(semesterId).deleteAll();
      await _isar.schedules.filter().semesterIdEqualTo(semesterId).deleteAll();
      await _isar.attendances.filter().semesterIdEqualTo(semesterId).deleteAll();
      await _isar.attendanceHistorys.filter().semesterIdEqualTo(semesterId).deleteAll();
      await _isar.academicTasks.filter().semesterIdEqualTo(semesterId).deleteAll();
      await _isar.semesters.delete(semesterId);
    });
  }

  Future<Semester?> getSemester(int id) async {
    return _isar.semesters.get(id);
  }

  Future<List<Semester>> getSemestersByProfile(int profileId) async {
    return _isar.semesters.filter().profileIdEqualTo(profileId).findAll();
  }

  Stream<List<Semester>> watchSemestersByProfile(int profileId) {
    return _isar.semesters.filter().profileIdEqualTo(profileId).watch(fireImmediately: true);
  }
}

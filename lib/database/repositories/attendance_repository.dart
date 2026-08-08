import 'package:isar/isar.dart';
import '../../core/enums/attendance_status.dart';
import '../collections/attendance_collection.dart';
import '../collections/attendance_history_collection.dart';
import '../../services/widget_service.dart';

/// Repository for [Attendance] and [AttendanceHistory] operations.
///
/// Contains pure CRUD/query/watch operations.
class AttendanceRepository {
  final Isar _isar;

  const AttendanceRepository(this._isar);

  /// Upserts an [Attendance] record and safely appends to the history log.
  ///
  /// The [AttendanceHistory] is only created if the status actually changes
  /// or if it's a completely new record with a status other than pending.
  Future<void> upsertAttendance(Attendance attendance) async {
    await _isar.writeTxn(() async {
      Attendance? existing;

      if (attendance.id != Isar.autoIncrement) {
        existing = await _isar.attendances.get(attendance.id);
      } else if (attendance.scheduleId != null) {
        // Fallback for scheduled classes: check unique identity
        existing = await _isar.attendances
            .filter()
            .semesterIdEqualTo(attendance.semesterId)
            .and()
            .dateEqualTo(attendance.date)
            .and()
            .scheduleIdEqualTo(attendance.scheduleId)
            .findFirst();

        if (existing != null) {
          attendance.id = existing.id;
          attendance.createdAt = existing.createdAt;
        }
      }

      final previousStatus = existing?.status ?? AttendanceStatus.pending;

      // Do nothing if status hasn't changed (prevents duplicate history entries)
      if (existing != null && previousStatus == attendance.status) {
        // We still save notes or other fields if they changed, but no history log.
        attendance.updatedAt = DateTime.now();
        await _isar.attendances.put(attendance);
        return;
      }

      attendance.updatedAt = DateTime.now();
      await _isar.attendances.put(attendance);

      // Log history for the status change
      final history = AttendanceHistory()
        ..semesterId = attendance.semesterId
        ..attendanceId = attendance.id
        ..subjectId = attendance.subjectId
        ..date = attendance.date
        ..previousStatus = previousStatus
        ..newStatus = attendance.status
        ..changedAt = attendance.updatedAt;

      await _isar.attendanceHistorys.put(history);
    });
    WidgetService.instance.updateWidget();
  }

  /// Returns a stream of all attendance records for a specific subject within a semester.
  Stream<List<Attendance>> watchBySubject(int semesterId, int subjectId) {
    return _isar.attendances
        .filter()
        .semesterIdEqualTo(semesterId)
        .and()
        .subjectIdEqualTo(subjectId)
        .watch(fireImmediately: true);
  }

  /// Fetches all attendance records for a specific subject within a semester.
  Future<List<Attendance>> getBySubjectId(int semesterId, int subjectId) async {
    return await _isar.attendances
        .filter()
        .semesterIdEqualTo(semesterId)
        .and()
        .subjectIdEqualTo(subjectId)
        .findAll();
  }

  /// Returns a stream of all attendance records across a date range for a semester.
  Stream<List<Attendance>> watchByDateRange(int semesterId, DateTime start, DateTime end) {
    return _isar.attendances
        .filter()
        .semesterIdEqualTo(semesterId)
        .and()
        .dateBetween(start, end)
        .watch(fireImmediately: true);
  }

  /// Returns a stream of all attendance records for a semester.
  Stream<List<Attendance>> watchAll(int semesterId) {
    return _isar.attendances.filter().semesterIdEqualTo(semesterId).watch(fireImmediately: true);
  }

  /// Returns a stream of history for a specific subject within a semester.
  Stream<List<AttendanceHistory>> watchHistoryBySubject(int semesterId, int subjectId) {
    return _isar.attendanceHistorys
        .filter()
        .semesterIdEqualTo(semesterId)
        .and()
        .subjectIdEqualTo(subjectId)
        .sortByChangedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Fetches a specific attendance by ID.
  Future<Attendance?> getById(int id) async {
    return await _isar.attendances.get(id);
  }

  /// Deletes an attendance record and its associated history.
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.attendanceHistorys
          .filter()
          .attendanceIdEqualTo(id)
          .deleteAll();
      final attendance = await _isar.attendances.get(id);
      if (attendance != null) {
        await _isar.attendances.delete(id);
      }
    });
    WidgetService.instance.updateWidget();
  }

  /// Clears all attendance records for a specific day transactionally.
  Future<void> deleteAttendancesByDate(DateTime date, int semesterId) async {
    await _isar.writeTxn(() async {
      final toDelete = await _isar.attendances
          .filter()
          .semesterIdEqualTo(semesterId)
          .and()
          .dateEqualTo(date)
          .findAll();

      final ids = toDelete.map((a) => a.id).toList();

      if (ids.isNotEmpty) {
        await _isar.attendanceHistorys
            .filter()
            .anyOf(ids, (q, int id) => q.attendanceIdEqualTo(id))
            .deleteAll();

        await _isar.attendances.deleteAll(ids);
      }
    });
    WidgetService.instance.updateWidget();
  }
}

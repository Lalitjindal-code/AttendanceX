import 'package:isar/isar.dart';
import '../../core/enums/attendance_status.dart';
import '../collections/attendance_collection.dart';
import '../collections/attendance_history_collection.dart';

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
      } else {
        // Try to find by unique composite key just in case
        existing = await _isar.attendances
            .filter()
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

      // Log history if the new status is different
      if (previousStatus != attendance.status) {
        final history = AttendanceHistory()
          ..attendanceId = attendance.id
          ..subjectId = attendance.subjectId
          ..date = attendance.date
          ..previousStatus = previousStatus
          ..newStatus = attendance.status
          ..changedAt = attendance.updatedAt;

        await _isar.attendanceHistorys.put(history);
      }
    });
  }

  /// Returns a stream of all attendance records for a specific subject.
  Stream<List<Attendance>> watchBySubject(int subjectId) {
    return _isar.attendances
        .filter()
        .subjectIdEqualTo(subjectId)
        .watch(fireImmediately: true);
  }

  /// Fetches all attendance records for a specific subject.
  Future<List<Attendance>> getBySubjectId(int subjectId) async {
    return await _isar.attendances
        .filter()
        .subjectIdEqualTo(subjectId)
        .findAll();
  }

  /// Returns a stream of all attendance records across a date range.
  Stream<List<Attendance>> watchByDateRange(DateTime start, DateTime end) {
    return _isar.attendances
        .filter()
        .dateBetween(start, end)
        .watch(fireImmediately: true);
  }

  /// Returns a stream of all attendance records.
  Stream<List<Attendance>> watchAll() {
    return _isar.attendances.where().watch(fireImmediately: true);
  }

  /// Returns a stream of history for a specific subject.
  Stream<List<AttendanceHistory>> watchHistoryBySubject(int subjectId) {
    return _isar.attendanceHistorys
        .filter()
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
      await _isar.attendances.delete(id);
    });
  }
}

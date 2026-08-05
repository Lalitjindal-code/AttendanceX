import 'package:attendify/core/enums/attendance_status.dart';
import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/attendance_history_collection.dart';
import 'package:attendify/database/repositories/attendance_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Isar isar;
  late AttendanceRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [AttendanceSchema, AttendanceHistorySchema],
      directory: '',
      name: 'attendance_test_db',
    );
    repository = AttendanceRepository(isar);
  });

  tearDown(() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  });

  tearDownAll(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('AttendanceRepository Audit Trail', () {
    test('upserting new attendance creates history log', () async {
      final date = DateTime.now();
      final attendance = Attendance()
        ..subjectId = 1
        ..scheduleId = 1
        ..date = date
        ..status = AttendanceStatus.present;

      await repository.upsertAttendance(attendance);

      // Verify attendance created
      final saved = await repository.getById(attendance.id);
      expect(saved, isNotNull);
      expect(saved!.status, AttendanceStatus.present);

      // Verify history created
      final histories = await isar.attendanceHistorys.where().findAll();
      expect(histories.length, 1);

      final history = histories.first;
      expect(history.attendanceId, attendance.id);
      expect(history.previousStatus, AttendanceStatus.pending);
      expect(history.newStatus, AttendanceStatus.present);
    });

    test(
        'upserting existing attendance with same status does NOT create duplicate history',
        () async {
      final date = DateTime.now();
      final attendance = Attendance()
        ..subjectId = 1
        ..scheduleId = 1
        ..date = date
        ..status = AttendanceStatus.present;

      // First insert
      await repository.upsertAttendance(attendance);

      // Update with SAME status
      final toUpdate = await repository.getById(attendance.id);
      toUpdate!.notes = 'Same status update';
      await repository.upsertAttendance(toUpdate);

      // History should still only have 1 entry from the first insert
      final histories = await isar.attendanceHistorys.where().findAll();
      expect(histories.length, 1);
    });

    test(
        'upserting existing attendance with DIFFERENT status creates new history',
        () async {
      final date = DateTime.now();
      final attendance = Attendance()
        ..subjectId = 1
        ..scheduleId = 1
        ..date = date
        ..status = AttendanceStatus.present;

      // First insert
      await repository.upsertAttendance(attendance);

      // Update with DIFFERENT status
      final toUpdate = await repository.getById(attendance.id);
      toUpdate!.status = AttendanceStatus.absent;
      await repository.upsertAttendance(toUpdate);

      // History should now have 2 entries
      final histories =
          await isar.attendanceHistorys.where().sortByChangedAt().findAll();
      expect(histories.length, 2);

      expect(histories[0].previousStatus, AttendanceStatus.pending);
      expect(histories[0].newStatus, AttendanceStatus.present);

      expect(histories[1].previousStatus, AttendanceStatus.present);
      expect(histories[1].newStatus, AttendanceStatus.absent);
    });

    test(
        'upserting new attendance matching unique constraints updates existing and logs history',
        () async {
      final date = DateTime.utc(2023, 1, 1);
      final a1 = Attendance()
        ..subjectId = 1
        ..scheduleId = 2
        ..date = date
        ..status = AttendanceStatus.present;

      await repository.upsertAttendance(a1);

      // Create new instance with SAME composite key but different status
      final a2 = Attendance()
        ..subjectId = 1
        ..scheduleId = 2
        ..date = date
        ..status = AttendanceStatus.absent;

      await repository.upsertAttendance(a2);

      // Should be 1 record total
      final records = await isar.attendances.where().findAll();
      expect(records.length, 1);
      expect(records.first.status, AttendanceStatus.absent);

      // Should be 2 histories
      final histories = await isar.attendanceHistorys.where().findAll();
      expect(histories.length, 2);
    });
  });
}

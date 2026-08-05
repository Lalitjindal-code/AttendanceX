import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attendify/core/errors/app_exception.dart';
import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/attendance_history_collection.dart';
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/database/repositories/subject_repository.dart';

void main() {
  late Isar isar;
  late SubjectRepository repository;
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_test');
    isar = await Isar.open(
      [
        SubjectSchema,
        ScheduleSchema,
        AttendanceSchema,
        AttendanceHistorySchema
      ],
      directory: tempDir.path,
    );
    repository = SubjectRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('SubjectRepository CRUD', () {
    test('creates a subject successfully', () async {
      final subject = Subject()..name = 'Math';
      await repository.create(subject);

      final fetched = await repository.getById(subject.id);
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Math');
    });

    test('throws DuplicateException on duplicate name', () async {
      final sub1 = Subject()..name = 'Math';
      await repository.create(sub1);

      final sub2 = Subject()..name = ' math ';
      expect(
        () => repository.create(sub2),
        throwsA(isA<DuplicateException>()),
      );
    });

    test('updates a subject successfully', () async {
      final subject = Subject()..name = 'Math';
      await repository.create(subject);

      subject.name = 'Advanced Math';
      await repository.update(subject);

      final fetched = await repository.getById(subject.id);
      expect(fetched!.name, 'Advanced Math');
    });

    test('throws DuplicateException when updating to an existing name',
        () async {
      final sub1 = Subject()..name = 'Math';
      await repository.create(sub1);

      final sub2 = Subject()..name = 'Science';
      await repository.create(sub2);

      sub2.name = 'Math';
      expect(
        () => repository.update(sub2),
        throwsA(isA<DuplicateException>()),
      );
    });
  });

  group('SubjectRepository Cascade Delete', () {
    test('getDeletionImpact returns correct counts', () async {
      final subject = Subject()..name = 'Math';
      await repository.create(subject);

      await isar.writeTxn(() async {
        await isar.schedules.put(Schedule()
          ..subjectId = subject.id
          ..startTime = '09:00'
          ..endTime = '10:00');
        await isar.schedules.put(Schedule()
          ..subjectId = subject.id
          ..startTime = '11:00'
          ..endTime = '12:00');
        await isar.attendances.put(Attendance()
          ..subjectId = subject.id
          ..date = DateTime.now());
      });

      final impact = await repository.getDeletionImpact(subject.id);
      expect(impact.schedulesCount, 2);
      expect(impact.attendancesCount, 1);
      expect(impact.historyCount, 0);
      expect(impact.hasAnyData, true);
    });

    test('deletePermanently cascades and deletes everything', () async {
      final subject = Subject()..name = 'Math';
      await repository.create(subject);

      await isar.writeTxn(() async {
        await isar.schedules.put(Schedule()
          ..subjectId = subject.id
          ..startTime = '09:00'
          ..endTime = '10:00');
        await isar.attendances.put(Attendance()
          ..subjectId = subject.id
          ..date = DateTime.now());
      });

      await repository.deletePermanently(subject.id);

      final impactAfter = await repository.getDeletionImpact(subject.id);
      expect(impactAfter.schedulesCount, 0);
      expect(impactAfter.attendancesCount, 0);

      final fetchedSubject = await repository.getById(subject.id);
      expect(fetchedSubject, isNull);
    });
  });
}

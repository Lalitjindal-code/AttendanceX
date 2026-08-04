import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/repositories/schedule_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Isar isar;
  late ScheduleRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [ScheduleSchema],
      directory: '',
      name: 'schedule_test_db',
    );
    repository = ScheduleRepository(isar);
  });

  tearDown(() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  });

  tearDownAll(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('ScheduleRepository CRUD', () {
    test('creates and fetches a schedule', () async {
      final schedule = Schedule()
        ..dayOfWeek = 1
        ..startTime = '09:00'
        ..endTime = '10:00'
        ..order = 0;

      await repository.create(schedule);

      final fetched = await repository.getById(schedule.id);
      expect(fetched, isNotNull);
      expect(fetched!.startTime, '09:00');
    });

    test('updateOrder reorders schedules correctly', () async {
      final s1 = Schedule()
        ..dayOfWeek = 1
        ..startTime = '09:00'
        ..endTime = '10:00'
        ..order = 0;
      final s2 = Schedule()
        ..dayOfWeek = 1
        ..startTime = '10:00'
        ..endTime = '11:00'
        ..order = 1;

      await repository.create(s1);
      await repository.create(s2);

      // Swap orders: s2 becomes 0, s1 becomes 1
      await repository.updateOrder([s2.id, s1.id]);

      final fetchedS1 = await repository.getById(s1.id);
      final fetchedS2 = await repository.getById(s2.id);

      expect(fetchedS1!.order, 1);
      expect(fetchedS2!.order, 0);
    });
  });
}

import 'package:isar/isar.dart';
import '../collections/schedule_collection.dart';

/// Repository for [Schedule] operations following clean architecture constraints.
///
/// Contains pure CRUD/query/watch operations.
class ScheduleRepository {
  final Isar _isar;

  const ScheduleRepository(this._isar);

  /// Returns a stream of all schedules for a specific day, sorted by order.
  /// This is specifically for the Schedule editing screen (drag-and-drop).
  Stream<List<Schedule>> watchByDaySortedByOrder(int dayOfWeek) {
    return _isar.schedules
        .filter()
        .dayOfWeekEqualTo(dayOfWeek)
        .sortByOrder()
        .watch(fireImmediately: true);
  }

  /// Returns a stream of all schedules for a specific day, sorted chronologically.
  /// This is used by Dashboard, Calendar, and Attendance matching.
  Stream<List<Schedule>> watchByDaySortedByTime(int dayOfWeek) {
    return _isar.schedules
        .filter()
        .dayOfWeekEqualTo(dayOfWeek)
        .sortByStartTime()
        .watch(fireImmediately: true);
  }

  /// Returns a stream of all schedules.
  Stream<List<Schedule>> watchAll() {
    return _isar.schedules.where().anyId().watch(fireImmediately: true);
  }

  /// Fetches a specific schedule by ID.
  Future<Schedule?> getById(int id) async {
    return await _isar.schedules.get(id);
  }

  /// Creates a new schedule.
  Future<void> create(Schedule schedule) async {
    schedule.createdAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.schedules.put(schedule);
    });
  }

  /// Updates an existing schedule.
  Future<void> update(Schedule schedule) async {
    await _isar.writeTxn(() async {
      await _isar.schedules.put(schedule);
    });
  }

  /// Deletes a schedule by its ID.
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.schedules.delete(id);
    });
  }

  /// Batch updates the order field of multiple schedules for drag-and-drop.
  Future<void> updateOrder(List<int> scheduleIds) async {
    await _isar.writeTxn(() async {
      for (var i = 0; i < scheduleIds.length; i++) {
        final id = scheduleIds[i];
        final schedule = await _isar.schedules.get(id);
        if (schedule != null) {
          schedule.order = i;
          await _isar.schedules.put(schedule);
        }
      }
    });
  }

  /// Fetches all schedules for a specific day (used by Engine for conflict validation).
  Future<List<Schedule>> getByDay(int dayOfWeek) async {
    return await _isar.schedules.filter().dayOfWeekEqualTo(dayOfWeek).findAll();
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/database_providers.dart';
import '../../../database/repositories/schedule_repository.dart';

part 'schedule_providers.g.dart';

@Riverpod(keepAlive: true)
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return ScheduleRepository(isar);
}

@riverpod
Stream<List<Schedule>> schedulesForDay(SchedulesForDayRef ref, int dayOfWeek) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.watchByDaySortedByOrder(dayOfWeek);
}

@riverpod
Stream<List<Schedule>> allSchedules(AllSchedulesRef ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.watchAll();
}

@riverpod
Stream<List<Schedule>> schedulesForDaySortedByTime(SchedulesForDaySortedByTimeRef ref, int dayOfWeek) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.watchByDaySortedByTime(dayOfWeek);
}

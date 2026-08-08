import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database_providers.dart';
import '../../../database/repositories/planner_repository.dart';
import '../../../database/collections/academic_task_collection.dart';
import '../../../engines/planner_engine.dart';
import '../../../core/enums/task_status.dart';

import '../models/planner_filter.dart';

import '../../settings/providers/semester_provider.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepository(ref.watch(isarProvider));
});

final plannerTasksProvider = StreamProvider<List<AcademicTask>>((ref) {
  final repo = ref.watch(plannerRepositoryProvider);
  final semester = ref.watch(semesterStateProvider);
  if (semester == null) return Stream.value([]);
  return repo.watchAllTasks(semester.id);
});

final plannerFilterProvider =
    StateProvider<PlannerFilter>((ref) => const PlannerFilter());

/// A computed provider that yields filtered tasks sorted by PlannerEngine.
final sortedPlannerTasksProvider =
    Provider<AsyncValue<List<AcademicTask>>>((ref) {
  final tasksAsync = ref.watch(plannerTasksProvider);
  final filter = ref.watch(plannerFilterProvider);

  return tasksAsync.whenData((tasks) {
    final filtered = tasks.where((t) {
      if (filter.subjectId != null && t.subjectId != filter.subjectId) {
        return false;
      }
      if (filter.priority != null && t.priority != filter.priority) {
        return false;
      }
      if (filter.status != null && t.status != filter.status) return false;
      if (filter.hideCompleted &&
          t.status == TaskStatus.completed &&
          filter.status != TaskStatus.completed) {
        return false;
      }
      return true;
    }).toList();

    return PlannerEngine.sortTasks(filtered);
  });
});

class PlannerNotifier extends StateNotifier<AsyncValue<void>> {
  final PlannerRepository _repository;
  final Ref ref;

  PlannerNotifier(this._repository, this.ref) : super(const AsyncValue.data(null));

  Future<void> saveTask(AcademicTask task) async {
    state = const AsyncValue.loading();
    try {
      if (task.semesterId == 0) {
        final semester = ref.read(semesterStateProvider);
        if (semester != null) {
          task.semesterId = semester.id;
        }
      }
      await _repository.upsertTask(task);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteTask(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleTaskCompletion(AcademicTask task) async {
    final updated = AcademicTask()
      ..id = task.id
      ..title = task.title
      ..description = task.description
      ..subjectId = task.subjectId
      ..facultyId = task.facultyId
      ..type = task.type
      ..priority = task.priority
      ..dueDate = task.dueDate
      ..dueTime = task.dueTime
      ..estimatedDuration = task.estimatedDuration
      ..repeatRule = task.repeatRule
      ..notes = task.notes
      ..createdAt = task.createdAt
      ..attachments = task.attachments
      ..submissionUrls = task.submissionUrls
      ..notificationOffsets = task.notificationOffsets;

    if (task.status == TaskStatus.completed) {
      updated.status = TaskStatus.pending;
    } else {
      updated.status = TaskStatus.completed;
    }

    final semester = ref.read(semesterStateProvider);
    if (semester != null) {
      updated.semesterId = semester.id;
    }

    await saveTask(updated);
  }
}

final plannerNotifierProvider =
    StateNotifierProvider<PlannerNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(plannerRepositoryProvider);
  return PlannerNotifier(repo, ref);
});

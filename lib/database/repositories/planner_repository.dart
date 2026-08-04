import 'package:isar/isar.dart';
import '../collections/academic_task_collection.dart';
import '../../core/enums/task_status.dart';

class PlannerRepository {
  final Isar _isar;

  const PlannerRepository(this._isar);

  Future<void> upsertTask(AcademicTask task) async {
    await _isar.writeTxn(() async {
      task.updatedAt = DateTime.now();
      if (task.status == TaskStatus.completed && task.completedAt == null) {
        task.completedAt = DateTime.now();
      } else if (task.status != TaskStatus.completed) {
        task.completedAt = null;
      }
      await _isar.academicTasks.put(task);
    });
  }

  Future<void> deleteTask(int id) async {
    await _isar.writeTxn(() async {
      await _isar.academicTasks.delete(id);
    });
  }

  Future<AcademicTask?> getById(int id) async {
    return await _isar.academicTasks.get(id);
  }

  Stream<List<AcademicTask>> watchAllTasks() {
    return _isar.academicTasks.where().watch(fireImmediately: true);
  }
}

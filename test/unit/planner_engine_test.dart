import 'package:flutter_test/flutter_test.dart';
import 'package:attendify/core/enums/task_priority.dart';
import 'package:attendify/core/enums/task_status.dart';
import 'package:attendify/core/enums/task_type.dart';
import 'package:attendify/database/collections/academic_task_collection.dart';
import 'package:attendify/engines/planner_engine.dart';

void main() {
  group('PlannerEngine Tests', () {
    test('isOverdue correctly identifies overdue tasks', () {
      final now = DateTime.now();

      final taskOverdue = AcademicTask()
        ..title = 'Old'
        ..dueDate = now.subtract(const Duration(days: 2))
        ..status = TaskStatus.pending
        ..type = TaskType.assignment;

      final taskFuture = AcademicTask()
        ..title = 'Future'
        ..dueDate = now.add(const Duration(days: 2))
        ..status = TaskStatus.pending
        ..type = TaskType.assignment;

      final taskCompletedOverdue = AcademicTask()
        ..title = 'Completed'
        ..dueDate = now.subtract(const Duration(days: 2))
        ..status = TaskStatus.completed
        ..type = TaskType.assignment;

      expect(PlannerEngine.isOverdue(taskOverdue), isTrue);
      expect(PlannerEngine.isOverdue(taskFuture), isFalse);
      expect(PlannerEngine.isOverdue(taskCompletedOverdue), isFalse);
    });

    test('generateDueLabel returns correct labels', () {
      final now = DateTime.now();

      final taskToday = AcademicTask()
        ..dueDate = now
        ..status = TaskStatus.pending;
      final taskTomorrow = AcademicTask()
        ..dueDate = now.add(const Duration(days: 1))
        ..status = TaskStatus.pending;
      final taskOverdue = AcademicTask()
        ..dueDate = now.subtract(const Duration(days: 2))
        ..status = TaskStatus.pending;
      final taskCompleted = AcademicTask()
        ..dueDate = now
        ..status = TaskStatus.completed;

      expect(PlannerEngine.generateDueLabel(taskToday), 'Today');
      expect(PlannerEngine.generateDueLabel(taskTomorrow), 'Tomorrow');
      expect(PlannerEngine.generateDueLabel(taskOverdue), 'Overdue by 2 Days');
      expect(PlannerEngine.generateDueLabel(taskCompleted), 'Completed');
    });

    test(
        'sortTasks prioritizes pending over completed, then by date, then priority',
        () {
      final now = DateTime.now();

      final taskCompleted = AcademicTask()
        ..title = 'T1'
        ..status = TaskStatus.completed
        ..priority = TaskPriority.critical
        ..dueDate = now
        ..type = TaskType.assignment;

      final taskPendingLate = AcademicTask()
        ..title = 'T2'
        ..status = TaskStatus.pending
        ..priority = TaskPriority.low
        ..dueDate = now.add(const Duration(days: 5))
        ..type = TaskType.assignment;

      final taskPendingSoonCritical = AcademicTask()
        ..title = 'T3'
        ..status = TaskStatus.pending
        ..priority = TaskPriority.critical
        ..dueDate = now.add(const Duration(days: 1))
        ..type = TaskType.assignment;

      final taskPendingSoonLow = AcademicTask()
        ..title = 'T4'
        ..status = TaskStatus.pending
        ..priority = TaskPriority.low
        ..dueDate = now.add(const Duration(days: 1))
        ..type = TaskType.assignment;

      final tasks = [
        taskCompleted,
        taskPendingLate,
        taskPendingSoonLow,
        taskPendingSoonCritical
      ];
      final sorted = PlannerEngine.sortTasks(tasks);

      // Order should be: T3, T4, T2, T1
      expect(sorted[0].title, 'T3');
      expect(sorted[1].title, 'T4');
      expect(sorted[2].title, 'T2');
      expect(sorted[3].title, 'T1');
    });

    test('getDashboardUpcomingDeadlines filters and sorts correctly', () {
      final now = DateTime.now();

      final overdueTask = AcademicTask()
        ..title = 'T1'
        ..dueDate = now.subtract(const Duration(days: 2))
        ..priority = TaskPriority.low
        ..status = TaskStatus.pending
        ..type = TaskType.assignment;

      final criticalTodayTask = AcademicTask()
        ..title = 'T2'
        ..dueDate = now
        ..priority = TaskPriority.critical
        ..status = TaskStatus.pending
        ..type = TaskType.assignment;

      final completedTask = AcademicTask()
        ..title = 'T3'
        ..dueDate = now
        ..status = TaskStatus.completed
        ..type = TaskType.assignment;

      final tasks = [completedTask, criticalTodayTask, overdueTask];
      final dashboardTasks = PlannerEngine.getDashboardUpcomingDeadlines(tasks);

      // Should exclude completed task, overdue should be first.
      expect(dashboardTasks.length, 2);
      expect(dashboardTasks[0].title, 'T1');
      expect(dashboardTasks[1].title, 'T2');
    });
  });
}

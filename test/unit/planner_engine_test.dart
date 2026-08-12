import 'package:flutter_test/flutter_test.dart';
import 'package:attendify/core/enums/task_priority.dart';
import 'package:attendify/core/enums/task_status.dart';
import 'package:attendify/core/enums/task_type.dart';
import 'package:attendify/database/collections/academic_task_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';
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

    test(
        'generateTaskNotifications respects plannerNotificationsEnabled for subject',
        () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final subEnabled = Subject()
        ..id = 1
        ..name = 'Math'
        ..plannerNotificationsEnabled = true;
      final subDisabled = Subject()
        ..id = 2
        ..name = 'Physics'
        ..plannerNotificationsEnabled = false;

      final task1 = AcademicTask()
        ..id = 101
        ..title = 'Math Assignment'
        ..dueDate = now.add(const Duration(days: 1))
        ..status = TaskStatus.pending
        ..subjectId = 1
        ..type = TaskType.assignment
        ..notificationOffsets = [60]; // 1 hour

      final task2 = AcademicTask()
        ..id = 102
        ..title = 'Physics Assignment'
        ..dueDate = now.add(const Duration(days: 1))
        ..status = TaskStatus.pending
        ..subjectId = 2
        ..type = TaskType.assignment
        ..notificationOffsets = [60]; // 1 hour

      final notifications = PlannerEngine.generateTaskNotifications(
        [task1, task2],
        [subEnabled, subDisabled],
        now,
      );

      // Only task1 (Math) should generate notification, task2 (Physics) is disabled
      expect(notifications.length, 1);
      expect(subDisabled.plannerNotificationsEnabled, isFalse);
      expect(notifications.first.title, contains('Math'));
    });

    test('generateTaskNotifications respects enabledTaskTypes filter', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final sub = Subject()
        ..id = 1
        ..name = 'Math';

      final taskAssignment = AcademicTask()
        ..id = 101
        ..title = 'Math Assignment'
        ..dueDate = now.add(const Duration(days: 1))
        ..status = TaskStatus.pending
        ..subjectId = 1
        ..type = TaskType.assignment
        ..notificationOffsets = [60];

      final taskQuiz = AcademicTask()
        ..id = 102
        ..title = 'Math Quiz'
        ..dueDate = now.add(const Duration(days: 1))
        ..status = TaskStatus.pending
        ..subjectId = 1
        ..type = TaskType.quiz
        ..notificationOffsets = [60];

      // Enable assignment, disable quiz
      final enabledTypes = ['assignment'];

      final notifications = PlannerEngine.generateTaskNotifications(
        [taskAssignment, taskQuiz],
        [sub],
        now,
        enabledTaskTypes: enabledTypes,
      );

      // Only taskAssignment should have notifications generated
      expect(notifications.length, 1);
      expect(notifications.first.title, contains('ASSIGNMENT'));
    });
  });
}

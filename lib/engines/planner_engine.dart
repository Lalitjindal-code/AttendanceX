import '../core/enums/task_status.dart';
import '../database/collections/academic_task_collection.dart';
import '../features/notifications/models/scheduled_notification.dart';
import '../database/collections/subject_collection.dart';

/// Pure Dart engine for AcademicTask logic, sorting, filtering, and insights.
class PlannerEngine {
  /// Sorts tasks by status, then due date, then priority.
  static List<AcademicTask> sortTasks(List<AcademicTask> tasks) {
    tasks.sort((a, b) {
      // Completed tasks go to the bottom
      if (a.status == TaskStatus.completed && b.status != TaskStatus.completed) {
        return 1;
      }
      if (b.status == TaskStatus.completed && a.status != TaskStatus.completed) {
        return -1;
      }

      // Then by due date
      final dateCmp = a.dueDate.compareTo(b.dueDate);
      if (dateCmp != 0) return dateCmp;

      // Then by priority (critical first)
      return b.priority.index.compareTo(a.priority.index);
    });
    return tasks;
  }

  /// Categorizes tasks and returns the top 5 for the dashboard "Upcoming Deadlines".
  static List<AcademicTask> getDashboardUpcomingDeadlines(
      List<AcademicTask> tasks) {
    // Filter out completed and cancelled tasks
    final activeTasks = tasks
        .where((t) =>
            t.status != TaskStatus.completed &&
            t.status != TaskStatus.cancelled)
        .toList();

    // Sort logic for Dashboard:
    // 1. Overdue
    // 2. Due Today
    // 3. Due Tomorrow
    // 4. Due Within 3 Days
    // 5. Due This Week
    // ...
    activeTasks.sort((a, b) {
      final bool aIsOverdue = isOverdue(a);
      final bool bIsOverdue = isOverdue(b);

      if (aIsOverdue && !bIsOverdue) return -1;
      if (!aIsOverdue && bIsOverdue) return 1;

      // Sort by due date next
      final int dateCmp = a.dueDate.compareTo(b.dueDate);
      if (dateCmp != 0) return dateCmp;

      // Then by priority
      return b.priority.index.compareTo(a.priority.index);
    });

    return activeTasks.take(5).toList();
  }

  /// Determines if a task is overdue.
  static bool isOverdue(AcademicTask task) {
    if (task.status == TaskStatus.completed ||
        task.status == TaskStatus.cancelled) {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Using just dueDate for now.
    // If dueTime is available, we could do more precise checking.
    return task.dueDate.isBefore(today);
  }

  /// Generates a human-readable due label.
  static String generateDueLabel(AcademicTask task) {
    if (task.status == TaskStatus.completed) return 'Completed';
    if (task.status == TaskStatus.cancelled) return 'Cancelled';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due =
        DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);

    final diff = due.difference(today).inDays;

    if (diff < 0) {
      if (diff == -1) return 'Overdue by 1 Day';
      return 'Overdue by ${diff.abs()} Days';
    } else if (diff == 0) {
      return 'Today';
    } else if (diff == 1) {
      return 'Tomorrow';
    } else if (diff == 2) {
      return 'In 2 Days';
    } else if (diff <= 7) {
      return 'In $diff Days';
    } else {
      return '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}';
    }
  }

  /// Generates Weekend Planner Study Plan.
  static List<String> generateWeekendPlan(List<AcademicTask> pendingTasks) {
    if (pendingTasks.isEmpty) {
      return ['You have no pending tasks. Enjoy your weekend!'];
    }

    // Sort tasks by priority and date
    final sorted = sortTasks(List.from(pendingTasks));

    final List<String> plan = [];
    int count = 0;

    for (var task in sorted) {
      if (count >= 5) break;
      plan.add('Finish ${task.title} (${task.type.name})');
      count++;
    }

    return plan;
  }

  /// Generates scheduled notifications for tasks.
  static List<ScheduledNotification> generateTaskNotifications(
    List<AcademicTask> tasks,
    List<Subject> subjects,
    DateTime now, {
    List<String>? enabledTaskTypes,
  }) {
    final List<ScheduledNotification> notifications = [];

    final activeTasks = tasks.where((t) =>
        t.status == TaskStatus.pending || t.status == TaskStatus.inProgress);

    for (var task in activeTasks) {
      if (task.notificationOffsets.isEmpty) continue;

      final subject = subjects.firstWhere((s) => s.id == task.subjectId,
          orElse: () => Subject()..name = 'Unknown Subject');

      // Skip if planner notifications are disabled for this subject
      if (subject.id != 0 && !subject.plannerNotificationsEnabled) continue;

      // Skip if this task type notification is disabled
      if (enabledTaskTypes != null && !enabledTaskTypes.contains(task.type.name)) continue;

      DateTime dueDateTime = task.dueDate;
      if (task.dueTime != null) {
        try {
          final parts = task.dueTime!.split(':');
          if (parts.length == 2) {
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            dueDateTime = DateTime(dueDateTime.year, dueDateTime.month,
                dueDateTime.day, hour, minute);
          }
        } catch (_) {}
      } else {
        dueDateTime = DateTime(
            dueDateTime.year, dueDateTime.month, dueDateTime.day, 23, 59);
      }

      for (var offsetMinutes in task.notificationOffsets) {
        final scheduledTime =
            dueDateTime.subtract(Duration(minutes: offsetMinutes));

        if (scheduledTime.isAfter(now) &&
            scheduledTime.difference(now).inDays < 30) {
          final id = _generateTaskId(task.id, offsetMinutes);

          String body = '${task.title} is due in ';
          if (offsetMinutes >= 1440) {
            body += '${offsetMinutes ~/ 1440} day(s)';
          } else if (offsetMinutes >= 60) {
            body += '${offsetMinutes ~/ 60} hour(s)';
          } else {
            body += '$offsetMinutes minutes';
          }

          notifications.add(ScheduledNotification(
            id: id,
            title: '${task.type.name.toUpperCase()} Reminder: ${subject.name}',
            body: body,
            scheduledDate: scheduledTime,
            payload: 'task_${task.id}',
          ));
        }
      }
    }
    return notifications;
  }

  static int _generateTaskId(int taskId, int offsetMinutes) {
    return 1000000 + (taskId * 1000) + (offsetMinutes % 1000);
  }
}

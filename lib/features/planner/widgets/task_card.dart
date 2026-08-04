import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/enums/task_type.dart';
import '../../../database/collections/academic_task_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../engines/planner_engine.dart';
import '../providers/planner_provider.dart';
import '../../../core/utils/haptics.dart';

class TaskCard extends ConsumerWidget {
  final AcademicTask task;
  final Subject? subject;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    this.subject,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue = PlannerEngine.isOverdue(task);

    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.critical:
        priorityColor = Theme.of(context).colorScheme.error;
        break;
      case TaskPriority.high:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.blue;
        break;
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
    }

    if (isCompleted)
      priorityColor = Theme.of(context).colorScheme.outlineVariant;

    // Use subject color if available, otherwise priority color
    final stripeColor = subject != null && !isCompleted
        ? Color(subject!.colorValue)
        : priorityColor;

    IconData typeIcon;
    switch (task.type) {
      case TaskType.assignment:
        typeIcon = Icons.assignment_outlined;
        break;
      case TaskType.quiz:
        typeIcon = Icons.quiz_outlined;
        break;
      case TaskType.labFile:
        typeIcon = Icons.science_outlined;
        break;
      case TaskType.homework:
        typeIcon = Icons.menu_book_outlined;
        break;
      default:
        typeIcon = Icons.task_outlined;
        break;
    }

    return AnimatedScale(
      scale: isCompleted ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isCompleted ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Semantics(
          label:
              'Task: ${task.title}. Priority: ${task.priority.name}. ${isCompleted ? "Completed." : (isOverdue ? "Overdue." : "Pending.")}',
          button: true,
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // radiusMD
              side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.5),
              ),
            ),
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              onTap: isCompleted ? null : onEdit,
              onLongPress: () => _showOptions(context, ref),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left color stripe
                    Container(
                      width: 6,
                      color: stripeColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type Icon
                            Icon(
                              typeIcon,
                              size: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: isCompleted
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        ),
                                    child: Text(task.title),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      if (subject != null) ...[
                                        Flexible(
                                          child: Text(
                                            subject!.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          '•',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                              ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                      ],
                                      Flexible(
                                        child: Text(
                                          PlannerEngine.generateDueLabel(task),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: isOverdue && !isCompleted
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .error
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                fontWeight:
                                                    isOverdue && !isCompleted
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Checkbox
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return ScaleTransition(
                                      scale: animation, child: child);
                                },
                                child: Icon(
                                  isCompleted
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  key: ValueKey<bool>(isCompleted),
                                  color: isCompleted
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              tooltip: isCompleted
                                  ? 'Mark as incomplete'
                                  : 'Mark as complete',
                              onPressed: () {
                                ref
                                    .read(plannerNotifierProvider.notifier)
                                    .toggleTaskCompletion(task);
                                Haptics.light();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Task',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(plannerNotifierProvider.notifier).deleteTask(task.id);
                Haptics.heavy();
              },
            ),
          ],
        ),
      ),
    );
  }
}

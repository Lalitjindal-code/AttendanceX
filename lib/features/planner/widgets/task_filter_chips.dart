import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/task_priority.dart';
import '../../subjects/providers/subject_providers.dart';
import '../providers/planner_provider.dart';
import '../models/planner_filter.dart';
import '../../../core/utils/haptics.dart';

class TaskFilterChips extends ConsumerWidget {
  const TaskFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(plannerFilterProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Clear Filters
          if (!filter.isEmpty || !filter.hideCompleted)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ActionChip(
                avatar: Icon(Icons.close,
                    size: 16, color: Theme.of(context).colorScheme.onSurface),
                label: Text('Clear',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold)),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                onPressed: () {
                  ref.read(plannerFilterProvider.notifier).state =
                      const PlannerFilter();
                  Haptics.selection();
                },
              ),
            ),

          // Completed toggle
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text('Show Completed',
                  style: TextStyle(
                      color: !filter.hideCompleted
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                      fontWeight: !filter.hideCompleted
                          ? FontWeight.bold
                          : FontWeight.w600)),
              selected: !filter.hideCompleted,
              onSelected: (selected) {
                ref.read(plannerFilterProvider.notifier).state =
                    filter.copyWith(hideCompleted: !selected);
                Haptics.selection();
              },
              showCheckmark: false,
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              side: !filter.hideCompleted
                  ? BorderSide.none
                  : BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
          ),

          // Priorities
          ...TaskPriority.values.map((priority) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  label: Text(
                      priority.name.substring(0, 1).toUpperCase() +
                          priority.name.substring(1),
                      style: TextStyle(
                          color: filter.priority == priority
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                          fontWeight: filter.priority == priority
                              ? FontWeight.bold
                              : FontWeight.w600)),
                  selected: filter.priority == priority,
                  onSelected: (selected) {
                    ref.read(plannerFilterProvider.notifier).state = filter
                        .copyWith(priority: priority, clearPriority: !selected);
                    Haptics.selection();
                  },
                  showCheckmark: false,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  side: filter.priority == priority
                      ? BorderSide.none
                      : BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
              )),

          // Subjects
          if (subjectsAsync.valueOrNull != null)
            ...subjectsAsync.valueOrNull!.map((subject) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(subject.name,
                        style: TextStyle(
                            color: filter.subjectId == subject.id
                                ? Colors.white
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                            fontWeight: filter.subjectId == subject.id
                                ? FontWeight.bold
                                : FontWeight.w600)),
                    selected: filter.subjectId == subject.id,
                    onSelected: (selected) {
                      ref.read(plannerFilterProvider.notifier).state =
                          filter.copyWith(
                              subjectId: subject.id, clearSubject: !selected);
                      Haptics.selection();
                    },
                    showCheckmark: false,
                    avatar: CircleAvatar(
                      backgroundColor: filter.subjectId == subject.id
                          ? Colors.white
                          : Color(subject.colorValue),
                      radius: 8,
                    ),
                    selectedColor:
                        Color(subject.colorValue).withValues(alpha: 0.8),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainer,
                    side: filter.subjectId == subject.id
                        ? BorderSide.none
                        : BorderSide(
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                )),
        ],
      ),
    );
  }
}

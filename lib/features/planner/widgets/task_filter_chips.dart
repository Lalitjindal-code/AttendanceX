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
                avatar: const Icon(Icons.close, size: 16),
                label: const Text('Clear'),
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
              label: const Text('Show Completed'),
              selected: !filter.hideCompleted,
              onSelected: (selected) {
                ref.read(plannerFilterProvider.notifier).state =
                    filter.copyWith(hideCompleted: !selected);
                Haptics.selection();
              },
            ),
          ),

          // Priorities
          ...TaskPriority.values.map((priority) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  label: Text(priority.name.substring(0, 1).toUpperCase() +
                      priority.name.substring(1)),
                  selected: filter.priority == priority,
                  onSelected: (selected) {
                    ref.read(plannerFilterProvider.notifier).state = filter
                        .copyWith(priority: priority, clearPriority: !selected);
                    Haptics.selection();
                  },
                ),
              )),

          // Subjects
          if (subjectsAsync.valueOrNull != null)
            ...subjectsAsync.valueOrNull!.map((subject) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(subject.name),
                    selected: filter.subjectId == subject.id,
                    onSelected: (selected) {
                      ref.read(plannerFilterProvider.notifier).state =
                          filter.copyWith(
                              subjectId: subject.id, clearSubject: !selected);
                      Haptics.selection();
                    },
                    avatar: CircleAvatar(
                      backgroundColor: Color(subject.colorValue),
                      radius: 8,
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/calendar_state.dart';
import 'daily_attendance_card.dart';
import '../../planner/widgets/task_card.dart';

class DayDetailPanel extends ConsumerWidget {
  final CalendarState state;

  const DayDetailPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.selectedDayDetails.items.isEmpty && state.selectedDayTasks.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No classes or tasks scheduled for',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  DateFormat('MMMM d, yyyy').format(state.selectedDate),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Logic to interleave titles and lists if necessary
            // For simplicity, we just rebuild a linear list of widgets
            final children = <Widget>[];

            if (state.selectedDayDetails.items.isNotEmpty) {
              children.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
                  child: Text(
                    'Classes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
              children.addAll(
                state.selectedDayDetails.items.map(
                  (item) => DailyAttendanceCard(item: item, date: state.selectedDate),
                ),
              );
              children.add(const SizedBox(height: AppSpacing.lg));
            }

            if (state.selectedDayTasks.isNotEmpty) {
              children.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
                  child: Text(
                    'Tasks & Deadlines',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
              children.addAll(
                state.selectedDayTasks.map((task) {
                  final subject = state.allSubjects.where((s) => s.id == task.subjectId).firstOrNull;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: TaskCard(task: task, subject: subject),
                  );
                }),
              );
            }

            if (index < children.length) {
              return children[index];
            }
            return null;
          },
          childCount: (state.selectedDayDetails.items.isNotEmpty ? state.selectedDayDetails.items.length + 2 : 0) +
                      (state.selectedDayTasks.isNotEmpty ? state.selectedDayTasks.length + 1 : 0),
        ),
      ),
    );
  }
}

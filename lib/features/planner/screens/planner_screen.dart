import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/task_status.dart';
import '../../../database/collections/academic_task_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../engines/planner_engine.dart';
import '../../subjects/providers/subject_providers.dart';
import '../providers/planner_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_chips.dart';
import 'task_form_screen.dart';

import '../../../core/utils/haptics.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabExtended = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == 
        ScrollDirection.reverse) {
      if (_isFabExtended) {
        setState(() => _isFabExtended = false);
      }
    } else if (_scrollController.position.userScrollDirection == 
        ScrollDirection.forward) {
      if (!_isFabExtended) {
        setState(() => _isFabExtended = true);
      }
    }
  }

  Future<void> _onRefresh() async {
    Haptics.selection();
    ref.invalidate(sortedPlannerTasksProvider);
    ref.invalidate(subjectsProvider);
    // Add a tiny delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(sortedPlannerTasksProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
          SliverAppBar.large(
            title: const Text('Planner'),
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Task',
                onPressed: () => showTaskFormSheet(context),
              ),
            ],
          ),
          
          // Filter Chips
          const SliverToBoxAdapter(
            child: TaskFilterChips(),
          ),
          
          tasksAsync.when(
            data: (tasks) {
              final subjects = subjectsAsync.valueOrNull ?? [];
              
              if (tasks.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 72,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            ref.watch(plannerFilterProvider).isEmpty 
                                ? "All caught up! Add a deadline when you're ready."
                                : 'No tasks match your filters.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (ref.watch(plannerFilterProvider).isEmpty)
                            FilledButton.icon(
                              onPressed: () => showTaskFormSheet(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Task'),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final overdueTasks = tasks.where(PlannerEngine.isOverdue).toList();
              final todayTasks = tasks.where((t) => PlannerEngine.generateDueLabel(t) == 'Today' && !PlannerEngine.isOverdue(t) && t.status != TaskStatus.completed).toList();
              final tomorrowTasks = tasks.where((t) => PlannerEngine.generateDueLabel(t) == 'Tomorrow' && t.status != TaskStatus.completed).toList();
              final upcomingTasks = tasks.where((t) => !PlannerEngine.isOverdue(t) && PlannerEngine.generateDueLabel(t) != 'Today' && PlannerEngine.generateDueLabel(t) != 'Tomorrow' && t.status != TaskStatus.completed).toList();
              final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).toList();

              return SliverList(
                delegate: SliverChildListDelegate([
                  _buildSection(context, 'Overdue', overdueTasks, subjects, Theme.of(context).colorScheme.error),
                  _buildSection(context, 'Due Today', todayTasks, subjects, Colors.orange),
                  _buildSection(context, 'Due Tomorrow', tomorrowTasks, subjects, Colors.blue),
                  _buildSection(context, 'Upcoming', upcomingTasks, subjects, Theme.of(context).colorScheme.primary),
                  _buildSection(context, 'Completed', completedTasks, subjects, Theme.of(context).colorScheme.outline),
                  
                  if (tasks.where((t) => t.status != TaskStatus.completed).isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Center(
                        child: Text(
                          "🎉 You're all caught up!",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  
                  // Bottom padding
                  const SizedBox(height: 80),
                ]),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskFormSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        tooltip: 'Add Task',
        isExtended: _isFabExtended,
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<AcademicTask> tasks, List<Subject> subjects, Color color) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '${tasks.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...tasks.map((task) {
          final subject = subjects.where((s) => s.id == task.subjectId).firstOrNull;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TaskCard(
              task: task,
              subject: subject,
              onEdit: () => showTaskFormSheet(context, taskId: task.id),
            ),
          );
        }),
      ],
    );
  }
}

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
import '../../../core/widgets/banner_ad_widget.dart';

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
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          cacheExtent: 500,
          slivers: [
            SliverAppBar(
              title: Text('Planner', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
              actions: [
                IconButton(
                  icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
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
              skipLoadingOnReload: true,
              data: (tasks) {
                final subjects = subjectsAsync.valueOrNull ?? [];

                if (tasks.isEmpty) {
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7E73FF).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.assignment_turned_in_rounded,
                                  size: 48,
                                  color: Color(0xFF7E73FF),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                ref.watch(plannerFilterProvider).isEmpty
                                    ? 'All caught up!'
                                    : 'No tasks found.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                ref.watch(plannerFilterProvider).isEmpty
                                    ? "Add a deadline when you're ready."
                                    : 'No tasks match your filters.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              if (ref.watch(plannerFilterProvider).isEmpty)
                                FilledButton.icon(
                                  onPressed: () => showTaskFormSheet(context),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Add Task'),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const BannerAdWidget(),
                      const SizedBox(height: 24),
                    ]),
                  );
                }

                final overdueTasks =
                    tasks.where(PlannerEngine.isOverdue).toList();
                final todayTasks = tasks
                    .where((t) =>
                        PlannerEngine.generateDueLabel(t) == 'Today' &&
                        !PlannerEngine.isOverdue(t) &&
                        t.status != TaskStatus.completed)
                    .toList();
                final tomorrowTasks = tasks
                    .where((t) =>
                        PlannerEngine.generateDueLabel(t) == 'Tomorrow' &&
                        t.status != TaskStatus.completed)
                    .toList();
                final upcomingTasks = tasks
                    .where((t) =>
                        !PlannerEngine.isOverdue(t) &&
                        PlannerEngine.generateDueLabel(t) != 'Today' &&
                        PlannerEngine.generateDueLabel(t) != 'Tomorrow' &&
                        t.status != TaskStatus.completed)
                    .toList();
                final completedTasks = tasks
                    .where((t) => t.status == TaskStatus.completed)
                    .toList();

                return SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSection(context, 'Overdue', overdueTasks, subjects,
                        Theme.of(context).colorScheme.error),
                    _buildSection(context, 'Due Today', todayTasks, subjects,
                        Colors.orange),
                    _buildSection(context, 'Due Tomorrow', tomorrowTasks,
                        subjects, Colors.blue),
                    _buildSection(context, 'Upcoming', upcomingTasks, subjects,
                        Theme.of(context).colorScheme.primary),
                    _buildSection(context, 'Completed', completedTasks,
                        subjects, Theme.of(context).colorScheme.outline),

                    if (tasks
                        .where((t) => t.status != TaskStatus.completed)
                        .isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Center(
                          child: Text(
                            "🎉 You're all caught up!",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ),

                    const BannerAdWidget(),
                    // Bottom padding
                    const SizedBox(height: 24),
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
    );
  }

  Widget _buildSection(BuildContext context, String title,
      List<AcademicTask> tasks, List<Subject> subjects, Color color) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
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
          final subject =
              subjects.where((s) => s.id == task.subjectId).firstOrNull;
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

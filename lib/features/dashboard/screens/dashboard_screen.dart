import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../../../navigation/app_routes.dart';
import '../../../core/enums/attendance_status.dart';
import '../../../core/extensions/attendance_status_extension.dart';
import '../../subjects/providers/subject_providers.dart';
import '../../settings/providers/semester_provider.dart';
import '../../attendance/providers/attendance_providers.dart';
import 'package:attendify/features/planner/widgets/task_card.dart';
import 'package:attendify/features/planner/screens/task_form_screen.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_state.dart';
import '../widgets/lecture_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/hero_health_card.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/next_class_card.dart';
import '../widgets/timeline_connector.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/banner_ad_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    Haptics.selection();
    ref.invalidate(dashboardNotifierProvider);
    ref.invalidate(subjectsProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateStream = ref.watch(dashboardNotifierProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final userName = user?.displayName;

    return Scaffold(
      body: stateStream.when(
        skipLoadingOnReload: true,
        data: (state) {
          if (state.isLoading) {
            return _buildSkeleton(context);
          }

          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          final pendingLectures = state.pendingLectures;
          final markedLectures = state.markedLectures;

          final pendingCount = pendingLectures.length;
          final taskCount = state.upcomingTasks.length;
          String subtitle = '';
          if (pendingCount > 0 && taskCount > 0) {
            subtitle = 'You have $pendingCount classes & $taskCount deadlines today';
          } else if (pendingCount > 0) {
            subtitle = 'You have $pendingCount classes remaining today';
          } else if (taskCount > 0) {
            subtitle = 'You have $taskCount deadlines coming up';
          } else {
            subtitle = 'You are all caught up! 🌟';
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _onRefresh(ref),
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: DashboardHeader(
                    subtitle: subtitle,
                    userName: userName ?? 'User',
                  ).animate().fade(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad),
                ),

                // Hero Attendance Health Card
                SliverToBoxAdapter(
                  child: HeroHealthCard(state: state)
                      .animate()
                      .fade(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.1, delay: 100.ms, duration: 400.ms, curve: Curves.easeOutQuad),
                ),

                if (state.patternInsight != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.surfaceContainerHigh,
                              Theme.of(context).colorScheme.surfaceContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded, color: Colors.amberAccent, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.patternInsight!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: 150.ms).slideY(begin: 0.1),
                  ),

                // Quick Stats Row
                SliverToBoxAdapter(
                  child: QuickStatsRow(quickStats: state.quickStats)
                      .animate()
                      .fade(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1, delay: 200.ms, duration: 400.ms, curve: Curves.easeOutQuad),
                ),

                // Upcoming Deadlines Section
                if (state.upcomingTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming Deadlines',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (state.upcomingTasks.length > 5)
                            TextButton(
                              onPressed: () => context.go(AppRoutes.planner),
                              child: const Text('View All â†’'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final subjectsAsync = ref.watch(subjectsProvider);
                        final subjects = subjectsAsync.valueOrNull ?? [];

                        final displayTasks =
                            state.upcomingTasks.take(5).toList();

                        return Column(
                          children: displayTasks.map((task) {
                            final subject = subjects.firstWhereOrNull(
                                (s) => s.id == task.subjectId);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 4.0),
                              child: TaskCard(
                                task: task,
                                subject: subject,
                                onEdit: () {
                                  showTaskFormSheet(context, taskId: task.id);
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],

                // Today's Schedule Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Schedule",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (pendingLectures.isNotEmpty || markedLectures.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.edit_calendar_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                            tooltip: 'Mark Full Day',
                            onPressed: () => _showMarkFullDayBottomSheet(context, ref, DateTime.now()),
                          ),
                      ],
                    ),
                  ),
                ),

                // Next Class Card (if there's a pending class)
                if (pendingLectures.isNotEmpty)
                  SliverToBoxAdapter(
                    child: NextClassCard(
                      lecture: pendingLectures.first,
                      onMarkAttendance: () {
                        _showAttendanceBottomSheet(
                            context, ref, pendingLectures.first);
                      },
                    ),
                  ),

                // Remaining Pending Classes
                if (pendingLectures.length > 1)
                  SliverToBoxAdapter(
                    child: Column(
                      children: pendingLectures.skip(1).mapIndexed((index, lecture) {
                        return TimelineConnector(
                          isLast: index == pendingLectures.length - 2 && markedLectures.isEmpty,
                          child: LectureCard(
                            key: ValueKey('pending_${lecture.schedule.id}'),
                            model: lecture,
                            onMarkAttendance: (status) {
                              ref
                                  .read(dashboardNotifierProvider.notifier)
                                  .markAttendance(
                                    lecture.schedule.id,
                                    lecture.subject.id,
                                    status,
                                  );
                            },
                          ),
                        );
                      }).toList(),
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                  ),

                if (pendingLectures.isEmpty && markedLectures.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_busy_rounded, size: 64, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                            const SizedBox(height: 16),
                            const Text(
                              'No lectures scheduled for today.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => context.go(AppRoutes.schedule),
                                  icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                                  label: const Text('Edit Timetable'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.primary,
                                    side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => context.go(AppRoutes.planner),
                                  icon: const Icon(Icons.add_task_rounded, size: 18),
                                  label: const Text('Go to Planner'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.secondary,
                                    side: BorderSide(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
                  )
                else if (pendingLectures.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.surfaceContainerHigh,
                              Theme.of(context).colorScheme.surfaceContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'All caught up for today!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Great job! You have no pending classes.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text('🎉', style: TextStyle(fontSize: 32)),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
                  ),

                // Marked Classes
                if (markedLectures.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Marked Classes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: markedLectures.mapIndexed((index, lecture) {
                        return TimelineConnector(
                          isLast: index == markedLectures.length - 1,
                          isPast: true,
                          child: LectureCard(
                            key: ValueKey('marked_${lecture.schedule.id}'),
                            model: lecture,
                            onMarkAttendance: (status) {
                              ref
                                  .read(dashboardNotifierProvider.notifier)
                                  .markAttendance(
                                    lecture.schedule.id,
                                    lecture.subject.id,
                                    status,
                                  );
                            },
                          ),
                        );
                      }).toList(),
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const SliverToBoxAdapter(
                  child: BannerAdWidget(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
          );
        },
        loading: () => _buildSkeleton(context),
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }

  void _showAttendanceBottomSheet(
      BuildContext context, WidgetRef ref, LectureCardModel lecture) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Mark Attendance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                lecture.subject.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: AttendanceStatus.values
                    .where((s) => s != AttendanceStatus.pending)
                    .map((status) {
                  return _buildQuickMarkButton(
                    context,
                    status.displayName,
                    status.icon,
                    status.color,
                    () {
                      ref
                          .read(dashboardNotifierProvider.notifier)
                          .markAttendance(
                            lecture.schedule.id,
                            lecture.subject.id,
                            status,
                          );
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickMarkButton(BuildContext context, String label,
      IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkFullDayBottomSheet(BuildContext context, WidgetRef ref, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Mark Entire Day',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickMarkButton(
                    context,
                    'GT',
                    Icons.stars_rounded,
                    Colors.purple,
                    () async {
                      final semester = ref.read(semesterStateProvider);
                      if (semester != null) {
                        await ref
                            .read(attendanceRepositoryProvider)
                            .markFullDayStatus(date, semester.id, AttendanceStatus.gt);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Marked entire day as GT'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                  _buildQuickMarkButton(
                    context,
                    'MEDICAL',
                    Icons.local_hospital_rounded,
                    Colors.orange,
                    () async {
                      final semester = ref.read(semesterStateProvider);
                      if (semester != null) {
                        await ref
                            .read(attendanceRepositoryProvider)
                            .markFullDayStatus(date, semester.id, AttendanceStatus.medical);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Marked entire day as Medical'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                  _buildQuickMarkButton(
                    context,
                    'HOLIDAY',
                    Icons.beach_access_rounded,
                    Theme.of(context).colorScheme.primary,
                    () async {
                      final semester = ref.read(semesterStateProvider);
                      if (semester != null) {
                        await ref
                            .read(attendanceRepositoryProvider)
                            .markFullDayStatus(date, semester.id, AttendanceStatus.holiday);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Marked entire day as Holiday'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                  _buildQuickMarkButton(
                    context,
                    'CLEAR ALL',
                    Icons.clear_all_rounded,
                    Colors.redAccent,
                    () async {
                      if (context.mounted) Navigator.pop(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                          title: Text('Clear Today\'s Attendance?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          content: Text(
                            'This will erase all attendance entries marked for this day.',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final semester = ref.read(semesterStateProvider);
                        if (semester != null) {
                          await ref
                              .read(attendanceRepositoryProvider)
                              .deleteAttendancesByDate(date, semester.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cleared today\'s attendance'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            highlightColor: Theme.of(context).colorScheme.surface,
            child: Container(
              height: 32,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              highlightColor: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

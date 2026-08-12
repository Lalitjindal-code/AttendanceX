import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/attendance_status.dart';
import '../models/calendar_state.dart';
import '../../settings/providers/semester_provider.dart';
import '../../attendance/providers/attendance_providers.dart';
import 'daily_attendance_card.dart';
import '../../planner/widgets/task_card.dart';

class DayDetailPanel extends ConsumerWidget {
  final CalendarState state;

  const DayDetailPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.selectedDayDetails.items.isEmpty &&
        state.selectedDayTasks.isEmpty) {
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No classes or tasks scheduled for',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                Text(
                  DateFormat('MMMM d, yyyy').format(state.selectedDate),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
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
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Logic to interleave titles and lists if necessary
            // For simplicity, we just rebuild a linear list of widgets
            final children = <Widget>[];

            if (state.selectedDayDetails.items.isNotEmpty) {
              children.add(
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppSpacing.sm, left: AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Classes',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showMarkFullDayBottomSheet(
                            context, ref, state.selectedDate),
                        icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                        label: const Text('Mark Day'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              );
              children.addAll(
                state.selectedDayDetails.items.map(
                  (item) =>
                      DailyAttendanceCard(item: item, date: state.selectedDate),
                ),
              );
              children.add(const SizedBox(height: AppSpacing.lg));
            }

            if (state.selectedDayTasks.isNotEmpty) {
              children.add(
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppSpacing.sm, left: AppSpacing.xs),
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
                  final subject = state.allSubjects
                      .where((s) => s.id == task.subjectId)
                      .firstOrNull;
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
          childCount: (state.selectedDayDetails.items.isNotEmpty
                  ? state.selectedDayDetails.items.length + 2
                  : 0) +
              (state.selectedDayTasks.isNotEmpty
                  ? state.selectedDayTasks.length + 1
                  : 0),
        ),
      ),
    );
  }

  void _showMarkFullDayBottomSheet(
      BuildContext context, WidgetRef ref, DateTime date) {
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
                            .markFullDayStatus(
                                date, semester.id, AttendanceStatus.gt);
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
                            .markFullDayStatus(
                                date, semester.id, AttendanceStatus.medical);
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
                            .markFullDayStatus(
                                date, semester.id, AttendanceStatus.holiday);
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
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          title: Text('Clear Today\'s Attendance?',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                          content: Text(
                            'This will erase all attendance entries marked for this day.',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Clear',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error)),
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
}

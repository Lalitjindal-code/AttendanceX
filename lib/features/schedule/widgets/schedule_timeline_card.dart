import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/attendance_status.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../../../core/utils/haptics.dart';

class ScheduleTimelineCard extends ConsumerWidget {
  final Schedule schedule;
  final Subject subject;
  final VoidCallback onEdit;
  final bool isFirst;
  final bool isLast;

  const ScheduleTimelineCard({
    super.key,
    required this.schedule,
    required this.subject,
    required this.onEdit,
    this.isFirst = false,
    this.isLast = false,
  });

  void _markAttendance(WidgetRef ref, AttendanceStatus status) {
    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);

    // We only allow marking for today from the schedule view for quick action
    if (now.weekday != schedule.dayOfWeek) {
      // It's not today. We probably shouldn't allow marking attendance for future/past days here easily
      // without a date picker. But for simplicity, we could assume 'today'.
      // However, usually timetable only shows quick mark for today.
    }

    final attendance = Attendance()
      ..semesterId = schedule.semesterId
      ..scheduleId = schedule.id
      ..subjectId = subject.id
      ..date = todayUtc
      ..status = status;

    ref.read(attendanceRepositoryProvider).upsertAttendance(attendance);
    Haptics.light();
  }

  void _markPresentWithFeedback(BuildContext context, WidgetRef ref) {
    _markAttendance(ref, AttendanceStatus.present);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked Present for ${subject.name}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markAbsentWithFeedback(BuildContext context, WidgetRef ref) {
    _markAttendance(ref, AttendanceStatus.absent);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked Absent for ${subject.name}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectColor = Color(subject.colorValue);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time column
          SizedBox(
            width: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  schedule.startTime,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  schedule.endTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Timeline indicator
          Column(
            children: [
              Container(
                width: 2,
                height: 16,
                color: isFirst
                    ? Colors.transparent
                    : subjectColor.withValues(alpha: 0.3),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: subjectColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0B0B13),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: subjectColor.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : subjectColor.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          const SizedBox(width: AppSpacing.md),

          // Card content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Dismissible(
                key: ValueKey('schedule_${schedule.id}'),
                direction: DateTime.now().weekday == schedule.dayOfWeek
                    ? DismissDirection.horizontal
                    : DismissDirection.none,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    _markPresentWithFeedback(context, ref);
                  } else {
                    _markAbsentWithFeedback(context, ref);
                  }
                  return false; // Don't actually dismiss the widget
                },
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: const Icon(Icons.check_circle,
                      color: Colors.white, size: 32),
                ),
                secondaryBackground: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1744).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child:
                      const Icon(Icons.cancel, color: Colors.white, size: 32),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16162C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: subjectColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    schedule.type.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: subjectColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            if (schedule.room != null ||
                                schedule.facultyOverride != null) ...[
                              Row(
                                children: [
                                  if (schedule.room != null) ...[
                                    Icon(Icons.location_on_outlined,
                                        size: 14,
                                        color: Colors.white.withValues(alpha: 0.5)),
                                    const SizedBox(width: 4),
                                    Text(schedule.room!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7))),
                                    const SizedBox(width: AppSpacing.sm),
                                  ],
                                  if (schedule.facultyOverride != null) ...[
                                    Icon(Icons.person_outline,
                                        size: 14,
                                        color: Colors.white.withValues(alpha: 0.5)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        schedule.facultyOverride!,
                                        style:
                                            Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

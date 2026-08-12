import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/attendance_status.dart';
import '../../../core/utils/haptics.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../../settings/providers/semester_provider.dart';
import '../models/daily_attendance_item.dart';

class DailyAttendanceCard extends ConsumerWidget {
  final DailyAttendanceItem item;
  final DateTime date;

  const DailyAttendanceCard({
    super.key,
    required this.item,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subjectColor = Color(item.subject.colorValue);

    Color statusColor;
    switch (item.status) {
      case AttendanceStatus.present:
        statusColor = Colors.green;
        break;
      case AttendanceStatus.absent:
        statusColor = Colors.red;
        break;
      case AttendanceStatus.medical:
        statusColor = Colors.orange;
        break;
      case AttendanceStatus.holiday:
        statusColor = colorScheme.primary;
        break;
      case AttendanceStatus.gt:
        statusColor = Colors.purple;
        break;
      default:
        statusColor = colorScheme.outlineVariant;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.status != null
              ? statusColor.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditSheet(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Glowing Color indicator bar on the left
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: subjectColor,
                    boxShadow: [
                      BoxShadow(
                        color: subjectColor.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.subject.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              if (item.schedule != null)
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 14,
                                        color: theme.colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.schedule!.startTime} - ${item.schedule!.endTime}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        size: 14,
                                        color: theme.colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Manual Attendance',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.status != null
                                ? statusColor.withValues(alpha: 0.15)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status?.name.toUpperCase() ?? 'PENDING',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: item.status != null
                                  ? statusColor
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(
                      top: AppSpacing.sm, bottom: AppSpacing.md),
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Update Attendance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  children: AttendanceStatus.values.map((status) {
                    final isSelected = item.status == status;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        selected: isSelected,
                        selectedTileColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        title: Text(
                          status.name.toUpperCase(),
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected ? const Icon(Icons.check) : null,
                        onTap: () {
                          _updateAttendance(ref, status);
                          Haptics.light();
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).cast<Widget>().toList()..add(
                    // Add a delete/clear option if an attendance record exists
                    item.attendance != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              title: const Text(
                                'Remove Attendance',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              onTap: () {
                                final repo = ref.read(attendanceRepositoryProvider);
                                repo.delete(item.attendance!.id);
                                Haptics.heavy();
                                Navigator.pop(context);
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateAttendance(WidgetRef ref, AttendanceStatus newStatus) {
    final repo = ref.read(attendanceRepositoryProvider);
    final semester = ref.read(semesterStateProvider);
    if (semester == null) return;
    
    final att = item.attendance ?? Attendance()
      ..semesterId = semester.id
      ..subjectId = item.subject.id
      ..scheduleId = item.schedule?.id
      ..date = DateTime(date.year, date.month, date.day);

    att.status = newStatus;

    // Perform background update
    repo.upsertAttendance(att);
  }
}

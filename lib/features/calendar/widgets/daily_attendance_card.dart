import 'package:attendancex/core/enums/attendance_status.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/features/attendance/providers/attendance_providers.dart';
import 'package:attendancex/features/calendar/models/daily_attendance_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    final isPresent = item.status == AttendanceStatus.present;
    final isAbsent = item.status == AttendanceStatus.absent;
    final isMedical = item.status == AttendanceStatus.medical;
    final isHoliday = item.status == AttendanceStatus.holiday;

    Color statusColor;
    if (isPresent) {
      statusColor = Colors.green;
    } else if (isAbsent) {
      statusColor = Colors.red;
    } else if (isMedical) {
      statusColor = Colors.orange;
    } else if (isHoliday) {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.status != null ? statusColor.withValues(alpha: 0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEditDialog(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.schedule != null)
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${item.schedule!.startTime} - ${item.schedule!.endTime}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (item.schedule!.room != null && item.schedule!.room!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.location_on_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              item.schedule!.room!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            'Manual Attendance',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: item.status != null ? statusColor.withValues(alpha: 0.1) : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status?.name.toUpperCase() ?? 'PENDING',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: item.status != null ? statusColor : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AttendanceStatus.values.map((status) {
              return ListTile(
                title: Text(status.name.toUpperCase()),
                trailing: item.status == status ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  _updateAttendance(ref, status);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _updateAttendance(WidgetRef ref, AttendanceStatus newStatus) {
    final repo = ref.read(attendanceRepositoryProvider);
    final att = item.attendance ?? Attendance()
      ..subjectId = item.subject.id
      ..scheduleId = item.schedule?.id ?? -1
      ..date = DateTime(date.year, date.month, date.day);
    
    att.status = newStatus;
    
    // Perform background update
    repo.upsertAttendance(att);
  }
}

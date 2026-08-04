import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/enums/attendance_status.dart';
import '../../../core/extensions/attendance_status_extension.dart';
import '../models/dashboard_state.dart';

class EditAttendanceBottomSheet extends StatelessWidget {
  final LectureCardModel model;
  final void Function(AttendanceStatus) onStatusSelected;

  const EditAttendanceBottomSheet({
    super.key,
    required this.model,
    required this.onStatusSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required LectureCardModel model,
    required void Function(AttendanceStatus) onStatusSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditAttendanceBottomSheet(
        model: model,
        onStatusSelected: onStatusSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = model.attendance?.status;
    final subject = model.subject;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Attendance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${subject.name} â€¢ ${model.schedule.startTime}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AttendanceStatus.values
                  .where((status) => status != AttendanceStatus.pending)
                  .map((status) =>
                      _buildStatusButton(context, status, currentStatus))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, AttendanceStatus status,
      AttendanceStatus? currentStatus) {
    final isSelected = currentStatus == status;
    final color = status.color;

    return ActionChip(
      label: Text(status.displayName),
      avatar:
          Icon(status.icon, size: 18, color: isSelected ? Colors.white : color),
      backgroundColor: isSelected ? color : color.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(
        color: isSelected ? Colors.transparent : color.withValues(alpha: 0.5),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        onStatusSelected(status);
        Navigator.of(context).pop();
      },
    );
  }
}

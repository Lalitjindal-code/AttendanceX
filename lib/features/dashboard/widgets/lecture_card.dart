import 'package:flutter/material.dart';
import '../../../core/enums/attendance_status.dart';
import '../../../core/extensions/attendance_status_extension.dart';
import '../../../core/utils/haptics.dart';
import '../models/dashboard_state.dart';
import 'edit_attendance_bottom_sheet.dart';

class LectureCard extends StatelessWidget {
  final LectureCardModel model;
  final void Function(AttendanceStatus status) onMarkAttendance;

  const LectureCard({
    super.key,
    required this.model,
    required this.onMarkAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final subject = model.subject;
    final attendance = model.attendance;
    final subjectColor = Color(subject.colorValue);

    final status = attendance?.status ?? AttendanceStatus.pending;
    final isMarked = status != AttendanceStatus.pending;

    // Use subject color for pending, but use the specific status color for marked.
    final accentColor = isMarked ? status.color : subjectColor;

    return Semantics(
      label: isMarked
          ? '${subject.name} attendance marked ${status.displayName}. Double tap to edit attendance.'
          : '${subject.name} pending attendance. Double tap to mark.',
      child: Dismissible(
        key: ValueKey(
            'lecture_${model.schedule.id}_${model.attendance?.id ?? "pending"}'),
        direction:
            isMarked ? DismissDirection.none : DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onMarkAttendance(AttendanceStatus.present);
          } else {
            onMarkAttendance(AttendanceStatus.absent);
          }
          Haptics.light();
          return false;
        },
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.cancel, color: Colors.white, size: 32),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMarked
                  ? accentColor.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: isMarked ? 1.5 : 0,
            ),
            boxShadow: isMarked
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: accentColor, width: 4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isMarked
                      ? _buildMarkedContent(context, accentColor, status)
                      : _buildPendingContent(context, accentColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingContent(BuildContext context, Color accentColor) {
    return Column(
      key: const ValueKey('pending'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, accentColor),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AttendanceStatus.values
              .where((s) => s != AttendanceStatus.pending)
              .map((s) => _buildActionButton(context, s, null))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMarkedContent(
      BuildContext context, Color accentColor, AttendanceStatus status) {
    return Column(
      key: const ValueKey('marked'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check, color: accentColor, size: 16),
            const SizedBox(width: 4),
            Text(
              'MARKED',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildHeader(context, accentColor),
        const SizedBox(height: 12),
        Text(
          'Status:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(status.icon, color: accentColor, size: 16),
            const SizedBox(width: 8),
            Text(
              status.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              EditAttendanceBottomSheet.show(
                context,
                model: model,
                onStatusSelected: onMarkAttendance,
              );
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Attendance'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Color accentColor) {
    final schedule = model.schedule;
    final subject = model.subject;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                subject.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${schedule.startTime} - ${schedule.endTime}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              schedule.type.name.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (schedule.room != null)
              Text(
                'Room: ${schedule.room}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Faculty: ${subject.facultyName}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, AttendanceStatus status,
      AttendanceStatus? currentStatus) {
    final isSelected = currentStatus == status;
    final color = status.color;

    return ChoiceChip(
      label: Text(status.displayName),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.onPrimary : color,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(
          color:
              isSelected ? Colors.transparent : color.withValues(alpha: 0.5)),
      onSelected: (selected) {
        if (!isSelected) {
          onMarkAttendance(status);
          Haptics.light();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/enums/attendance_status.dart';
import '../models/dashboard_state.dart';

class LectureCard extends StatefulWidget {
  final LectureCardModel model;
  final void Function(AttendanceStatus status) onMarkAttendance;

  const LectureCard({
    super.key,
    required this.model,
    required this.onMarkAttendance,
  });

  @override
  State<LectureCard> createState() => _LectureCardState();
}

class _LectureCardState extends State<LectureCard> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final schedule = widget.model.schedule;
    final subject = widget.model.subject;
    final attendance = widget.model.attendance;
    final color = Color(subject.colorValue);

    final isMarked = attendance != null && attendance.status != AttendanceStatus.pending;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                          color: color,
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
              const SizedBox(height: 16),
              
              if (isMarked && !_isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(attendance.status),
                          color: _getStatusColor(attendance.status),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Marked: ${attendance.status.name.toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(attendance.status),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                  ],
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionButton(context, 'Present', AttendanceStatus.present, Colors.green),
                    _buildActionButton(context, 'Absent', AttendanceStatus.absent, Colors.red),
                    _buildActionButton(context, 'Medical', AttendanceStatus.medical, Colors.orange),
                    _buildActionButton(context, 'GT', AttendanceStatus.gt, Colors.purple),
                    _buildActionButton(context, 'Holiday', AttendanceStatus.holiday, Colors.blue),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, AttendanceStatus status, Color color) {
    return ActionChip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      side: BorderSide(color: color.withOpacity(0.5)),
      onPressed: () {
        setState(() => _isEditing = false);
        widget.onMarkAttendance(status);
      },
    );
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present: return Icons.check_circle;
      case AttendanceStatus.absent: return Icons.cancel;
      case AttendanceStatus.medical: return Icons.local_hospital;
      case AttendanceStatus.gt: return Icons.directions_walk;
      case AttendanceStatus.holiday: return Icons.celebration;
      case AttendanceStatus.pending: return Icons.help_outline;
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present: return Colors.green;
      case AttendanceStatus.absent: return Colors.red;
      case AttendanceStatus.medical: return Colors.orange;
      case AttendanceStatus.gt: return Colors.purple;
      case AttendanceStatus.holiday: return Colors.blue;
      case AttendanceStatus.pending: return Colors.grey;
    }
  }
}

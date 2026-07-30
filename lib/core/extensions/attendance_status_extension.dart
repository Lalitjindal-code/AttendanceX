import 'package:flutter/material.dart';
import '../enums/attendance_status.dart';

extension AttendanceStatusUI on AttendanceStatus {
  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.medical:
        return Colors.orange;
      case AttendanceStatus.gt:
        return Colors.blue;
      case AttendanceStatus.holiday:
        return Colors.purple;
      case AttendanceStatus.pending:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.medical:
        return Icons.local_hospital;
      case AttendanceStatus.gt:
        return Icons.directions_walk;
      case AttendanceStatus.holiday:
        return Icons.celebration;
      case AttendanceStatus.pending:
        return Icons.help_outline;
    }
  }

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.medical:
        return 'Medical';
      case AttendanceStatus.gt:
        return 'GT';
      case AttendanceStatus.holiday:
        return 'Holiday';
      case AttendanceStatus.pending:
        return 'Pending';
    }
  }
}

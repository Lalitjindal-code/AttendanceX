import 'package:attendify/core/enums/attendance_status.dart';
import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';

class DailyAttendanceItem {
  final Subject subject;
  final Schedule? schedule;
  final Attendance? attendance;
  final bool isManual; // Marked without a scheduled lecture

  const DailyAttendanceItem({
    required this.subject,
    this.schedule,
    this.attendance,
    this.isManual = false,
  });

  AttendanceStatus? get status => attendance?.status;

  // Sorting logic:
  // 1. Start time (ascending)
  // 2. Subject name
  int compareTo(DailyAttendanceItem other) {
    if (schedule != null && other.schedule != null) {
      final t1 = _timeToMinutes(schedule!.startTime);
      final t2 = _timeToMinutes(other.schedule!.startTime);
      if (t1 != t2) {
        return t1.compareTo(t2);
      }
    } else if (schedule != null && other.schedule == null) {
      return -1; // Schedules come before manual items
    } else if (schedule == null && other.schedule != null) {
      return 1;
    }
    return subject.name.compareTo(other.subject.name);
  }

  int _timeToMinutes(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return 0;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return h * 60 + m;
    } catch (_) {
      return 0;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DailyAttendanceItem &&
        other.subject.id == subject.id &&
        other.schedule?.id == schedule?.id &&
        other.attendance?.id == attendance?.id &&
        other.isManual == isManual;
  }

  @override
  int get hashCode {
    return subject.id.hashCode ^
        (schedule?.id).hashCode ^
        (attendance?.id).hashCode ^
        isManual.hashCode;
  }
}

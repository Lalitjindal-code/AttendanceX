import 'package:isar/isar.dart';
import '../core/errors/app_exception.dart';
import '../database/collections/schedule_collection.dart';

/// Pure business logic engine for Schedule validation and conflict detection.
class ScheduleEngine {
  /// Converts an "HH:mm" time string to minutes since midnight for easy comparison.
  static int timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) {
      throw const ValidationException('Invalid time format. Expected HH:mm');
    }
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    
    if (hours == null || minutes == null) {
      throw const ValidationException('Invalid time format. Expected numeric HH:mm');
    }
    
    return hours * 60 + minutes;
  }

  /// Validates that endTime is strictly after startTime.
  static void validateTimeRange(String startTime, String endTime) {
    final startMins = timeToMinutes(startTime);
    final endMins = timeToMinutes(endTime);

    if (endMins <= startMins) {
      throw const ValidationException('End time must be after start time.');
    }
  }

  /// Checks if a [newSchedule] overlaps with any [existingSchedules].
  ///
  /// Ignores the schedule with the same ID (for editing).
  static void checkForConflicts(Schedule newSchedule, List<Schedule> existingSchedules) {
    final newStart = timeToMinutes(newSchedule.startTime);
    final newEnd = timeToMinutes(newSchedule.endTime);

    for (final existing in existingSchedules) {
      // Skip self when editing
      if (newSchedule.id != Isar.autoIncrement && existing.id == newSchedule.id) {
        continue;
      }

      final existingStart = timeToMinutes(existing.startTime);
      final existingEnd = timeToMinutes(existing.endTime);

      // Overlap condition: StartA < EndB AND EndA > StartB
      if (newStart < existingEnd && newEnd > existingStart) {
        throw const TimeConflictException(
            'This schedule conflicts with an existing lecture.');
      }
    }
  }
}

import 'package:attendancex/core/errors/app_exception.dart';
import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/engines/schedule_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScheduleEngine time format validation', () {
    test('throws ValidationException for invalid format', () {
      expect(() => ScheduleEngine.timeToMinutes('900'),
          throwsA(isA<ValidationException>()));
      expect(() => ScheduleEngine.timeToMinutes('09-00'),
          throwsA(isA<ValidationException>()));
      expect(() => ScheduleEngine.timeToMinutes('aa:bb'),
          throwsA(isA<ValidationException>()));
    });

    test('correctly parses HH:mm', () {
      expect(ScheduleEngine.timeToMinutes('00:00'), 0);
      expect(ScheduleEngine.timeToMinutes('09:30'), 570);
      expect(ScheduleEngine.timeToMinutes('23:59'), 1439);
    });
  });

  group('ScheduleEngine.validateTimeRange', () {
    test('throws ValidationException when endTime is before startTime', () {
      expect(() => ScheduleEngine.validateTimeRange('10:00', '09:00'),
          throwsA(isA<ValidationException>()));
    });

    test('throws ValidationException when endTime is equal to startTime', () {
      expect(() => ScheduleEngine.validateTimeRange('10:00', '10:00'),
          throwsA(isA<ValidationException>()));
    });

    test('returns normally for valid time range', () {
      expect(() => ScheduleEngine.validateTimeRange('09:00', '10:00'),
          returnsNormally);
    });
  });

  group('ScheduleEngine.checkForConflicts', () {
    late List<Schedule> existingSchedules;

    setUp(() {
      existingSchedules = [
        Schedule()
          ..id = 1
          ..startTime = '09:00'
          ..endTime = '10:00',
        Schedule()
          ..id = 2
          ..startTime = '11:00'
          ..endTime = '12:00',
      ];
    });

    test('passes for adjacent lectures', () {
      final newSchedule = Schedule()
        ..startTime = '10:00'
        ..endTime = '11:00';

      expect(
          () =>
              ScheduleEngine.checkForConflicts(newSchedule, existingSchedules),
          returnsNormally);
    });

    test('throws for exact overlap', () {
      final newSchedule = Schedule()
        ..startTime = '09:00'
        ..endTime = '10:00';

      expect(
          () =>
              ScheduleEngine.checkForConflicts(newSchedule, existingSchedules),
          throwsA(isA<TimeConflictException>()));
    });

    test('throws for partial overlap (starts during)', () {
      final newSchedule = Schedule()
        ..startTime = '09:30'
        ..endTime = '10:30';

      expect(
          () =>
              ScheduleEngine.checkForConflicts(newSchedule, existingSchedules),
          throwsA(isA<TimeConflictException>()));
    });

    test('throws for partial overlap (ends during)', () {
      final newSchedule = Schedule()
        ..startTime = '08:30'
        ..endTime = '09:30';

      expect(
          () =>
              ScheduleEngine.checkForConflicts(newSchedule, existingSchedules),
          throwsA(isA<TimeConflictException>()));
    });

    test('throws for complete containment', () {
      final newSchedule = Schedule()
        ..startTime = '08:00'
        ..endTime = '10:30';

      expect(
          () =>
              ScheduleEngine.checkForConflicts(newSchedule, existingSchedules),
          throwsA(isA<TimeConflictException>()));
    });

    test('self-edit conflict exclusion', () {
      final editingSchedule = Schedule()
        ..id = 1 // Same ID as existing
        ..startTime = '09:00'
        ..endTime = '10:00';

      expect(
          () => ScheduleEngine.checkForConflicts(
              editingSchedule, existingSchedules),
          returnsNormally);
    });
  });
}

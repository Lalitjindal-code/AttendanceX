import 'package:attendancex/engines/attendance_engine.dart';
import 'package:attendancex/features/dashboard/models/smart_suggestion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Smart Suggestions Math', () {
    test('no data returns noData type', () {
      final suggestion = AttendanceEngine.calculateSmartSuggestion(
        effectivePresent: 0,
        effectiveTotal: 0,
        goalPercentage: 75.0,
      );

      expect(suggestion.type, SmartSuggestionType.noData);
      expect(suggestion.classes, 0);
    });

    test('0% goal always returns onTrack', () {
      final suggestion = AttendanceEngine.calculateSmartSuggestion(
        effectivePresent: 0,
        effectiveTotal: 10,
        goalPercentage: 0.0,
      );

      expect(suggestion.type, SmartSuggestionType.onTrack);
      expect(suggestion.classes, 0);
    });

    test('exactly on track returns onTrack', () {
      final suggestion = AttendanceEngine.calculateSmartSuggestion(
        effectivePresent: 75,
        effectiveTotal: 100,
        goalPercentage: 75.0,
      );

      expect(suggestion.type, SmartSuggestionType.onTrack);
      expect(suggestion.classes, 0); // 75/0.75 - 100 = 100 - 100 = 0
    });

    test('safe bunks calculated correctly (floor)', () {
      final suggestion = AttendanceEngine.calculateSmartSuggestion(
        effectivePresent: 80,
        effectiveTotal: 100,
        goalPercentage: 75.0,
      );

      // (80 / 0.75) - 100 = 106.666 - 100 = 6.666 -> floor = 6
      expect(suggestion.type, SmartSuggestionType.safeBunk);
      expect(suggestion.classes, 6);
    });

    test('required classes calculated correctly (ceil)', () {
      final suggestion = AttendanceEngine.calculateSmartSuggestion(
        effectivePresent: 50,
        effectiveTotal: 100,
        goalPercentage: 75.0,
      );

      // (0.75 * 100 - 50) / (1 - 0.75) = (75 - 50) / 0.25 = 25 / 0.25 = 100
      expect(suggestion.type, SmartSuggestionType.attendMore);
      expect(suggestion.classes, 100);
    });

    test('impossible to reach 100%', () {
      final suggestion = AttendanceEngine.calculateSmartSuggestion(
        effectivePresent: 99,
        effectiveTotal: 100,
        goalPercentage: 100.0,
      );

      expect(suggestion.type, SmartSuggestionType.attendMore);
      expect(suggestion.classes, -1);
    });
  });
}

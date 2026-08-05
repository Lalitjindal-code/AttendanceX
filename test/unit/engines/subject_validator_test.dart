import 'package:attendify/engines/subject_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubjectValidator Normalization', () {
    test('normalizes complex strings correctly', () {
      expect(SubjectValidator.normalizeName('  DATA   STRUCTURES  '),
          'DATA STRUCTURES');
      expect(SubjectValidator.normalizeName('Math'), 'Math');
    });
  });

  group('SubjectValidator.validateName', () {
    test('returns error when null or empty', () {
      expect(SubjectValidator.validateName(null), 'Subject name is required');
      expect(SubjectValidator.validateName('   '), 'Subject name is required');
    });

    test('returns error when name exceeds 60 characters', () {
      final longName = 'A' * 61;
      expect(SubjectValidator.validateName(longName),
          'Subject name cannot exceed 60 characters');
    });

    test('returns null when valid', () {
      expect(SubjectValidator.validateName('Data Structures'), isNull);
    });
  });

  group('SubjectValidator.validateCredits', () {
    test('returns error when null or empty', () {
      expect(SubjectValidator.validateCredits(null), 'Credits are required');
      expect(SubjectValidator.validateCredits(''), 'Credits are required');
    });

    test('returns error when non-numeric', () {
      expect(SubjectValidator.validateCredits('abc'), 'Enter a valid number');
    });

    test('returns error when out of bounds', () {
      expect(SubjectValidator.validateCredits('0'),
          'Credits must be between 1 and 10');
      expect(SubjectValidator.validateCredits('11'),
          'Credits must be between 1 and 10');
    });

    test('returns null when valid', () {
      expect(SubjectValidator.validateCredits('3'), isNull);
      expect(SubjectValidator.validateCredits(' 10 '), isNull);
    });
  });

  group('SubjectValidator.validateGoal', () {
    test('returns error when null or empty', () {
      expect(
          SubjectValidator.validateGoal(null), 'Goal percentage is required');
    });

    test('returns error when non-numeric', () {
      expect(SubjectValidator.validateGoal('abc'), 'Enter a valid percentage');
    });

    test('returns error when out of bounds', () {
      expect(SubjectValidator.validateGoal('0.9'),
          'Goal must be between 1 and 100');
      expect(SubjectValidator.validateGoal('100.1'),
          'Goal must be between 1 and 100');
    });

    test('returns null when valid', () {
      expect(SubjectValidator.validateGoal('75.0'), isNull);
    });
  });
}

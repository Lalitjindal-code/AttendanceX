/// Represents the type of exam for an attendance slot or day.
enum ExamType {
  /// Mid Semester Examination 1
  midSem1,

  /// Mid Semester Examination 2
  midSem2,

  /// End Semester Examination
  endSem,

  /// Practical / Lab Examination
  practicalExam;

  /// User-facing display title
  String get displayName {
    switch (this) {
      case ExamType.midSem1:
        return 'Mid Sem 1';
      case ExamType.midSem2:
        return 'Mid Sem 2';
      case ExamType.endSem:
        return 'End Sem';
      case ExamType.practicalExam:
        return 'Practical Exam';
    }
  }

  /// Short badge title
  String get shortName {
    switch (this) {
      case ExamType.midSem1:
        return 'Mid 1';
      case ExamType.midSem2:
        return 'Mid 2';
      case ExamType.endSem:
        return 'End Sem';
      case ExamType.practicalExam:
        return 'Practical';
    }
  }
}

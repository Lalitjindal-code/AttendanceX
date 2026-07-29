/// Pure business logic engine for Subject validation.
///
/// Ensures inputs meet the application's rules before hitting the repository layer.
class SubjectValidator {
  /// Normalizes a subject name by trimming leading/trailing whitespace
  /// and collapsing multiple inner spaces into a single space.
  ///
  /// Example: `"  DATA    STRUCTURES "` -> `"DATA STRUCTURES"`
  static String normalizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Validates the subject name.
  /// Returns an error string if invalid, or null if valid.
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Subject name is required';
    }
    final normalized = normalizeName(name);
    if (normalized.length > 60) {
      return 'Subject name cannot exceed 60 characters';
    }
    return null;
  }

  /// Validates subject credits (must be between 1 and 10).
  static String? validateCredits(String? creditsStr) {
    if (creditsStr == null || creditsStr.trim().isEmpty) {
      return 'Credits are required';
    }
    final credits = int.tryParse(creditsStr.trim());
    if (credits == null) {
      return 'Enter a valid number';
    }
    if (credits < 1 || credits > 10) {
      return 'Credits must be between 1 and 10';
    }
    return null;
  }

  /// Validates the subject goal percentage (must be between 1.0 and 100.0).
  static String? validateGoal(String? goalStr) {
    if (goalStr == null || goalStr.trim().isEmpty) {
      return 'Goal percentage is required';
    }
    final goal = double.tryParse(goalStr.trim());
    if (goal == null) {
      return 'Enter a valid percentage';
    }
    if (goal < 1.0 || goal > 100.0) {
      return 'Goal must be between 1 and 100';
    }
    return null;
  }

  /// Validates the subject notes (must not exceed 300 characters).
  static String? validateNotes(String? notes) {
    if (notes != null && notes.trim().length > 300) {
      return 'Notes cannot exceed 300 characters';
    }
    return null;
  }
}

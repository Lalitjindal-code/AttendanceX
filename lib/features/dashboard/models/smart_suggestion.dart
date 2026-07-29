enum SmartSuggestionType {
  safeBunk,
  attendMore,
  onTrack,
  noData,
}

class SmartSuggestion {
  final SmartSuggestionType type;
  final int? subjectId; // Optional, null if it's an overall suggestion
  final int classes;
  final String message;

  const SmartSuggestion({
    required this.type,
    this.subjectId,
    required this.classes,
    required this.message,
  });
}

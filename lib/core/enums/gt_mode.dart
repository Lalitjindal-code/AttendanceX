/// Controls how GT (Granted Leave) attendance is calculated.
///
/// Stored in [SharedPreferences] as a [String] key via [key].
/// The default is [GtMode.exclude] — GT is fully ignored, identical to Holiday.
enum GtMode {
  /// GT is fully excluded from attendance calculation — identical to Holiday.
  ///
  /// Present unchanged, Total unchanged. This is the **default**.
  exclude('exclude'),

  /// GT is counted as a Present class.
  ///
  /// Present++, Total++. Attendance percentage improves slightly.
  countAsPresent('count_as_present'),

  /// GT is counted as an Absent class.
  ///
  /// Total++, Present unchanged. Attendance percentage decreases.
  countAsAbsent('count_as_absent');

  const GtMode(this.key);

  /// The [SharedPreferences] storage key for this mode.
  final String key;

  /// Returns the [GtMode] matching the given [key].
  ///
  /// Falls back to [GtMode.exclude] if no match is found.
  static GtMode fromKey(String key) {
    return GtMode.values.firstWhere(
      (mode) => mode.key == key,
      orElse: () => GtMode.exclude,
    );
  }

  /// Short display label for use in settings UI.
  String get label {
    return switch (this) {
      GtMode.exclude => 'Exclude from Attendance',
      GtMode.countAsPresent => 'Count as Present',
      GtMode.countAsAbsent => 'Count as Absent',
    };
  }

  /// Descriptive subtitle for the settings UI.
  String get description {
    return switch (this) {
      GtMode.exclude =>
        'GT classes are ignored in calculation, like holidays. (Default)',
      GtMode.countAsPresent =>
        'GT classes count as attended. Attendance improves slightly.',
      GtMode.countAsAbsent =>
        'GT classes count against your attendance.',
    };
  }
}

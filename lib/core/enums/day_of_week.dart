/// Represents a day of the week, mapped to Dart's [DateTime.weekday] values.
///
/// Monday = 1, Sunday = 7 — identical to [DateTime.monday] through [DateTime.sunday].
enum DayOfWeek {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const DayOfWeek(this.value);

  /// Only Monday through Friday
  static const List<DayOfWeek> weekdays = [
    DayOfWeek.monday,
    DayOfWeek.tuesday,
    DayOfWeek.wednesday,
    DayOfWeek.thursday,
    DayOfWeek.friday,
  ];

  /// Integer value matching [DateTime.weekday].
  final int value;

  /// Returns the [DayOfWeek] for the given [DateTime.weekday] integer.
  ///
  /// Falls back to [DayOfWeek.monday] for any out-of-range value.
  static DayOfWeek fromInt(int weekday) {
    return DayOfWeek.values.firstWhere(
      (day) => day.value == weekday,
      orElse: () => DayOfWeek.monday,
    );
  }

  /// Abbreviated display label (e.g., "Mon").
  String get shortLabel {
    return switch (this) {
      DayOfWeek.monday => 'Mon',
      DayOfWeek.tuesday => 'Tue',
      DayOfWeek.wednesday => 'Wed',
      DayOfWeek.thursday => 'Thu',
      DayOfWeek.friday => 'Fri',
      DayOfWeek.saturday => 'Sat',
      DayOfWeek.sunday => 'Sun',
    };
  }

  /// Full display label (e.g., "Monday").
  String get label {
    return switch (this) {
      DayOfWeek.monday => 'Monday',
      DayOfWeek.tuesday => 'Tuesday',
      DayOfWeek.wednesday => 'Wednesday',
      DayOfWeek.thursday => 'Thursday',
      DayOfWeek.friday => 'Friday',
      DayOfWeek.saturday => 'Saturday',
      DayOfWeek.sunday => 'Sunday',
    };
  }
}

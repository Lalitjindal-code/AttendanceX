import 'package:attendify/features/calendar/models/daily_attendance_item.dart';

class DailyAttendanceDetails {
  final DateTime date;
  final List<DailyAttendanceItem> items;

  const DailyAttendanceDetails({
    required this.date,
    this.items = const [],
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DailyAttendanceDetails &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day;
  }

  @override
  int get hashCode =>
      date.year.hashCode ^ date.month.hashCode ^ date.day.hashCode;
}

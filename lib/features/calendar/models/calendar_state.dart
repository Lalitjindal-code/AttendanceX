import 'dart:collection';
import 'package:attendancex/core/enums/attendance_status.dart';
import 'package:attendancex/features/calendar/models/daily_attendance_details.dart';
import 'package:attendancex/database/collections/subject_collection.dart';

class CalendarState {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final UnmodifiableMapView<DateTime, List<AttendanceStatus>> attendanceMarkers;
  final DailyAttendanceDetails selectedDayDetails;
  final List<Subject> allSubjects;
  final bool isLoading;

  const CalendarState({
    required this.selectedDate,
    required this.focusedDate,
    required this.attendanceMarkers,
    required this.selectedDayDetails,
    required this.allSubjects,
    this.isLoading = false,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? focusedDate,
    UnmodifiableMapView<DateTime, List<AttendanceStatus>>? attendanceMarkers,
    DailyAttendanceDetails? selectedDayDetails,
    List<Subject>? allSubjects,
    bool? isLoading,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      attendanceMarkers: attendanceMarkers ?? this.attendanceMarkers,
      selectedDayDetails: selectedDayDetails ?? this.selectedDayDetails,
      allSubjects: allSubjects ?? this.allSubjects,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

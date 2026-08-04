import 'dart:collection';
import 'package:attendancex/core/enums/attendance_status.dart';
import 'package:attendancex/database/collections/academic_task_collection.dart';
import 'package:attendancex/features/calendar/models/daily_attendance_details.dart';
import 'package:attendancex/database/collections/subject_collection.dart';

class CalendarState {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final UnmodifiableMapView<DateTime, List<AttendanceStatus>> attendanceMarkers;
  final UnmodifiableMapView<DateTime, List<AcademicTask>> taskMarkers;
  final DailyAttendanceDetails selectedDayDetails;
  final List<AcademicTask> selectedDayTasks;
  final List<Subject> allSubjects;
  final bool isLoading;

  const CalendarState({
    required this.selectedDate,
    required this.focusedDate,
    required this.attendanceMarkers,
    required this.taskMarkers,
    required this.selectedDayDetails,
    required this.selectedDayTasks,
    required this.allSubjects,
    this.isLoading = false,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? focusedDate,
    UnmodifiableMapView<DateTime, List<AttendanceStatus>>? attendanceMarkers,
    UnmodifiableMapView<DateTime, List<AcademicTask>>? taskMarkers,
    DailyAttendanceDetails? selectedDayDetails,
    List<AcademicTask>? selectedDayTasks,
    List<Subject>? allSubjects,
    bool? isLoading,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      attendanceMarkers: attendanceMarkers ?? this.attendanceMarkers,
      taskMarkers: taskMarkers ?? this.taskMarkers,
      selectedDayDetails: selectedDayDetails ?? this.selectedDayDetails,
      selectedDayTasks: selectedDayTasks ?? this.selectedDayTasks,
      allSubjects: allSubjects ?? this.allSubjects,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

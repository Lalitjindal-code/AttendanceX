import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/collections/subject_collection.dart';
import 'package:attendify/database/collections/academic_task_collection.dart';
import 'attendance_summary.dart';
import 'smart_suggestion.dart';

class LectureCardModel {
  final Schedule schedule;
  final Subject subject;
  final Attendance? attendance;
  final SubjectAttendanceSummary summary;
  final SmartSuggestion suggestion;

  const LectureCardModel({
    required this.schedule,
    required this.subject,
    required this.attendance,
    required this.summary,
    required this.suggestion,
  });
}

class QuickStats {
  final int attendedToday;
  final int totalToday;
  final int attendedThisWeek;
  final int totalThisWeek;
  final int attendedThisMonth;
  final int totalThisMonth;

  const QuickStats({
    this.attendedToday = 0,
    this.totalToday = 0,
    this.attendedThisWeek = 0,
    this.totalThisWeek = 0,
    this.attendedThisMonth = 0,
    this.totalThisMonth = 0,
  });
}

class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final List<LectureCardModel> pendingLectures;
  final List<LectureCardModel> markedLectures;
  final String todayProgressText;
  final double todayProgressPercentage;
  final OverallAttendanceSummary? overallSummary;
  final SmartSuggestion? overallSuggestion;
  final List<AcademicTask> upcomingTasks;
  final QuickStats quickStats;

  const DashboardState({
    this.isLoading = true,
    this.errorMessage,
    this.pendingLectures = const [],
    this.markedLectures = const [],
    this.todayProgressText = '0 / 0 Classes Marked',
    this.todayProgressPercentage = 0.0,
    this.overallSummary,
    this.overallSuggestion,
    this.upcomingTasks = const [],
    this.quickStats = const QuickStats(),
  });
}

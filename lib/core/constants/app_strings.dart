/// All user-facing string literals for the application.
///
/// No display strings should be hardcoded in widget files.
/// All text content must come from this class.
abstract final class AppStrings {
  AppStrings._();

  // ── App ────────────────────────────────────────────────────────────────────────
  static const String appName = 'Attendify';
  static const String appTagline = 'Smart Attendance Tracker';

  // ── Navigation ────────────────────────────────────────────────────────────────
  static const String navDashboard = 'Dashboard';
  static const String navSubjects = 'Subjects';
  static const String navSchedule = 'Schedule';
  static const String navAnalytics = 'Analytics';
  static const String navSettings = 'Settings';

  // ── Dashboard ─────────────────────────────────────────────────────────────────
  static const String dashboardTitle = 'Today';
  static const String dashboardGreetingMorning = 'Good Morning';
  static const String dashboardGreetingAfternoon = 'Good Afternoon';
  static const String dashboardGreetingEvening = 'Good Evening';
  static const String dashboardNoClasses = 'No classes today';
  static const String dashboardNoClassesSub =
      'Enjoy your free day! Set up your timetable to start tracking.';
  static const String dashboardMarkHoliday = 'Mark as Holiday';
  static const String dashboardOverallAttendance = 'Overall Attendance';

  // ── Subjects ──────────────────────────────────────────────────────────────────
  static const String subjectsTitle = 'Subjects';
  static const String subjectsEmpty = 'No subjects yet';
  static const String subjectsEmptySub =
      'Add your first subject to start tracking attendance.';
  static const String subjectAdd = 'Add Subject';
  static const String subjectEdit = 'Edit Subject';
  static const String subjectDelete = 'Delete Subject';
  static const String subjectName = 'Subject Name';
  static const String subjectFaculty = 'Faculty Name';
  static const String subjectFacultyEmail = 'Faculty Email';
  static const String subjectFacultyPhone = 'Faculty Phone';
  static const String subjectCredits = 'Credits';
  static const String subjectGoal = 'Attendance Goal (%)';
  static const String subjectMinimum = 'Minimum Attendance (%)';
  static const String subjectNotes = 'Notes';
  static const String subjectColor = 'Color';

  // ── Subject Deletion Dialog ────────────────────────────────────────────────────
  static const String deleteSubjectTitle = 'Delete Subject?';
  static const String deleteSubjectConfirm = 'Delete Permanently';
  static const String deleteSubjectCancel = 'Cancel';

  // ── Schedule ──────────────────────────────────────────────────────────────────
  static const String scheduleTitle = 'Schedule';
  static const String scheduleEmpty = 'No schedule set up';
  static const String scheduleEmptySub =
      "Add your weekly timetable to see today's classes automatically.";
  static const String scheduleAddLecture = 'Add Lecture';
  static const String scheduleEditLecture = 'Edit Lecture';
  static const String scheduleRoom = 'Room Number';
  static const String scheduleStartTime = 'Start Time';
  static const String scheduleEndTime = 'End Time';

  // ── Attendance Status Labels ───────────────────────────────────────────────────
  static const String statusPresent = 'Present';
  static const String statusAbsent = 'Absent';
  static const String statusMedical = 'Medical';
  static const String statusGT = 'GT';
  static const String statusHoliday = 'Holiday';
  static const String statusPending = 'Pending';

  // ── Lecture Type Labels ───────────────────────────────────────────────────────
  static const String typeLecture = 'Lecture';
  static const String typeLab = 'Lab';
  static const String typeTutorial = 'Tutorial';

  // ── Analytics ─────────────────────────────────────────────────────────────────
  static const String analyticsTitle = 'Analytics';
  static const String analyticsEmpty = 'No data yet';
  static const String analyticsEmptySub =
      'Start tracking attendance to see your statistics here.';
  static const String analyticsSafeBunks = 'Safe Bunks';
  static const String analyticsRequired = 'Classes Required';
  static const String analyticsPrediction = 'Predicted End %';
  static const String analyticsOverall = 'Overall Attendance';

  // ── Settings ──────────────────────────────────────────────────────────────────
  static const String settingsTitle = 'Settings';
  static const String settingsAppearance = 'Appearance';
  static const String settingsTheme = 'Theme';
  static const String settingsThemeLight = 'Light';
  static const String settingsThemeDark = 'Dark';
  static const String settingsThemeSystem = 'System Default';
  static const String settingsAttendance = 'Attendance Rules';
  static const String settingsDefaultGoal = 'Default Goal (%)';
  static const String settingsMedical = 'Medical Leave Policy';
  static const String settingsMedicalSwitch = 'Count Medical Leave as Present';
  static const String settingsGtMode = 'GT (Granted Leave) Mode';
  static const String settingsSemester = 'Semester Dates';
  static const String settingsSemesterStart = 'Semester Start Date';
  static const String settingsSemesterEnd = 'Semester End Date';
  static const String settingsNotifications = 'Notifications';
  static const String settingsBackup = 'Backup & Restore';
  static const String settingsAbout = 'About';

  // ── Calendar ──────────────────────────────────────────────────────────────────
  static const String calendarTitle = 'Calendar';

  // ── Holiday ───────────────────────────────────────────────────────────────────
  static const String holidayDialogTitle = 'Mark as Holiday';
  static const String holidayReason = 'Holiday Reason';
  static const String holidayNotes = 'Notes (optional)';
  static const String holidayConfirm = 'Mark Holiday';

  // ── Common ────────────────────────────────────────────────────────────────────
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String confirm = 'Confirm';
  static const String back = 'Back';
  static const String search = 'Search';
  static const String noResults = 'No results found';
  static const String error = 'Something went wrong';
  static const String retry = 'Retry';
  static const String loading = 'Loading…';
  static const String close = 'Close';

  // ── Validation ────────────────────────────────────────────────────────────────
  static const String validRequired = 'This field is required';
  static const String validNameTooLong = 'Must be 60 characters or less';
  static const String validNotesTooLong = 'Must be 300 characters or less';
  static const String validGoalRange = 'Must be between 1 and 100';
  static const String validCreditsRange = 'Must be between 1 and 10';
  static const String validDuplicateSubject =
      'A subject with this name already exists';
  static const String validInvalidEmail = 'Enter a valid email address';
  static const String validTimeConflict =
      'This time slot conflicts with an existing lecture';
  static const String validEndBeforeStart =
      'End time must be after start time';

  // ── Snackbars ─────────────────────────────────────────────────────────────────
  static const String snackSubjectAdded = 'Subject added';
  static const String snackSubjectUpdated = 'Subject updated';
  static const String snackSubjectDeleted = 'Subject deleted';
  static const String snackAttendanceUpdated = 'Attendance updated';
  static const String snackHolidayAdded = 'Marked as holiday';
  static const String snackSettingsSaved = 'Settings saved';
  static const String snackBackupSuccess = 'Backup created';
  static const String snackRestoreSuccess = 'Data restored';
  static const String snackError = 'An error occurred. Please try again.';
}

/// Strongly-typed route paths for GoRouter.
///
/// Use these constants instead of hardcoded strings when calling
/// context.go() or context.push().
abstract final class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/';
  static const String splash = '/splash';
  static const String subjects = '/subjects';
  static const String schedule = '/schedule';
  static const String planner = '/planner';
  static const String more = '/more';
  static const String calendar = '/calendar';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  // Manager route
  static const String notificationManager = '/notification-manager';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String collegeZone = '/college-zone';
  static const String requestTimetable = '/request-timetable';
  static const String feedback = '/feedback';
  static const String userSupport = '/support';
  static const String ticketChat = '/support/chat';
  
  // Admin Routes
  static const String adminRequests = '/admin-requests';
  static const String adminUsers = '/admin-users';
  static const String adminReminders = '/admin-reminders';
  static const String adminFeedbacks = '/admin-feedbacks';
  
  static const String bunkSimulator = '/bunk-simulator';

  // Sub-routes
  static const String subjectDetail = 'detail/:id';
}

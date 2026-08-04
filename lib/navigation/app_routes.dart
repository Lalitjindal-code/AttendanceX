/// Strongly-typed route paths for GoRouter.
///
/// Use these constants instead of hardcoded strings when calling
/// context.go() or context.push().
abstract final class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/';
  static const String subjects = '/subjects';
  static const String schedule = '/schedule';
  static const String planner = '/planner';
  static const String more = '/more';
  static const String calendar = '/calendar';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

  // Sub-routes
  static const String subjectDetail = 'detail/:id';
}

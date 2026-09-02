import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:showcaseview/showcaseview.dart';

import '../features/analytics/screens/analytics_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/schedule/screens/schedule_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/subjects/screens/subject_detail_screen.dart';
import '../features/subjects/screens/subjects_screen.dart';
import '../features/planner/screens/planner_screen.dart';
import '../features/more/screens/more_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/notifications/screens/notification_manager_screen.dart';
import '../features/settings/screens/feedback_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/settings/providers/settings_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/college/screens/college_zone_screen.dart';
import '../features/simulator/screens/bunk_simulator_screen.dart';
import '../features/admin/screens/admin_requests_screen.dart';
import '../features/admin/screens/admin_users_screen.dart';
import '../features/admin/screens/admin_reminders_screen.dart';
import '../features/admin/screens/admin_feedbacks_screen.dart';
import '../features/schedule/screens/request_timetable_screen.dart';
import '../features/support/screens/user_support_screen.dart';
import '../features/support/screens/ticket_chat_screen.dart';
import 'app_routes.dart';
import 'shell_scaffold.dart';
import '../features/splash/screens/splash_screen.dart';

part 'app_router.g.dart';

/// Global navigator key.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider for the GoRouter instance.
///
/// Ref is passed in case future requirements (like Auth) need to listen to
/// state changes to trigger redirects.
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final isOnboardingComplete =
      ref.watch(settingsProvider.select((s) => s.isOnboardingComplete));
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isGoingToSplash = state.uri.path == AppRoutes.splash;
      final isGoingToOnboarding = state.uri.path == AppRoutes.onboarding;
      final isGoingToLogin = state.uri.path == AppRoutes.login;
      final isGoingToSignup = state.uri.path == AppRoutes.signup;

      if (isGoingToSplash) return null;

      if (authState.isLoading) return null;
      final user = authState.valueOrNull;

      if (user == null) {
        if (isGoingToSignup) return AppRoutes.signup;
        return AppRoutes.login;
      }

      if (isGoingToLogin || isGoingToSignup) {
        if (!isOnboardingComplete) return AppRoutes.onboarding;
        return AppRoutes.dashboard;
      }

      if (!isOnboardingComplete && !isGoingToOnboarding) {
        return AppRoutes.onboarding;
      }
      if (isOnboardingComplete && isGoingToOnboarding) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.collegeZone,
        builder: (context, state) => const CollegeZoneScreen(),
      ),
      GoRoute(
        path: AppRoutes.requestTimetable,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return RequestTimetableScreen(
            branch: args['branch'] ?? 'Unknown',
            semester: args['semester']?.toString() ?? '1',
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // ── Branch 0: Dashboard ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => ShowCaseWidget(
                  builder: (context) => const DashboardScreen(),
                ),
              ),
            ],
          ),
          // ── Branch 1: Subjects ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.subjects,
                builder: (context, state) => ShowCaseWidget(
                  builder: (context) => const SubjectsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.subjectDetail,
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      final subjectId = int.tryParse(id ?? '');
                      if (subjectId == null) {
                        return const Scaffold(
                          body: Center(child: Text('Invalid subject ID')),
                        );
                      }
                      return SubjectDetailScreen(subjectId: subjectId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // ── Branch 2: Schedule ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.schedule,
                builder: (context, state) => ShowCaseWidget(
                  builder: (context) => const ScheduleScreen(),
                ),
              ),
            ],
          ),
          // 📅 Branch 3: Planner 📅
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.planner,
                builder: (context, state) => ShowCaseWidget(
                  builder: (context) => const PlannerScreen(),
                ),
              ),
            ],
          ),
          // ⚙️ Branch 4: More ⚙️
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => ShowCaseWidget(
                  builder: (context) => const MoreScreen(),
                ),
                routes: const <RouteBase>[],
                // Sub-routes for More tab (no leading slash for sub-routes, but AppRoutes are absolute)
                // Wait, if they are absolute, we can just define them inside the branch directly instead of nested.
                // Wait, if they are absolute, we can just define them inside the branch directly instead of nested.
              ),
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) => ShowCaseWidget(
                  builder: (context) => const CalendarScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.analytics,
                builder: (context, state) => ShowCaseWidget(
                  builder: (context) => const AnalyticsScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => ShowCaseWidget(
                  builder: (context) => const SettingsScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.notifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
              GoRoute(
                // Manager screen
                path: AppRoutes.notificationManager,
                builder: (context, state) => const NotificationManagerScreen(),
              ),
              GoRoute(
                path: AppRoutes.feedback,
                builder: (context, state) => ShowCaseWidget(
                  builder: (context) => const FeedbackScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.userSupport,
                builder: (context, state) => const UserSupportScreen(),
              ),
              GoRoute(
                path: AppRoutes.ticketChat,
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>? ?? {};
                  return TicketChatScreen(
                    ticketId: args['id'] ?? '',
                    ticketType: args['type'] ?? 'feedback',
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.bunkSimulator,
                builder: (context, state) => const BunkSimulatorScreen(),
              ),
              GoRoute(
                path: AppRoutes.adminRequests,
                builder: (context, state) => const AdminRequestsScreen(),
              ),
              GoRoute(
                path: AppRoutes.adminUsers,
                builder: (context, state) => const AdminUsersScreen(),
              ),
              GoRoute(
                path: AppRoutes.adminReminders,
                builder: (context, state) => const AdminRemindersScreen(),
              ),
              GoRoute(
                path: AppRoutes.adminFeedbacks,
                builder: (context, state) => const AdminFeedbacksScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

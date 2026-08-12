import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
import 'app_routes.dart';
import 'shell_scaffold.dart';

part 'app_router.g.dart';

/// Global navigator key.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

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
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isGoingToOnboarding = state.uri.path == AppRoutes.onboarding;
      final isGoingToLogin = state.uri.path == AppRoutes.login;
      final isGoingToSignup = state.uri.path == AppRoutes.signup;

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
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // ── Branch 1: Subjects ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.subjects,
                builder: (context, state) => const SubjectsScreen(),
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
                builder: (context, state) => const ScheduleScreen(),
              ),
            ],
          ),
          // 📅 Branch 3: Planner 📅
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.planner,
                builder: (context, state) => const PlannerScreen(),
              ),
            ],
          ),
          // ⚙️ Branch 4: More ⚙️
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => const MoreScreen(),
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
                builder: (context, state) => const CalendarScreen(),
              ),
              GoRoute(
                path: AppRoutes.analytics,
                builder: (context, state) => const AnalyticsScreen(),
              ),
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
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
                builder: (context, state) => const FeedbackScreen(),
              ),
              GoRoute(
                path: AppRoutes.bunkSimulator,
                builder: (context, state) => const BunkSimulatorScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

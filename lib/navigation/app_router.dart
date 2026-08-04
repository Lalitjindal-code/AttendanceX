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
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    routes: [
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
                      return SubjectDetailScreen(
                        subjectId: int.parse(id!),
                      );
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
                routes: [
                  // Sub-routes for More tab (no leading slash for sub-routes, but AppRoutes are absolute)
                  // Wait, if they are absolute, we can just define them inside the branch directly instead of nested.
                ],
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
            ],
          ),
        ],
      ),
    ],
  );
}

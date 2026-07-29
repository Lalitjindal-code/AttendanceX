import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/analytics/screens/analytics_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/schedule/screens/schedule_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/subjects/screens/subject_form_screen.dart';
import '../features/subjects/screens/subjects_screen.dart';
import '../features/schedule/screens/schedule_form_screen.dart';
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
                    path: AppRoutes.subjectForm,
                    builder: (context, state) {
                      final id = state.uri.queryParameters['id'];
                      return SubjectFormScreen(
                        subjectId: id != null ? int.tryParse(id) : null,
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
                routes: [
                  GoRoute(
                    path: AppRoutes.scheduleForm,
                    builder: (context, state) {
                      final id = state.uri.queryParameters['id'];
                      final day = state.uri.queryParameters['day'];
                      return ScheduleFormScreen(
                        scheduleId: id != null ? int.tryParse(id) : null,
                        dayOfWeek: day != null ? int.tryParse(day) : null,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // 📅 Branch 3: Calendar 📅
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // 📊 Branch 4: Analytics 📊
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analytics,
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          // ⚙️ Branch 5: Settings ⚙️
          StatefulShellBranch(
            routes: [
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

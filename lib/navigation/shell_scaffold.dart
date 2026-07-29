import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_icons.dart';
import '../core/constants/app_strings.dart';

/// The root scaffold for the application's bottom navigation bar.
///
/// Wraps the GoRouter StatefulShellRoute branches to provide persistent
/// navigation state between tabs.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // A common pattern when tapping an already active tab is to pop
            // to the initial location of that branch.
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(AppIcons.dashboardOutlined),
            selectedIcon: Icon(AppIcons.dashboard),
            label: AppStrings.navDashboard,
          ),
          NavigationDestination(
            icon: Icon(AppIcons.subjectsOutlined),
            selectedIcon: Icon(AppIcons.subjects),
            label: AppStrings.navSubjects,
          ),
          NavigationDestination(
            icon: Icon(AppIcons.scheduleOutlined),
            selectedIcon: Icon(AppIcons.schedule),
            label: AppStrings.navSchedule,
          ),
          NavigationDestination(
            icon: Icon(AppIcons.calendar),
            selectedIcon: Icon(AppIcons.calendar),
            label: AppStrings.calendarTitle,
          ),
          NavigationDestination(
            icon: Icon(AppIcons.analyticsOutlined),
            selectedIcon: Icon(AppIcons.analytics),
            label: AppStrings.navAnalytics,
          ),
          NavigationDestination(
            icon: Icon(AppIcons.settingsOutlined),
            selectedIcon: Icon(AppIcons.settings),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}

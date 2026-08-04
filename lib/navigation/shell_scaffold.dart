import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_icons.dart';
import '../core/constants/app_strings.dart';

/// The root scaffold for the application's bottom navigation bar.
///
/// Meridian-styled: top border separator, pill indicator, custom icons.
/// Wraps [StatefulNavigationShell] branches for persistent navigation state.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Meridian: hairline top border on nav bar
          Divider(
            height: 1,
            thickness: 1,
            color: scheme.outlineVariant,
          ),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(AppIcons.dashboardOutlined),
                selectedIcon: Icon(AppIcons.dashboard),
                label: AppStrings.navDashboard,
                tooltip: '',
              ),
              NavigationDestination(
                icon: Icon(AppIcons.subjectsOutlined),
                selectedIcon: Icon(AppIcons.subjects),
                label: AppStrings.navSubjects,
                tooltip: '',
              ),
              NavigationDestination(
                icon: Icon(AppIcons.scheduleOutlined),
                selectedIcon: Icon(AppIcons.schedule),
                label: AppStrings.navSchedule,
                tooltip: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.check_circle_outline_rounded),
                selectedIcon: Icon(Icons.check_circle_rounded),
                label: 'Planner',
                tooltip: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'More',
                tooltip: '',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

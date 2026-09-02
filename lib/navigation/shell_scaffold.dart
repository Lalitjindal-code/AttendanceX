import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import '../core/constants/app_icons.dart';
import '../core/constants/app_strings.dart';
import '../features/tutorials/providers/tutorial_provider.dart';

/// The root scaffold for the application's bottom navigation bar.
///
/// Meridian-styled: top border separator, pill indicator, custom icons.
/// Wraps [StatefulNavigationShell] branches for persistent navigation state.
class ShellScaffold extends ConsumerStatefulWidget {
  const ShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<ShellScaffold> {
  final GlobalKey _moreTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasShown = ref.read(bottomNavTutorialNotifierProvider);
      if (!hasShown && mounted) {
        // We use a delayed future to ensure ShowCaseWidget context is fully ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && context.mounted) {
            ShowCaseWidget.of(context).startShowCase([_moreTabKey]);
            ref.read(bottomNavTutorialNotifierProvider.notifier).markShown();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ShowCaseWidget(
      builder: (context) => Scaffold(
        body: widget.navigationShell,
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
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: (index) {
                HapticFeedback.selectionClick();
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: index == widget.navigationShell.currentIndex,
                );
              },
              destinations: [
                const NavigationDestination(
                  icon: Icon(AppIcons.dashboardOutlined),
                  selectedIcon: Icon(AppIcons.dashboard),
                  label: AppStrings.navDashboard,
                  tooltip: '',
                ),
                const NavigationDestination(
                  icon: Icon(AppIcons.subjectsOutlined),
                  selectedIcon: Icon(AppIcons.subjects),
                  label: AppStrings.navSubjects,
                  tooltip: '',
                ),
                const NavigationDestination(
                  icon: Icon(AppIcons.scheduleOutlined),
                  selectedIcon: Icon(AppIcons.schedule),
                  label: AppStrings.navSchedule,
                  tooltip: '',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.check_circle_outline_rounded),
                  selectedIcon: Icon(Icons.check_circle_rounded),
                  label: 'Planner',
                  tooltip: '',
                ),
                NavigationDestination(
                  icon: Showcase(
                    key: _moreTabKey,
                    description: 'Go to Settings here to join the WhatsApp Community!',
                    child: const Icon(Icons.grid_view_outlined),
                  ),
                  selectedIcon: const Icon(Icons.grid_view_rounded),
                  label: 'More',
                  tooltip: '',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

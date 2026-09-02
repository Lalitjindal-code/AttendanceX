import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/calendar_provider.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/day_detail_panel.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../tutorials/providers/tutorial_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final GlobalKey _calendarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasShown = ref.read(calendarTutorialNotifierProvider);
      if (!hasShown) {
        ShowCaseWidget.of(context).startShowCase([_calendarKey]);
        ref.read(calendarTutorialNotifierProvider.notifier).markShown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarStateAsync = ref.watch(calendarNotifierProvider);

    return Scaffold(
      body: calendarStateAsync.when(
        skipLoadingOnReload: true,
        data: (state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text('Calendar',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold)),
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                iconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              SliverToBoxAdapter(
                child: Showcase(
                  key: _calendarKey,
                  description: 'Select any date to view your schedule and attendance for that day',
                  child: CalendarWidget(state: state),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.1)),
                ),
              ),
              DayDetailPanel(state: state),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: BannerAdWidget(),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7E73FF))),
        error: (err, stack) => Center(
            child: Text('Error: $err',
                style: TextStyle(color: Theme.of(context).colorScheme.error))),
      ),
    );
  }
}

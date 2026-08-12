import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/calendar_provider.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/day_detail_panel.dart';
import '../../../core/widgets/banner_ad_widget.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                child: CalendarWidget(state: state),
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

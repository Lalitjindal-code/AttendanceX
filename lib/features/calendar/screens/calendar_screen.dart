import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/calendar_provider.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/day_detail_panel.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarStateAsync = ref.watch(calendarNotifierProvider);

    return Scaffold(
      body: calendarStateAsync.when(
        data: (state) {
          return CustomScrollView(
            slivers: [
              const SliverAppBar.large(
                title: Text('Calendar'),
                floating: true,
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: CalendarWidget(state: state),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(),
                ),
              ),
              DayDetailPanel(state: state),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

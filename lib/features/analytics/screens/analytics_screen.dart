import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/analytics_provider.dart';
import '../widgets/atd_bar_chart.dart';
import '../widgets/atd_line_chart.dart';
import '../widgets/atd_donut_chart.dart';
import '../widgets/analytics_summary_cards.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(analyticsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: stateAsync.when(
        data: (state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.subjectStats.isEmpty) {
            return _buildEmptyState(context);
          }

          final summary = state.overallSummary;
          if (summary == null) return const SizedBox();
          final forecast = state.overallForecast;

          return CustomScrollView(
            slivers: [
              const SliverAppBar.large(
                title: Text('Analytics'),
                floating: true,
                pinned: true,
              ),
              
              // 1. Overview Donut Chart & Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AtdDonutChart(summary: summary),
                      const SizedBox(height: AppSpacing.md),
                      AnalyticsSummaryCards(
                        title1: 'Total Classes',
                        value1: '${summary.effectiveTotal}',
                        icon1: Icons.class_outlined,
                        color1: theme.colorScheme.primary,
                        title2: 'Attended',
                        value2: '${summary.effectivePresent}',
                        icon2: Icons.check_circle_outline,
                        color2: Colors.green,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AnalyticsSummaryCards(
                        title1: 'Bunks Available',
                        value1: '${forecast?.safeBunksRemaining ?? 0}',
                        icon1: Icons.event_available_outlined,
                        color1: Colors.blue,
                        title2: 'Classes Needed',
                        value2: '${forecast?.classesNeededToReachGoal ?? 0}',
                        icon2: Icons.event_busy_outlined,
                        color2: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(),
                ),
              ),

              // 2. Weekly Trend Line Chart
              if (state.monthlyTrends.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Trend',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AtdLineChart(trends: state.monthlyTrends),
                      ],
                    ),
                  ),
                ),
              
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(),
                ),
              ),

              // 3. Subject-wise Bar Chart
              if (state.subjectStats.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subject Breakdown',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AtdBarChart(stats: state.subjectStats),
                      ],
                    ),
                  ),
                ),

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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nothing to analyse yet.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Start marking attendance to see insights.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

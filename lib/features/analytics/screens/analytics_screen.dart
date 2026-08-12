import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/analytics_provider.dart';
import '../widgets/atd_line_chart.dart';
import '../widgets/atd_donut_chart.dart';
import '../widgets/analytics_summary_cards.dart';
import '../widgets/subject_analytics_card.dart';
import '../widgets/day_of_week_chart.dart';
import '../widgets/top_bottom_subjects_cards.dart';
import '../widgets/bunk_heatmap_chart.dart';
import '../../../core/widgets/banner_ad_widget.dart';

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
              SliverAppBar.large(
                title: Text('Analytics', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
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
                        color1: const Color(0xFF7E73FF),
                        title2: 'Attended',
                        value2: '${summary.effectivePresent}',
                        icon2: Icons.check_circle_outline,
                        color2: const Color(0xFF00E676),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AnalyticsSummaryCards(
                        title1: 'Bunks Available',
                        value1: '${forecast?.safeBunksRemaining ?? 0}',
                        icon1: Icons.event_available_outlined,
                        color1: Colors.blueAccent,
                        title2: 'Classes Needed',
                        value2: '${forecast?.classesNeededToReachGoal ?? 0}',
                        icon2: Icons.event_busy_outlined,
                        color2: Colors.orangeAccent,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TopBottomSubjectsCards(subjectStats: state.subjectStats),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
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
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AtdLineChart(trends: state.monthlyTrends),
                      ],
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),

              // 2.5 Bunk Heatmap
              if (state.bunkHeatmap.isNotEmpty)
                SliverToBoxAdapter(
                  child: BunkHeatmapChart(heatmapData: state.bunkHeatmap),
                ),

              // 2.6 Day of Week Trend Chart
              if (state.dayOfWeekTrends.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      top: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day of Week Analysis',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DayOfWeekChart(trends: state.dayOfWeekTrends),
                      ],
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),

              // 3. Subject-wise Breakdowns
              if (state.subjectStats.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.md,
                      bottom: AppSpacing.sm,
                    ),
                    child: Text(
                      'Subject Breakdown',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return SubjectAnalyticsCard(
                          stats: state.subjectStats[index],
                        );
                      },
                      childCount: state.subjectStats.length,
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(
                child: BannerAdWidget(),
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nothing to analyse yet.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Start marking attendance to see insights.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
          ),
        ],
      ),
    );
  }
}

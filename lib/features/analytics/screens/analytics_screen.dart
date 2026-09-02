import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/analytics_state.dart';
import '../providers/analytics_provider.dart';
import '../services/pdf_report_service.dart';
import '../widgets/atd_line_chart.dart';
import '../widgets/atd_donut_chart.dart';
import '../widgets/analytics_summary_cards.dart';
import '../widgets/subject_analytics_card.dart';
import '../widgets/day_of_week_chart.dart';
import '../widgets/top_bottom_subjects_cards.dart';
import '../widgets/bunk_heatmap_chart.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../settings/providers/semester_provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../tutorials/providers/tutorial_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isExporting = false;
  final GlobalKey _exportPdfKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasShown = ref.read(analyticsTutorialNotifierProvider);
      if (!hasShown) {
        ShowCaseWidget.of(context).startShowCase([_exportPdfKey]);
        ref.read(analyticsTutorialNotifierProvider.notifier).markShown();
      }
    });
  }

  Future<void> _exportPdf(AnalyticsState state, bool isDetailed) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final semester = ref.read(semesterStateProvider);
      final semesterName = semester?.name ?? 'Current Semester';
      final pdfBytes = await PdfReportService.generateReport(
        state: state,
        semesterName: semesterName,
        isDetailed: isDetailed,
      );
      final suffix = isDetailed ? 'detailed' : 'brief';
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'attendify_report_${semesterName}_$suffix.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showReportTypeSheet(AnalyticsState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'Select Report Type',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Brief Report'),
                  subtitle: const Text('Overview and subject summary (Current)'),
                  onTap: () {
                    Navigator.pop(context);
                    _exportPdf(state, false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt_outlined),
                  title: const Text('Detailed Report'),
                  subtitle: const Text('Includes date-by-date attendance for each subject'),
                  onTap: () {
                    Navigator.pop(context);
                    _exportPdf(state, true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                title: Text('Analytics',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold)),
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                iconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.onSurface),
                actions: [
                  if (_isExporting)
                    const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    Showcase(
                      key: _exportPdfKey,
                      description: 'Tap here to export your analytics as a PDF report',
                      child: IconButton(
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        tooltip: 'Export PDF Report',
                        onPressed: () => _showReportTypeSheet(state),
                      ),
                    ),
                ],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(
                      color: Theme.of(context).colorScheme.outlineVariant),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(
                      color: Theme.of(context).colorScheme.outlineVariant),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(
                      color: Theme.of(context).colorScheme.outlineVariant),
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
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nothing to analyse yet.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Start marking attendance to see insights.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
          ),
        ],
      ),
    );
  }
}

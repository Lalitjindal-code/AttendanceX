import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_spacing.dart';

class BunkHeatmapChart extends StatelessWidget {
  final Map<DateTime, int> heatmapData;

  const BunkHeatmapChart({super.key, required this.heatmapData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // We will show the last 28 days (4 weeks)
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    // Move to the nearest Sunday (or end of week) to align the grid
    final daysToSubtract = endDate.weekday % 7; 
    final adjustedEndDate = endDate.add(Duration(days: 7 - daysToSubtract));
    final startDate = adjustedEndDate.subtract(const Duration(days: 27));

    // Generate grid points
    final List<DateTime> dates = [];
    for (int i = 0; i <= 27; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bunk Heatmap (Last 4 Weeks)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            mainAxisSpacing: 0,
            crossAxisSpacing: 4,
            childAspectRatio: 2.0,
            children: [
              _buildTopDayLabel('M', theme),
              _buildTopDayLabel('T', theme),
              _buildTopDayLabel('W', theme),
              _buildTopDayLabel('T', theme),
              _buildTopDayLabel('F', theme),
              _buildTopDayLabel('S', theme),
              _buildTopDayLabel('S', theme),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 days in a week (columns)
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final dateKey = DateTime(date.year, date.month, date.day);
              final missedClasses = heatmapData[dateKey] ?? 0;
              
              return Tooltip(
                message: '${DateFormat('MMM d, yyyy').format(date)}\n'
                    '${missedClasses == 0 ? "No bunks" : "$missedClasses class${missedClasses > 1 ? 'es' : ''} bunked"}',
                textAlign: TextAlign.center,
                triggerMode: TooltipTriggerMode.tap,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getColor(missedClasses, theme),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLegend(theme),
        ],
      ),
    );
  }

  Widget _buildTopDayLabel(String text, ThemeData theme) {
    return Center(
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less', style: theme.textTheme.labelSmall),
        const SizedBox(width: 4),
        _buildLegendBox(0, theme),
        const SizedBox(width: 4),
        _buildLegendBox(1, theme),
        const SizedBox(width: 4),
        _buildLegendBox(3, theme),
        const SizedBox(width: 4),
        _buildLegendBox(5, theme),
        const SizedBox(width: 4),
        Text('More', style: theme.textTheme.labelSmall),
      ],
    );
  }

  Widget _buildLegendBox(int count, ThemeData theme) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getColor(count, theme),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildDayLabel(String text, ThemeData theme) {
    return SizedBox(
      height: 24, // Matches the rough height of a grid item + spacing
      child: Center(
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Color _getColor(int missedClasses, ThemeData theme) {
    if (missedClasses == 0) return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    if (missedClasses <= 1) return Colors.orange.shade300;
    if (missedClasses <= 2) return Colors.deepOrange.shade400;
    if (missedClasses <= 4) return Colors.red.shade600;
    return Colors.red.shade900;
  }
}

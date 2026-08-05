import 'package:flutter/material.dart';
import 'package:attendify/features/analytics/models/subject_statistics.dart';
import 'package:attendify/features/analytics/models/analytics_trend.dart';

class SubjectStatisticsCard extends StatelessWidget {
  final SubjectStatistics stats;

  const SubjectStatisticsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData trendIcon;
    Color trendColor;
    String trendText;

    switch (stats.trend) {
      case AnalyticsTrend.improving:
        trendIcon = Icons.trending_up;
        trendColor = Colors.green;
        trendText = 'Improving';
        break;
      case AnalyticsTrend.declining:
        trendIcon = Icons.trending_down;
        trendColor = Colors.orange;
        trendText = 'Declining';
        break;
      case AnalyticsTrend.stable:
        trendIcon = Icons.trending_flat;
        trendColor = Colors.blue;
        trendText = 'Stable';
        break;
      case AnalyticsTrend.insufficientData:
        trendIcon = Icons.remove;
        trendColor = Colors.grey;
        trendText = 'No data';
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    stats.subject.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(trendIcon, size: 16, color: trendColor),
                      const SizedBox(width: 4),
                      Text(
                        trendText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn(
                  'Present',
                  '${stats.summary.effectivePresent}',
                  theme,
                  Colors.green,
                ),
                _buildStatColumn(
                  'Absent',
                  '${stats.summary.effectiveTotal - stats.summary.effectivePresent}',
                  theme,
                  Colors.orange,
                ),
                _buildStatColumn(
                  'Total',
                  '${stats.summary.effectiveTotal}',
                  theme,
                  Colors.blue,
                ),
                _buildStatColumn(
                  'Current %',
                  '${stats.summary.attendancePercentage.toStringAsFixed(1)}%',
                  theme,
                  theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Forecast',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (stats.forecast.classesNeededToReachGoal > 0)
              Text(
                'Attend ${stats.forecast.classesNeededToReachGoal} more class(es) to reach your goal.',
                style: theme.textTheme.bodyMedium,
              )
            else if (stats.forecast.safeBunksRemaining > 0 &&
                stats.forecast.safeBunksRemaining != 999)
              Text(
                'You can safely bunk ${stats.forecast.safeBunksRemaining} class(es).',
                style: theme.textTheme.bodyMedium,
              )
            else if (stats.forecast.classesNeededToReachGoal == -1)
              Text(
                'Impossible to reach your goal of ${stats.subject.goalPercentage}%.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
              )
            else
              Text(
                'You are currently exactly on track for your goal.',
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildForecastBox(
                    'If you attend next',
                    '${(stats.forecast.projectedPercentageIfAttendNext * 100).toStringAsFixed(1)}%',
                    theme,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildForecastBox(
                    'If you bunk next',
                    '${(stats.forecast.projectedPercentageIfBunkNext * 100).toStringAsFixed(1)}%',
                    theme,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
      String label, String value, ThemeData theme, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastBox(
      String label, String value, ThemeData theme, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

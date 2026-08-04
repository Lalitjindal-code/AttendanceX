import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/subject_statistics.dart';

class SubjectAnalyticsCard extends StatelessWidget {
  final SubjectStatistics stats;

  const SubjectAnalyticsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = stats.subject;
    final overallPct = stats.summary.attendancePercentage;
    final lecturePct = stats.lectureSummary.attendancePercentage;
    final labPct = stats.labSummary.attendancePercentage;
    final isSafe = overallPct >= subject.goalPercentage;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(subject.colorValue),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Goal: ${subject.goalPercentage.toInt()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSafe 
                        ? theme.colorScheme.primaryContainer 
                        : theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${overallPct.toStringAsFixed(1)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSafe 
                          ? theme.colorScheme.onPrimaryContainer 
                          : theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTypeRow(context, 'Lectures', lecturePct, stats.lectureSummary.effectivePresent, stats.lectureSummary.effectiveTotal),
            const SizedBox(height: AppSpacing.md),
            _buildTypeRow(context, 'Labs', labPct, stats.labSummary.effectivePresent, stats.labSummary.effectiveTotal),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeRow(BuildContext context, String title, double pct, int present, int total) {
    final theme = Theme.of(context);
    final validTotal = total > 0;
    
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: validTotal ? present / total : 0.0,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              minHeight: 8,
              color: Color(stats.subject.colorValue),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 50,
          child: Text(
            validTotal ? '${pct.toStringAsFixed(0)}%' : 'N/A',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

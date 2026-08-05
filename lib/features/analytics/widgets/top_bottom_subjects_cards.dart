import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/subject_statistics.dart';

class TopBottomSubjectsCards extends StatelessWidget {
  final List<SubjectStatistics> subjectStats;

  const TopBottomSubjectsCards({super.key, required this.subjectStats});

  @override
  Widget build(BuildContext context) {
    if (subjectStats.length < 2) return const SizedBox();

    final sortedStats = List<SubjectStatistics>.from(subjectStats)
      ..sort((a, b) => b.summary.attendancePercentage
          .compareTo(a.summary.attendancePercentage));

    final topSubject = sortedStats.first;
    final bottomSubject = sortedStats.last;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildHighlightCard(
              context: context,
              title: 'Best Performer',
              stat: topSubject,
              icon: Icons.trending_up,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildHighlightCard(
              context: context,
              title: 'Needs Attention',
              stat: bottomSubject,
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required BuildContext context,
    required String title,
    required SubjectStatistics stat,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final pct = stat.summary.attendancePercentage;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF16162C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            stat.subject.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

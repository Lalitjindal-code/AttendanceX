import 'package:flutter/material.dart';
import '../models/dashboard_state.dart';

class QuickStatsRow extends StatelessWidget {
  final QuickStats quickStats;

  const QuickStatsRow({super.key, required this.quickStats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard(
            context,
            title: 'Today',
            attended: quickStats.attendedToday,
            total: quickStats.totalToday,
            icon: Icons.today_rounded,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            context,
            title: 'This Week',
            attended: quickStats.attendedThisWeek,
            total: quickStats.totalThisWeek,
            icon: Icons.view_week_rounded,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            context,
            title: 'This Month',
            attended: quickStats.attendedThisMonth,
            total: quickStats.totalThisMonth,
            icon: Icons.calendar_month_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title,
      required int attended,
      required int total,
      required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              '$attended / $total',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

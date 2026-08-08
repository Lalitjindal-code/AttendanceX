import 'package:flutter/material.dart';
import '../models/dashboard_state.dart';

class QuickStatsRow extends StatelessWidget {
  final QuickStats quickStats;

  const QuickStatsRow({super.key, required this.quickStats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard(
            context,
            title: 'Today',
            attended: quickStats.attendedToday,
            total: quickStats.totalToday,
            icon: Icons.calendar_today_rounded,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            context,
            title: 'This Week',
            attended: quickStats.attendedThisWeek,
            total: quickStats.totalThisWeek,
            icon: Icons.bar_chart_rounded,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            context,
            title: 'This Month',
            attended: quickStats.attendedThisMonth,
            total: quickStats.totalThisMonth,
            icon: Icons.date_range_rounded,
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
    
    final progress = total > 0 ? (attended / total) : 0.0;

    return Expanded(
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF16162C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF28284A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF7E73FF),
                ),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$attended / $total',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7E73FF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

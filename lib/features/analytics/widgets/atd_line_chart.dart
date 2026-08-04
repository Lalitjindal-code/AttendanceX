import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/monthly_trend.dart';
class AtdLineChart extends StatelessWidget {
  final List<MonthlyTrend> trends;

  const AtdLineChart({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No trend data available.'),
        ),
      );
    }

    // Ensure we have at least 2 points to draw a line, if only 1, we can duplicate it or just draw a dot.
    final displayTrends = trends.length == 1 
        ? [trends.first, trends.first] // Duplicate to draw a straight flat line
        : trends;

    final spots = displayTrends.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.percentage * 100);
    }).toList();

    final firstTrend = displayTrends.first;
    final lastTrend = displayTrends.last;
    final firstMonthStr = DateFormat('MMM yyyy').format(DateTime(firstTrend.year, firstTrend.month));
    final lastMonthStr = DateFormat('MMM yyyy').format(DateTime(lastTrend.year, lastTrend.month));
    final semanticLabel = 'Attendance trend over ${displayTrends.length} months. '
        'From $firstMonthStr at ${(firstTrend.percentage * 100).toStringAsFixed(1)}% '
        'to $lastMonthStr at ${(lastTrend.percentage * 100).toStringAsFixed(1)}%.';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: semanticLabel,
      child: Container(
        height: 220,
        padding: const EdgeInsets.only(right: AppSpacing.md, left: AppSpacing.sm, top: AppSpacing.lg, bottom: AppSpacing.sm),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) => FlLine(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= displayTrends.length) return const SizedBox.shrink();
                    final trend = displayTrends[index];
                    final date = DateTime(trend.year, trend.month);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MMM').format(date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 25,
                  getTitlesWidget: (value, meta) {
                    if (value % 25 != 0) return const SizedBox();
                    return Text(
                      '${value.toInt()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (displayTrends.length - 1).toDouble(),
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: theme.colorScheme.primary,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: theme.colorScheme.surface,
                      strokeWidth: 2,
                      strokeColor: theme.colorScheme.primary,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                      theme.colorScheme.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

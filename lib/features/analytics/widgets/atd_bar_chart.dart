import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/subject_statistics.dart';

class AtdBarChart extends StatelessWidget {
  final List<SubjectStatistics> stats;

  const AtdBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.md),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
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
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < stats.length) {
                    final subject = stats[value.toInt()].subject;
                    // truncate name to 3 letters for the chart
                    final shortName = subject.name.length > 3 ? subject.name.substring(0, 3) : subject.name;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        shortName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
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
          barGroups: stats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            final percentage = stat.summary.attendancePercentage;
            
            final color = Color(stat.subject.colorValue);

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: percentage,
                  color: color,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

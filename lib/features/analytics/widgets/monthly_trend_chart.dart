import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:attendancex/features/analytics/models/monthly_trend.dart';
import 'package:intl/intl.dart';

class MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyTrend> trends;

  const MonthlyTrendChart({super.key, required this.trends});

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
    final firstMonthStr = DateFormat('MMM yyyy')
        .format(DateTime(firstTrend.year, firstTrend.month));
    final lastMonthStr = DateFormat('MMM yyyy')
        .format(DateTime(lastTrend.year, lastTrend.month));
    final semanticLabel =
        'Attendance trend over ${displayTrends.length} months. '
        'From $firstMonthStr at ${(firstTrend.percentage * 100).toStringAsFixed(1)}% '
        'to $lastMonthStr at ${(lastTrend.percentage * 100).toStringAsFixed(1)}%.';

    return Semantics(
      label: semanticLabel,
      child: AspectRatio(
        aspectRatio: 1.7,
        child: Padding(
          padding:
              const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 20,
                verticalInterval: 1,
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= displayTrends.length)
                        return const SizedBox.shrink();
                      final trend = displayTrends[index];
                      final date = DateTime(trend.year, trend.month);
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%',
                          style: const TextStyle(fontSize: 10));
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d)),
              ),
              minX: 0,
              maxX: (displayTrends.length - 1).toDouble(),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

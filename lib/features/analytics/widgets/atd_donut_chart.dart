import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_spacing.dart';
import 'package:attendancex/features/dashboard/models/attendance_summary.dart';

class AtdDonutChart extends StatefulWidget {
  final OverallAttendanceSummary summary;

  const AtdDonutChart({super.key, required this.summary});

  @override
  State<AtdDonutChart> createState() => _AtdDonutChartState();
}

class _AtdDonutChartState extends State<AtdDonutChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final presentCount = widget.summary.totalPresentRecords;
    final absentCount = widget.summary.totalAbsentRecords;
    final otherCount = widget.summary.totalMedicalRecords + widget.summary.totalHolidayRecords + widget.summary.totalGTRecords;

    final total = presentCount + absentCount + otherCount;
    if (total == 0) return const SizedBox();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: presentCount.toDouble(),
                  title: touchedIndex == 0 ? '$presentCount\nPresent' : '',
                  titleStyle: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  radius: touchedIndex == 0 ? 30.0 : 20.0,
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: absentCount.toDouble(),
                  title: touchedIndex == 1 ? '$absentCount\nAbsent' : '',
                  titleStyle: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  radius: touchedIndex == 1 ? 30.0 : 20.0,
                ),
                if (otherCount > 0)
                  PieChartSectionData(
                    color: Colors.blue,
                    value: otherCount.toDouble(),
                    title: touchedIndex == 2 ? '$otherCount\nOther' : '',
                    titleStyle: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    radius: touchedIndex == 2 ? 30.0 : 20.0,
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.summary.attendancePercentage.toInt()}%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Overall',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

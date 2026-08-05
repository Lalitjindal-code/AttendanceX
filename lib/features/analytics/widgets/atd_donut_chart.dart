import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_spacing.dart';
import 'package:attendify/features/dashboard/models/attendance_summary.dart';

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

    final presentCount = widget.summary.totalPresentRecords;
    final absentCount = widget.summary.totalAbsentRecords;
    final otherCount = widget.summary.totalMedicalRecords +
        widget.summary.totalHolidayRecords +
        widget.summary.totalGTRecords;

    final total = presentCount + absentCount + otherCount;
    if (total == 0) return const SizedBox();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF16162C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 4,
              centerSpaceRadius: 65,
              sections: [
                PieChartSectionData(
                  color: const Color(0xFF00E676),
                  value: presentCount.toDouble(),
                  title: touchedIndex == 0 ? '$presentCount\nPresent' : '',
                  titleStyle: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  radius: touchedIndex == 0 ? 35.0 : 25.0,
                  badgeWidget: touchedIndex == 0 ? const _Badge(icon: Icons.check, color: Color(0xFF00E676)) : null,
                  badgePositionPercentageOffset: .98,
                ),
                PieChartSectionData(
                  color: const Color(0xFFFF5252),
                  value: absentCount.toDouble(),
                  title: touchedIndex == 1 ? '$absentCount\nAbsent' : '',
                  titleStyle: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  radius: touchedIndex == 1 ? 35.0 : 25.0,
                  badgeWidget: touchedIndex == 1 ? const _Badge(icon: Icons.close, color: Color(0xFFFF5252)) : null,
                  badgePositionPercentageOffset: .98,
                ),
                if (otherCount > 0)
                  PieChartSectionData(
                    color: const Color(0xFF448AFF),
                    value: otherCount.toDouble(),
                    title: touchedIndex == 2 ? '$otherCount\nOther' : '',
                    titleStyle: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    radius: touchedIndex == 2 ? 35.0 : 25.0,
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.summary.attendancePercentage.toInt()}%',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Overall',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _Badge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B13),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      padding: const EdgeInsets.all(4),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

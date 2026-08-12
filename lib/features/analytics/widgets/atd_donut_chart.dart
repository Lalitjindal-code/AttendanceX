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
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
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
                      fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  radius: touchedIndex == 0 ? 35.0 : 25.0,
                  badgeWidget: touchedIndex == 0 ? const _Badge(icon: Icons.check, color: Color(0xFF00E676)) : null,
                  badgePositionPercentageOffset: .98,
                ),
                PieChartSectionData(
                  color: const Color(0xFFFF5252),
                  value: absentCount.toDouble(),
                  title: touchedIndex == 1 ? '$absentCount\nAbsent' : '',
                  titleStyle: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
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
                        fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
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
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Overall',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      padding: const EdgeInsets.all(4),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

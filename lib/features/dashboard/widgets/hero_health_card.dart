import 'package:flutter/material.dart';
import '../models/dashboard_state.dart';
import '../models/smart_suggestion.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroHealthCard extends StatelessWidget {
  final DashboardState state;

  const HeroHealthCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final summary = state.overallSummary;
    final suggestion = state.overallSuggestion;
    
    final double percentage = summary?.attendancePercentage ?? 0.0;
    
    Color statusColor = Theme.of(context).colorScheme.primary;
    String statusText = 'No Data';
    IconData statusIcon = Icons.info_outline;

    if (suggestion != null) {
      switch (suggestion.type) {
        case SmartSuggestionType.safeBunk:
          statusColor = Colors.green;
          statusText = 'Safe Zone';
          statusIcon = Icons.check_circle;
          break;
        case SmartSuggestionType.attendMore:
          statusColor = Theme.of(context).colorScheme.error;
          statusText = 'At Risk';
          statusIcon = Icons.warning_amber_rounded;
          break;
        case SmartSuggestionType.onTrack:
          statusColor = Colors.blue;
          statusText = 'On Track';
          statusIcon = Icons.track_changes;
          break;
        case SmartSuggestionType.noData:
          statusColor = Colors.grey;
          statusText = 'No Data';
          statusIcon = Icons.info_outline;
          break;
      }
    }

    return Semantics(
      label: 'Overall Attendance: ${(percentage * 100).toInt()}%. Status: $statusText',
      container: true,
      excludeSemantics: true,
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surfaceContainerHigh,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side: Progress donut
          SizedBox(
            width: 80,
            height: 80,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: summary == null || summary.effectiveTotal == 0 ? 0.0 : percentage),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: value / 100.0,
                      strokeWidth: 8,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      color: statusColor,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '${value.toStringAsFixed(1)}%',
                        style: GoogleFonts.jetBrainsMono(
                          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 24),
          // Right side: Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Overall Attendance',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: percentage),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '${value.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    );
                  }
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

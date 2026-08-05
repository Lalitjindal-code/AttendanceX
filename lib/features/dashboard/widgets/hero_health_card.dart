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

    Color statusColor = const Color(0xFF7E73FF);
    String statusText = 'No Data';
    IconData statusIcon = Icons.info_outline;

    if (suggestion != null) {
      switch (suggestion.type) {
        case SmartSuggestionType.safeBunk:
          statusColor = Colors.greenAccent;
          statusText = 'Safe Zone';
          statusIcon = Icons.check_circle_outline;
          break;
        case SmartSuggestionType.attendMore:
          statusColor = const Color(0xFFFF5F5F);
          statusText = 'At Risk';
          statusIcon = Icons.warning_amber_rounded;
          break;
        case SmartSuggestionType.onTrack:
          statusColor = const Color(0xFF42A5F5);
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
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3F2B96),
              Color(0xFF1B1B3A),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3F2B96).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Left side: Large Progress donut
                SizedBox(
                  width: 120,
                  height: 120,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                        begin: 0.0,
                        end: summary == null || summary.effectiveTotal == 0 ? 0.0 : percentage),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: value / 100.0,
                            strokeWidth: 10,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            color: const Color(0xFF7E73FF),
                            strokeCap: StrokeCap.round,
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${value.toStringAsFixed(1)}%',
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Attendance',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 32),
                // Right side: Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Overall Attendance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: percentage),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              '${value.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            );
                          }),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
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
            if (suggestion != null && suggestion.type != SmartSuggestionType.noData) ...[
              const SizedBox(height: 24),
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

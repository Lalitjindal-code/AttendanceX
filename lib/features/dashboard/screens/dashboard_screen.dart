import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/lecture_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/dashboard_header.dart';
import '../../../core/enums/attendance_status.dart';
import '../models/smart_suggestion.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateStream = ref.watch(dashboardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
      ),
      body: stateStream.when(
        data: (state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: DashboardHeader(),
              ),
              // Overall Summary Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: _buildOverallProgress(context, state),
                  ),
                ),
              ),

              // Calculate pending and marked from state directly
              ...() {
                final pendingLectures = state.pendingLectures;
                final markedLectures = state.markedLectures;

                return [
                  // Today's Progress
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Today's Progress",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: state.todayProgressPercentage,
                                  ),
                                  builder: (context, value, child) {
                                    return Text(
                                      '${(value * 100).toInt()}%',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              tween: Tween<double>(
                                begin: 0,
                                end: state.todayProgressPercentage,
                              ),
                              builder: (context, value, child) {
                                return LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  minHeight: 8,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                state.todayProgressText,
                                key: ValueKey(state.todayProgressText),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Today's Schedule Header
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Text(
                        "Pending Classes",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Pending Schedule List
                  if (pendingLectures.isEmpty && markedLectures.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "No lectures scheduled for today.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  else if (pendingLectures.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "All caught up for today! 🎉",
                            style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          children: pendingLectures.map((lecture) {
                            return LectureCard(
                              key: ValueKey('pending_${lecture.schedule.id}'),
                              model: lecture,
                              onMarkAttendance: (status) {
                                ref.read(dashboardNotifierProvider.notifier).markAttendance(
                                  lecture.schedule.id,
                                  lecture.subject.id,
                                  status,
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                  // Marked Classes Header
                  if (markedLectures.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
                        child: Text(
                          "Marked Classes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                  // Marked Classes List
                  if (markedLectures.isNotEmpty)
                    SliverToBoxAdapter(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          children: markedLectures.map((lecture) {
                            return LectureCard(
                              key: ValueKey('marked_${lecture.schedule.id}'),
                              model: lecture,
                              onMarkAttendance: (status) {
                                ref.read(dashboardNotifierProvider.notifier).markAttendance(
                                  lecture.schedule.id,
                                  lecture.subject.id,
                                  status,
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ];
              }(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildOverallProgress(BuildContext context, state) {
    final summary = state.overallSummary;
    final suggestion = state.overallSuggestion;

    if (summary == null || summary.effectiveTotal == 0) {
      return const Column(
        children: [
          Icon(Icons.insights, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No attendance data yet.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      );
    }

    Color ringColor = Colors.blue;
    if (suggestion != null) {
      switch (suggestion.type) {
        case SmartSuggestionType.safeBunk:
          ringColor = Colors.green;
          break;
        case SmartSuggestionType.attendMore:
          ringColor = Colors.orange;
          break;
        case SmartSuggestionType.onTrack:
          ringColor = Colors.blue;
          break;
        case SmartSuggestionType.noData:
          ringColor = Colors.grey;
          break;
      }
    }

    return ProgressRing(
      percentage: summary.attendancePercentage,
      title: 'Overall',
      subtitle: suggestion?.message ?? '',
      color: ringColor,
    );
  }
}

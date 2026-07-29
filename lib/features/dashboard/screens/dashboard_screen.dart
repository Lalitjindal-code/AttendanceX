import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/lecture_card.dart';
import '../widgets/progress_ring.dart';
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
              // Overall Summary Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: _buildOverallProgress(context, state),
                  ),
                ),
              ),

              // Today's Schedule Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    "Today's Schedule",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Today's Schedule List
              if (state.todaysLectures.isEmpty)
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
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final lecture = state.todaysLectures[index];
                      return LectureCard(
                        model: lecture,
                        onMarkAttendance: (status) {
                          ref.read(dashboardNotifierProvider.notifier).markAttendance(
                            lecture.schedule.id,
                            lecture.subject.id,
                            status,
                          );
                        },
                      );
                    },
                    childCount: state.todaysLectures.length,
                  ),
                ),
                
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
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

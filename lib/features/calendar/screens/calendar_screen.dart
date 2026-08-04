import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/attendance_status.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../models/calendar_state.dart';
import '../providers/calendar_provider.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/day_detail_panel.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarStateAsync = ref.watch(calendarNotifierProvider);

    return Scaffold(
      body: calendarStateAsync.when(
        data: (state) {
          return CustomScrollView(
            slivers: [
              const SliverAppBar.large(
                title: Text('Calendar'),
                floating: true,
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: CalendarWidget(state: state),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Divider(),
                ),
              ),
              DayDetailPanel(state: state),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showAddManualAttendanceDialog(
      BuildContext context, WidgetRef ref, CalendarState state, DateTime date) {
    if (state.allSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subjects available. Please add a subject first.')),
      );
      return;
    }

    Subject? selectedSubject;
    AttendanceStatus? selectedStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Manual Attendance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Subject>(
                    key: const Key('subject_dropdown'),
                    decoration: const InputDecoration(labelText: 'Subject'),
                    value: selectedSubject,
                    items: state.allSubjects.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedSubject = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AttendanceStatus>(
                    key: const Key('status_dropdown'),
                    decoration: const InputDecoration(labelText: 'Status'),
                    value: selectedStatus,
                    items: AttendanceStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedStatus = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: selectedSubject != null && selectedStatus != null
                      ? () {
                          final repo = ref.read(attendanceRepositoryProvider);
                          final att = Attendance()
                            ..subjectId = selectedSubject!.id
                            ..scheduleId = -1
                            ..date = DateTime(date.year, date.month, date.day)
                            ..status = selectedStatus!;
                          repo.upsertAttendance(att);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

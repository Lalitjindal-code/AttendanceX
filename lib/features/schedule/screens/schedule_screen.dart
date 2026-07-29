import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/day_of_week.dart';
import '../../../navigation/app_routes.dart';
import '../../subjects/providers/subject_providers.dart';
import '../providers/schedule_providers.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentDayIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scheduleTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: DayOfWeek.values.map((day) => Tab(text: day.shortLabel)).toList(),
        ),
      ),
      body: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No subjects available.\nPlease create a subject first.', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.subjects), // Assuming they go to subjects tab to add
                    child: const Text('Go to Subjects'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: DayOfWeek.values.map((day) => _DayScheduleView(dayOfWeek: day.value)).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: subjectsAsync.maybeWhen(
        data: (subjects) => subjects.isNotEmpty
            ? FloatingActionButton(
                onPressed: () {
                  context.push('${AppRoutes.schedule}/${AppRoutes.scheduleForm}?day=${DayOfWeek.values[_currentDayIndex].value}');
                },
                child: const Icon(Icons.add),
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}

class _DayScheduleView extends ConsumerWidget {
  final int dayOfWeek;

  const _DayScheduleView({required this.dayOfWeek});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesForDayProvider(dayOfWeek));

    return schedulesAsync.when(
      data: (schedules) {
        if (schedules.isEmpty) {
          return const Center(child: Text('No classes scheduled for this day.'));
        }
        
        return ReorderableListView.builder(
          itemCount: schedules.length,
          onReorder: (oldIndex, newIndex) async {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final mutableSchedules = List.of(schedules);
            final item = mutableSchedules.removeAt(oldIndex);
            mutableSchedules.insert(newIndex, item);
            
            final ids = mutableSchedules.map((e) => e.id).toList();
            await ref.read(scheduleRepositoryProvider).updateOrder(ids);
          },
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            final subjectAsync = ref.watch(subjectProvider(schedule.subjectId));

            return Card(
              key: ValueKey(schedule.id),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: subjectAsync.when(
                  data: (subject) => Text(subject?.name ?? 'Unknown Subject'),
                  loading: () => const Text('Loading...'),
                  error: (_, __) => const Text('Error loading subject'),
                ),
                subtitle: Text('${schedule.startTime} - ${schedule.endTime} • ${schedule.type.name}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.drag_handle, color: Colors.grey),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                         context.push('${AppRoutes.schedule}/${AppRoutes.scheduleForm}?id=${schedule.id}');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

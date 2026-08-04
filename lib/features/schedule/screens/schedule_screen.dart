import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/day_of_week.dart';
import '../../../navigation/app_routes.dart';
import '../../subjects/providers/subject_providers.dart';
import '../providers/schedule_providers.dart';
import '../widgets/day_selector_pills.dart';
import '../widgets/schedule_timeline_card.dart';
import 'schedule_form_screen.dart';
import '../../../core/utils/haptics.dart';
import 'package:flutter/rendering.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentDayIndex = 0;
  bool _isFabExtended = true;

  @override
  void initState() {
    super.initState();
    // Default to today if it's a weekday, otherwise Monday
    final today = DateTime.now().weekday;
    if (today >= 1 && today <= 5) {
      _currentDayIndex = today - 1;
    } else {
      _currentDayIndex = 0;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == 
        ScrollDirection.reverse) {
      if (_isFabExtended) {
        setState(() => _isFabExtended = false);
      }
    } else if (_scrollController.position.userScrollDirection == 
        ScrollDirection.forward) {
      if (!_isFabExtended) {
        setState(() => _isFabExtended = true);
      }
    }
  }

  Future<void> _onRefresh() async {
    Haptics.selection();
    ref.invalidate(subjectsProvider);
    ref.invalidate(schedulesForDaySortedByTimeProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
          SliverAppBar.large(
            title: const Text(AppStrings.scheduleTitle),
            floating: true,
            pinned: true,
            actions: [
              if (subjectsAsync.valueOrNull?.isNotEmpty == true)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => showScheduleFormSheet(context, dayOfWeek: DayOfWeek.weekdays[_currentDayIndex].value),
                ),
            ],
          ),
          
          subjectsAsync.when(
            data: (subjects) {
              if (subjects.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 72,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            "No subjects available.\nPlease create a subject first.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          FilledButton.icon(
                            onPressed: () => context.go(AppRoutes.subjects),
                            icon: const Icon(Icons.add),
                            label: const Text('Go to Subjects'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  DaySelectorPills(
                    days: DayOfWeek.weekdays,
                    selectedDayIndex: _currentDayIndex,
                    onDaySelected: (index) {
                      setState(() {
                        _currentDayIndex = index;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DayScheduleView(dayOfWeek: DayOfWeek.weekdays[_currentDayIndex].value),
                  const SizedBox(height: 80),
                ]),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      ),
      floatingActionButton: subjectsAsync.maybeWhen(
        data: (subjects) => subjects.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => showScheduleFormSheet(context, dayOfWeek: DayOfWeek.weekdays[_currentDayIndex].value),
                icon: const Icon(Icons.add),
                label: const Text('Add Class'),
                isExtended: _isFabExtended,
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
    // We use sorted by time for timeline view
    final schedulesAsync = ref.watch(schedulesForDaySortedByTimeProvider(dayOfWeek));

    return schedulesAsync.when(
      data: (schedules) {
        if (schedules.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No classes scheduled for today.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: List.generate(schedules.length, (index) {
              final schedule = schedules[index];
              final subjectAsync = ref.watch(subjectProvider(schedule.subjectId));
              
              return subjectAsync.when(
                data: (subject) {
                  if (subject == null) return const SizedBox.shrink();
                  
                  return ScheduleTimelineCard(
                    schedule: schedule,
                    subject: subject,
                    isFirst: index == 0,
                    isLast: index == schedules.length - 1,
                    onEdit: () => showScheduleFormSheet(context, scheduleId: schedule.id, dayOfWeek: dayOfWeek),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading subject'),
              );
            }),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(child: Text('Error: $err')),
      ),
    );
  }
}

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
import '../../../core/widgets/banner_ad_widget.dart';

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
    ref.invalidate(allSchedulesProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B13),
      body: RefreshIndicator(
        color: const Color(0xFF7E73FF),
        backgroundColor: const Color(0xFF16162C),
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar.large(
              title: const Text(AppStrings.scheduleTitle, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              floating: true,
              pinned: true,
              backgroundColor: const Color(0xFF0B0B13),
              surfaceTintColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                if (subjectsAsync.valueOrNull?.isNotEmpty == true)
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'Add Class',
                    onPressed: () => showScheduleFormSheet(context,
                        dayOfWeek: DayOfWeek.weekdays[_currentDayIndex].value),
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
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16162C),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7E73FF).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  size: 48,
                                  color: Color(0xFF7E73FF),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'No subjects available',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Please create a subject first to build your schedule.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              FilledButton.icon(
                                onPressed: () => context.go(AppRoutes.subjects),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF7E73FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Go to Subjects'),
                              ),
                            ],
                          ),
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
                    _DayScheduleView(
                        dayOfWeek: DayOfWeek.weekdays[_currentDayIndex].value),
                    const SizedBox(height: 16),
                    const BannerAdWidget(),
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
      floatingActionButton: subjectsAsync.valueOrNull?.isNotEmpty == true
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E2DE2).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                heroTag: 'schedule_fab',
                backgroundColor: Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                onPressed: () => showScheduleFormSheet(context,
                    dayOfWeek: DayOfWeek.weekdays[_currentDayIndex].value),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Class', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                isExtended: _isFabExtended,
              ),
            )
          : null,
    );
  }
}

class _DayScheduleView extends ConsumerWidget {
  final int dayOfWeek;

  const _DayScheduleView({required this.dayOfWeek});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We use allSchedules to avoid loading states when changing days
    final schedulesAsync = ref.watch(allSchedulesProvider);

    if (schedulesAsync.hasValue) {
      final allSchedules = schedulesAsync.requireValue;
      final schedules = allSchedules
          .where((s) => s.dayOfWeek == dayOfWeek)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

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
            final subjectsAsync = ref.watch(subjectsProvider);

            if (!subjectsAsync.hasValue) return const SizedBox.shrink();
            final subjectList = subjectsAsync.requireValue;

            final subjectIndex =
                subjectList.indexWhere((s) => s.id == schedule.subjectId);
            if (subjectIndex == -1) return const SizedBox.shrink();
            final subject = subjectList[subjectIndex];

            return ScheduleTimelineCard(
              schedule: schedule,
              subject: subject,
              isFirst: index == 0,
              isLast: index == schedules.length - 1,
              onEdit: () => showScheduleFormSheet(context,
                  scheduleId: schedule.id, dayOfWeek: dayOfWeek),
            );
          }),
        ),
      );
    } else if (schedulesAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (schedulesAsync.hasError) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(child: Text('Error: ${schedulesAsync.error}')),
      );
    }

    return const SizedBox.shrink();
  }
}

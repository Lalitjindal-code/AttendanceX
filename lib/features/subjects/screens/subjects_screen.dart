import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/subject_providers.dart';
import 'subject_form_screen.dart'; // Which now contains the sheet
import '../widgets/subject_card.dart';
import '../widgets/subject_card_skeleton.dart';
import '../../../core/utils/haptics.dart';
import 'package:flutter/rendering.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabExtended = true;

  @override
  void initState() {
    super.initState();
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
            const SliverAppBar.large(
              title: Text(AppStrings.subjectsTitle),
              floating: true,
              pinned: true,
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
                              Icons.library_books_outlined,
                              size: 72,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              AppStrings.subjectsEmpty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            FilledButton.icon(
                              onPressed: () => showSubjectFormSheet(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Subject'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final delay = index * 100;
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            // Simple delay logic
                            if (value == 0.0) {
                              Future.delayed(Duration(milliseconds: delay), () {
                                if (context.mounted) {
                                  // Trigger rebuild but TweenAnimationBuilder manages its own animation so this trick isn't perfect.
                                  // Instead we can animate the transform with a staggered begin value if we write a custom implicit animation,
                                  // but for simplicity TweenAnimationBuilder starting immediately with a translation looks fine.
                                }
                              });
                            }
                            // Better staggered approach with tween:
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: SubjectCard(subject: subjects[index]),
                              ),
                            );
                          },
                        );
                      },
                      childCount: subjects.length,
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const SubjectCardSkeleton(),
                    childCount: 6,
                  ),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $error')),
              ),
            ),
            // Bottom padding to ensure last item is not hidden behind the bottom nav bar or FAB
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSubjectFormSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
        tooltip: 'Add Subject',
        isExtended: _isFabExtended,
      ),
    );
  }
}

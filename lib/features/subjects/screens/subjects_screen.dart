import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/subject_providers.dart';
import 'subject_form_screen.dart'; // Which now contains the sheet
import '../widgets/subject_card.dart';
import '../widgets/subject_card_skeleton.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/widgets/native_ad_widget.dart';
import '../../../core/ads/providers/ad_free_provider.dart';
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
    final isAdFree = ref.watch(adFreeProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: const Color(0xFF7E73FF),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          cacheExtent: 500, // Pre-render more items for smooth fast scrolling
          slivers: [
            SliverAppBar(
              title: Text('Subjects',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold)),
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: Icon(Icons.add,
                      color: Theme.of(context).colorScheme.onSurface),
                  tooltip: 'Add Subject',
                  onPressed: () => showSubjectFormSheet(context),
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
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7E73FF)
                                      .withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.library_books_rounded,
                                  size: 48,
                                  color: Color(0xFF7E73FF),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'No Subjects Yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Add your first subject to start tracking attendance.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              FilledButton.icon(
                                onPressed: () => showSubjectFormSheet(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Add Subject'),
                              ),
                            ],
                          ),
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
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final showNativeAd = !isAdFree && subjects.length >= 2;

                        if (showNativeAd && index == 2) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: const NativeAdWidget(),
                          )
                              .animate(
                                  delay: Duration(milliseconds: 60 * index))
                              .fadeIn(
                                  duration: 350.ms, curve: Curves.easeOutQuad)
                              .slideY(
                                  begin: 0.12,
                                  duration: 350.ms,
                                  curve: Curves.easeOutQuad);
                        }

                        final subjectIndex =
                            showNativeAd && index > 2 ? index - 1 : index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: RepaintBoundary(
                            child: SubjectCard(subject: subjects[subjectIndex]),
                          ),
                        )
                            .animate(delay: Duration(milliseconds: 60 * index))
                            .fadeIn(duration: 350.ms, curve: Curves.easeOutQuad)
                            .slideY(
                                begin: 0.12,
                                duration: 350.ms,
                                curve: Curves.easeOutQuad);
                      },
                      childCount: subjects.length +
                          (!isAdFree && subjects.length >= 2 ? 1 : 0),
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: SubjectCardSkeleton(),
                    ),
                    childCount: 4,
                  ),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                    child: Text('Error: $error',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
              ),
            ),
            const SliverToBoxAdapter(
              child: BannerAdWidget(),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}

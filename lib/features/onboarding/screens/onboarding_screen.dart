import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../navigation/app_routes.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/onboarding_subject_form.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top action bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Skip'),
                    )
                  else
                    const SizedBox(height: 48), // Placeholder for alignment
                ],
              ),
            ),
            
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  OnboardingPage(
                    iconData: Icons.track_changes_outlined,
                    title: 'Never miss a class... unless you want to.',
                    subtitle: 'Set attendance goals, track your progress, and get smart suggestions on when it is safe to bunk.',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  OnboardingPage(
                    iconData: Icons.insert_chart_outlined,
                    title: 'Smart Analytics at your fingertips',
                    subtitle: 'Beautiful charts help you visualize your attendance trends across the entire semester.',
                    color: Colors.blue,
                  ),
                  OnboardingSubjectForm(
                    onComplete: _completeOnboarding,
                  ),
                ],
              ),
            ),
            
            // Bottom indicators and next button
            if (_currentPage < 2)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot indicators
                    Row(
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    
                    // Next Button
                    FloatingActionButton(
                      onPressed: _onNext,
                      elevation: 0,
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 100), // padding for form on last page
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../navigation/app_routes.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/onboarding_subject_form.dart';
import '../widgets/onboarding_semester_form.dart';
import '../widgets/onboarding_profile_form.dart';
import '../../college/providers/college_auth_provider.dart';

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

  void _onNext(int totalPages) {
    if (_currentPage < totalPages - 1) {
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
    final isCollegeUser = ref.watch(isCollegeUserProvider);
    // 4 tutorial pages + 2 or 3 forms
    final totalTutorialPages = 4;
    final totalPages = isCollegeUser ? totalTutorialPages + 2 : totalTutorialPages + 3;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top action bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage >= totalTutorialPages)
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
                    iconData: Icons.school_outlined,
                    title: 'Welcome to Attendify',
                    subtitle:
                        'Your ultimate companion to manage classes, track attendance, and stay on top of your academic schedule seamlessly.',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const OnboardingPage(
                    iconData: Icons.cloud_done_outlined,
                    title: 'Seamless Cloud Sync',
                    subtitle:
                        'Your data is now safely backed up to the cloud! Enjoy the new Dashboard with cleaner progress rings and insights.',
                    color: Colors.blue,
                  ),
                  const OnboardingPage(
                    iconData: Icons.groups_rounded,
                    title: 'Join Our Community',
                    subtitle:
                        'Connect with other students, share feedback, and get the latest updates by joining our WhatsApp community.',
                    color: Color(0xFF4CAF50),
                  ),
                  const OnboardingPage(
                    iconData: Icons.notifications_active_outlined,
                    title: 'Bunk Predictor & Reminders',
                    subtitle:
                        'Get smart suggestions on when it is safe to bunk, and never miss a class with timely notifications.',
                    color: Colors.orange,
                  ),
                  OnboardingProfileForm(
                    onComplete: () => _onNext(totalPages),
                  ),
                  OnboardingSemesterForm(
                    onComplete: isCollegeUser ? _completeOnboarding : () => _onNext(totalPages),
                  ),
                  if (!isCollegeUser)
                    OnboardingSubjectForm(
                      onComplete: _completeOnboarding,
                    ),
                ],
              ),
            ),

            // Bottom indicators and next button
            if (_currentPage < totalTutorialPages)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot indicators
                    Row(
                      children: List.generate(
                        totalPages,
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
                      heroTag: 'onboarding_fab',
                      onPressed: () => _onNext(totalPages),
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

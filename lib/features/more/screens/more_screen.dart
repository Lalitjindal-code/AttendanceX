import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_icons.dart';
import '../../../navigation/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/ads/interstitial_ad_manager.dart';
import '../../../core/ads/rewarded_ad_manager.dart';
import '../../../core/ads/app_open_ad_manager.dart';
import '../../../core/ads/providers/ad_free_provider.dart';
import '../../../core/ads/ad_eligibility_service.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  @override
  void initState() {
    super.initState();
    // Preload ads if not already loaded
    InterstitialAdManager.instance.loadAd();
    RewardedAdManager.instance.loadAd();
  }

  void _navigateWithInterstitial(String route, String feature) {
    InterstitialAdManager.instance.showAdIfAvailable(
      feature: feature,
      onNavigation: () {
        if (mounted) context.push(route);
      },
    );
  }

  void _showRewardedAd() {
    // Show a snackbar if ad is not ready
    if (!RewardedAdManager.instance.isLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Ad is still loading, please try again in a few seconds.')),
      );
      RewardedAdManager.instance.loadAd(); // Force preload attempt
      return;
    }

    RewardedAdManager.instance.showAdIfAvailable(
      onRewardEarned: () {
        AdEligibilityService.grantReward();
        ref.read(adFreeProvider.notifier).refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Thank you! Ads have been removed for 24 hours.')),
          );
        }
      },
      onCompletion: () {
        // Handle dismissal
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isAdFree = ref.watch(adFreeProvider);
    final isAdmin = user?.email == 'lalitjindal519@gmail.com';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('More',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          if (user != null) _buildProfileCard(context, user),
          const SizedBox(height: 32),
          _buildMenuCard(
            context: context,
            icon: AppIcons.calendar,
            iconColor: const Color(0xFF42A5F5),
            title: 'Calendar',
            onTap: () => context.push(AppRoutes.calendar),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context: context,
            icon: AppIcons.analytics,
            iconColor: const Color(0xFFAB47BC),
            title: 'Analytics',
            onTap: () => _navigateWithInterstitial(AppRoutes.analytics, 'analytics'),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context: context,
            icon: Icons.psychology_outlined,
            iconColor: Colors.orangeAccent,
            title: 'Bunk Simulator & Predictor',
            onTap: () => _navigateWithInterstitial(AppRoutes.bunkSimulator, 'bunk_simulator'),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context: context,
            icon: AppIcons.settings,
            iconColor: const Color(0xFF7E73FF),
            title: 'Settings',
            onTap: () => context.push(AppRoutes.settings),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 24),
            Text(
              'ADMIN DASHBOARD',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context: context,
              icon: Icons.people_alt_rounded,
              iconColor: const Color(0xFF3949AB),
              title: 'Registered Users',
              onTap: () => context.push(AppRoutes.adminUsers),
            ),
            const SizedBox(height: 24),
            Text(
              'ADMIN COMMUNICATION',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context: context,
              icon: Icons.chat_rounded,
              iconColor: const Color(0xFFE53935),
              title: 'Support Chats & Requests',
              onTap: () => context.push(AppRoutes.adminRequests),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context: context,
              icon: Icons.feedback_rounded,
              iconColor: const Color(0xFFFFA726),
              title: 'User Feedbacks',
              onTap: () => context.push(AppRoutes.adminFeedbacks),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context: context,
              icon: Icons.campaign_rounded,
              iconColor: const Color(0xFF43A047),
              title: 'Notification Center',
              onTap: () => context.push(AppRoutes.adminReminders),
            ),
          ],
          if (!isAdFree) ...[
            const SizedBox(height: 24),
            _buildRemoveAdsCard(context),
          ],
          const SizedBox(height: 48),
          if (user != null) _buildLogOutButton(context, ref),
          const SizedBox(height: 24),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, User user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3F2B96),
            Color(0xFF1B1B3A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F2B96).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push(AppRoutes.profile),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF1D1743),
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person, color: Colors.white, size: 32)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Student Profile',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View Account Details',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveAdsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9A9E).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _showRewardedAd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remove Ads for 24h',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Watch a short video ad to remove all ads for 24 hours.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill_rounded,
                    color: Colors.white, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHigh,
            Theme.of(context).colorScheme.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogOutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () async {
          AppOpenAdManager.instance.isPaused = true;
          try {
            await ref.read(authProvider).signOut();
          } finally {
            AppOpenAdManager.instance.isPaused = false;
          }
          if (context.mounted) context.go(AppRoutes.login);
        },
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF5F5F)),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Color(0xFFFF5F5F),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFFFF5F5F).withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: const Color(0xFFFF5F5F).withValues(alpha: 0.15)),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/ads/app_open_ad_manager.dart';
import 'core/ads/app_lifecycle_reactor.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'database/isar_service.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'navigation/app_router.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'features/sync/services/firebase_sync_service.dart';
import 'features/security/widgets/app_lock_wrapper.dart';
import 'services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run critical initializations in parallel
  // Isar needs path_provider which is ready after ensureInitialized()
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    PreferencesService.instance.initialize(),
    IsarService.instance.initialize(),
  ]);

  // Non-blocking background initializations
  MobileAds.instance.initialize().then((_) {
    final appOpenAdManager = AppOpenAdManager()..loadAd();
    final appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    appLifecycleReactor.listenToAppStateChanges();
  });

  NotificationService.instance.init().then((_) {
    if (PreferencesService.instance.getBool('notificationsEnabled', defaultValue: true)) {
      NotificationService.instance.requestPermissions();
    }
  });

  WidgetService.instance.initialize().then((_) {
    WidgetService.instance.updateWidget();
  });

  runApp(
    const ProviderScope(
      child: AttendifyApp(),
    ),
  );
}

class AttendifyApp extends ConsumerWidget {
  const AttendifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the notification orchestrator alive and reacting to changes globally
    ref.listen(notificationOrchestratorProvider, (_, __) {});
    // Keep the Firebase sync orchestrator alive to watch local DB changes
    ref.listen(firebaseSyncOrchestratorProvider, (_, __) {});

    final router = ref.watch(appRouterProvider); // Generated router provider
    final settings = ref.watch(settingsProvider); // Watches ThemeMode changes

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light,
      darkTheme: settings.isAmoled ? AppTheme.amoled : AppTheme.dark,
      routerConfig: router,
      builder: (context, child) {
        return AppLockWrapper(child: child!);
      },
    );
  }
}

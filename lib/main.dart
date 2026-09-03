import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'database/isar_service.dart';
import 'database/repositories/subject_repository.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'navigation/app_router.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'features/sync/services/firebase_sync_service.dart';
import 'features/security/widgets/app_lock_wrapper.dart';
import 'services/widget_service.dart';
import 'package:home_widget/home_widget.dart';
import 'core/providers/firebase_provider.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && !Platform.isWindows) {
    await HomeWidget.registerInteractivityCallback(widgetInteractiveCallback);
    await HomeWidget.registerBackgroundCallback(widgetInteractiveCallback);
  }

  await Future.wait([
    PreferencesService.instance.initialize(),
    IsarService.instance.initialize(),
  ]);

  // Set Dark and AMOLED theme configuration as default on first startup launch
  final prefs = PreferencesService.instance;
  if (!prefs.containsKey(PreferencesService.keyThemeMode)) {
    await prefs.setString(PreferencesService.keyThemeMode, 'dark');
  }
  if (!prefs.containsKey(PreferencesService.keyIsAmoled)) {
    await prefs.setBool(PreferencesService.keyIsAmoled, true);
  }

  // Migration for existing users: disable tutorials if they've already onboarded
  if (prefs.getBool(PreferencesService.keyIsOnboardingComplete, defaultValue: false)) {
    if (!prefs.containsKey(PreferencesService.keyTutorialsMigrated)) {
      await Future.wait([
        prefs.setBool(PreferencesService.keyHasShownDashboardTutorial, true),
        prefs.setBool(PreferencesService.keyHasShownSubjectsTutorial, true),
        prefs.setBool(PreferencesService.keyHasShownPlannerTutorial, true),
        prefs.setBool(PreferencesService.keyHasShownScheduleTutorial, true),
        prefs.setBool(PreferencesService.keyHasShownMoreTutorial, true),
        prefs.setBool(PreferencesService.keyHasShownAnalyticsTutorial, true),
        prefs.setBool(PreferencesService.keyHasShownCalendarTutorial, true),
        prefs.setBool(PreferencesService.keyHasShownFeedbackTutorial, true),
        prefs.setBool(PreferencesService.keyHasShownBottomNavTutorial, true),
        prefs.setBool(PreferencesService.keyHasShownSettingsTutorial, true),
        prefs.setBool(PreferencesService.keyTutorialsMigrated, true),
      ]);
    }
  }

  runApp(
    const ProviderScope(
      child: AttendifyApp(),
    ),
  );

  // Defer non-critical background services to run after the first frame has painted
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final bool notificationsEnabled = PreferencesService.instance.getBool(
      PreferencesService.keyNotificationsEnabled,
      defaultValue: true,
    );

    if (notificationsEnabled) {
      NotificationService.instance.init().then((_) {
        NotificationService.instance.requestPermissions();
      });
    }

    // Run DB migrations asynchronously in background
    SubjectRepository(IsarService.instance.isar).migrateNotificationDefaults();

    WidgetService.instance.initialize().then((_) {
      WidgetService.instance.updateWidget();
    });
  });
}

class AttendifyApp extends ConsumerWidget {
  const AttendifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize Firebase in the background
    ref.listen(firebaseInitProvider, (_, __) {});
    // Keep the notification orchestrator alive and reacting to changes globally
    ref.listen(notificationOrchestratorProvider, (_, __) {});
    // Keep the Firebase sync orchestrator alive to watch local DB changes
    ref.listen(firebaseSyncOrchestratorProvider, (_, __) {});
    // Keep the FCM token orchestrator alive
    ref.listen(fcmTokenOrchestratorProvider, (_, __) {});

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

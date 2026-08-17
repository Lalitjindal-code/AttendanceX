import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'database/isar_service.dart';
import 'database/repositories/subject_repository.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'navigation/app_router.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'features/sync/services/firebase_sync_service.dart';
import 'features/security/widgets/app_lock_wrapper.dart';
import 'services/widget_service.dart';
import 'package:home_widget/home_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && !Platform.isWindows) {
    await HomeWidget.registerInteractivityCallback(widgetInteractiveCallback);
  }

  await Future.wait([
    (kIsWeb || !Platform.isWindows)
        ? Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform)
        : Future.value(null),
    PreferencesService.instance.initialize(),
    IsarService.instance.initialize(),
  ]);

  if (!kIsWeb && !Platform.isWindows) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Set Dark and AMOLED theme configuration as default on first startup launch
  final prefs = PreferencesService.instance;
  if (!prefs.containsKey(PreferencesService.keyThemeMode)) {
    await prefs.setString(PreferencesService.keyThemeMode, 'dark');
  }
  if (!prefs.containsKey(PreferencesService.keyIsAmoled)) {
    await prefs.setBool(PreferencesService.keyIsAmoled, true);
  }

  // One-time migration: fix notification defaults for subjects created before
  // classNotificationsEnabled / plannerNotificationsEnabled were added.
  // Isar sets new bool fields to false on old records; we force them to true.
  await SubjectRepository(IsarService.instance.isar)
      .migrateNotificationDefaults();

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

    WidgetService.instance.initialize().then((_) {
      WidgetService.instance.updateWidget();
    });
  });
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

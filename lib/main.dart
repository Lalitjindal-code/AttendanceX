import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'database/isar_service.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'navigation/app_router.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'features/sync/services/firebase_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. Initialize SharedPreferences singleton
  await PreferencesService.instance.initialize();

  // 2. Initialize Isar Database singleton
  await IsarService.instance.initialize();

  // 3. Initialize Notifications singleton
  await NotificationService.instance.init();

  runApp(
    const ProviderScope(
      child: AttendanceXApp(),
    ),
  );
}

class AttendanceXApp extends ConsumerWidget {
  const AttendanceXApp({super.key});

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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'database/isar_service.dart';
import 'features/settings/providers/settings_provider.dart';
import 'navigation/app_router.dart';
import 'services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize SharedPreferences singleton
  await PreferencesService.instance.initialize();

  // 2. Initialize Isar Database singleton
  await IsarService.instance.initialize();

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
    final router = ref.watch(appRouterProvider); // Generated router provider
    final settings = ref.watch(settingsProvider); // Watches ThemeMode changes

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}

import 'package:attendancex/core/enums/gt_mode.dart';
import 'package:attendancex/features/settings/screens/settings_screen.dart';
import 'package:attendancex/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendancex/features/settings/providers/settings_provider.dart';
import 'package:attendancex/features/settings/models/app_settings.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import '../helpers/golden_helper.dart';

class FakeEnabledSettings extends Settings {
  @override
  AppSettings build() => const AppSettings(
        notificationsEnabled: true,
        dailyReminderEnabled: true,
        dailyReminderTime: '20:00',
        lectureReminderMinutes: 10,
        defaultGoalPercentage: 75.0,
        semesterStartDate: null,
        semesterEndDate: null,
        gtMode: GtMode.exclude,
        medicalCountsAsPresent: false,
      );

  @override
  Future<void> updateDailyReminderTime(String time) async {
    state = state.copyWith(dailyReminderTime: time);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferencesService.keyDailyReminderTime, time);
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      PreferencesService.keyThemeMode: 'system',
      PreferencesService.keyDefaultGoal: 75.0,
      PreferencesService.keyMedicalCountsAsPresent: false,
      PreferencesService.keyGtMode: 'exclude',
      PreferencesService.keyNotificationsEnabled: true,
      PreferencesService.keyDailyReminderEnabled: true,
      PreferencesService.keyDailyReminderTime: '20:00',
      PreferencesService.keyLectureReminderMinutes: 10,
    });
    await PreferencesService.instance.initialize();
  });

  Widget createTestWidget({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  group('Settings Widget Tests', () {
    testWidgets('Theme switching works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('APPEARANCE'), findsOneWidget);

      // Switch to dark mode
      final darkFinder = find.text('Dark');
      await tester.dragUntilVisible(
          darkFinder, find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(darkFinder);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PreferencesService.keyThemeMode), 'dark');
    });

    testWidgets('Notification toggle updates state and preferences',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final masterSwitchFinder = find.ancestor(
        of: find.text('Master switch for all alerts'),
        matching: find.byType(SwitchListTile),
      );

      await tester.dragUntilVisible(
          masterSwitchFinder, find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(masterSwitchFinder);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PreferencesService.keyNotificationsEnabled), false);
    });

    testWidgets('GT mode selection works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final excludeFinder = find.text(GtMode.exclude.label);
      await tester.dragUntilVisible(
          excludeFinder, find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(excludeFinder, findsOneWidget);

      await tester.tap(excludeFinder);
      await tester.pumpAndSettle();

      final countAsPresentFinder = find.text(GtMode.countAsPresent.label).last;
      await tester.tap(countAsPresentFinder);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PreferencesService.keyGtMode),
          GtMode.countAsPresent.key);
    });

    testWidgets('Medical toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final medicalFinder = find.ancestor(
        of: find.text('Medical Leave (ML)'),
        matching: find.byType(SwitchListTile),
      );

      await tester.dragUntilVisible(
          medicalFinder, find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(medicalFinder);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PreferencesService.keyMedicalCountsAsPresent), true);
    });

    testWidgets('Goal percentage slider updates value',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('75%'), findsOneWidget);

      final sliderFinder = find.byType(Slider);
      await tester.dragUntilVisible(
          sliderFinder, find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(sliderFinder);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble(PreferencesService.keyDefaultGoal) != 0.75, true);
    });

    testWidgets('Daily Reminder time picker opens and sets time',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        overrides: [
          settingsProvider.overrideWith(() => FakeEnabledSettings()),
        ],
      ));
      await tester.pumpAndSettle();

      final textFinder = find.text('Daily Reminder Time');
      await tester.dragUntilVisible(
          textFinder, find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(textFinder);
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsWidgets);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(
          prefs.getString(PreferencesService.keyDailyReminderTime), isNotNull);
    });

    testWidgets('Settings text scale regression loop',
        (WidgetTester tester) async {
      final textScaleFactors = [1.0, 1.3, 1.5, 2.0];
      for (final scale in textScaleFactors) {
        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              );
            },
            home: const SettingsScreen(),
          ),
        ));
        await tester.pumpAndSettle();
        // Scroll around
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Settings Golden Tests', () {
    testGoldens('Settings UI matches golden', (tester) async {
      if (!isGoldenTestsSupported) return;
      await setupGoldenTests();

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: defaultDevices)
        ..addScenario(
          widget: const ProviderScope(
            child: SettingsScreen(),
          ),
          name: 'default_settings',
        );

      await tester.pumpDeviceBuilder(builder, wrapper: materialWrapper());
      await screenMatchesGolden(tester, 'settings_default');
    });
  });
}

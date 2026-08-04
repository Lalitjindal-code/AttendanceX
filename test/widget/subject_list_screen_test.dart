import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/features/subjects/providers/subject_providers.dart';
import 'package:attendancex/features/subjects/screens/subjects_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import '../helpers/golden_helper.dart';

void main() {
  Widget createWidget(List<Subject> mockSubjects) {
    return ProviderScope(
      overrides: [
        subjectsProvider.overrideWith((ref) => Stream.value(mockSubjects)),
      ],
      child: const MaterialApp(
        home: SubjectsScreen(),
      ),
    );
  }

  final mockSubject = Subject()
    ..name = 'Mathematics'
    ..credits = 4
    ..goalPercentage = 75.0
    ..colorValue = Colors.blue.value
    ..id = 1;

  group('Subject List Widget Tests', () {
    testWidgets('Subject list renders empty state', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget([]));
      await tester.pumpAndSettle();

      expect(find.text('No subjects yet'), findsOneWidget);
    });

    testWidgets('Subject list renders loaded state', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget([mockSubject]));
      await tester.pumpAndSettle();

      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('4 Credits • Goal: 75.0%'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    // Removed swipe test because SubjectListScreen no longer uses Slidable.

    testWidgets('Subject list text scale regression loop', (WidgetTester tester) async {
      final textScaleFactors = [1.0, 1.3, 1.5, 2.0];
      for (final scale in textScaleFactors) {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            subjectsProvider.overrideWith((ref) => Stream.value([mockSubject])),
          ],
          child: MaterialApp(
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              );
            },
            home: const SubjectsScreen(),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Subject List Golden Tests', () {
    testGoldens('Subject list UI matches golden', (tester) async {
      if (!isGoldenTestsSupported) return;
      await setupGoldenTests();

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: defaultDevices)
        ..addScenario(
          widget: createWidget([mockSubject]),
          name: 'loaded_state',
        );

      await tester.pumpDeviceBuilder(builder, wrapper: materialWrapper());
      await screenMatchesGolden(tester, 'subjects_loaded_state');
    });
  });
}

import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/features/schedule/providers/schedule_providers.dart';
import 'package:attendancex/features/subjects/providers/subject_providers.dart';
import 'package:attendancex/features/schedule/screens/schedule_screen.dart';
import 'package:attendancex/core/enums/lecture_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import '../helpers/golden_helper.dart';

void main() {
  Widget createWidget(List<Schedule> mockSchedules) {
    return ProviderScope(
      overrides: [
        schedulesForDaySortedByTimeProvider(1).overrideWith((ref) => Stream.value(mockSchedules)),
        schedulesForDaySortedByTimeProvider(2).overrideWith((ref) => Stream.value(mockSchedules)),
        schedulesForDaySortedByTimeProvider(3).overrideWith((ref) => Stream.value(mockSchedules)),
        schedulesForDaySortedByTimeProvider(4).overrideWith((ref) => Stream.value(mockSchedules)),
        schedulesForDaySortedByTimeProvider(5).overrideWith((ref) => Stream.value(mockSchedules)),
        subjectProvider(1).overrideWith((ref) => Future.value(Subject()..name = 'Math'..colorValue = Colors.blue.value..id = 1)),
        subjectsProvider.overrideWith((ref) => Stream.value([Subject()..name = 'Math'..colorValue = Colors.blue.value..id = 1])),
      ],
      child: const MaterialApp(
        home: ScheduleScreen(),
      ),
    );
  }

  final mockSchedule = Schedule()
    ..id = 1
    ..subjectId = 1
    ..type = LectureType.lecture
    ..startTime = '10:00'
    ..endTime = '11:00'
    ..dayOfWeek = 1;

  group('Schedule Widget Tests', () {
    testWidgets('Schedule renders empty state', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget([]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mon'));
      await tester.pumpAndSettle();

      expect(find.text('No classes scheduled for today.'), findsOneWidget);
    });

    testWidgets('Schedule renders loaded state and interacts with floating button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget([mockSchedule]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mon'));
      await tester.pumpAndSettle();

      expect(find.text('Math'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('11:00'), findsOneWidget);
      expect(find.text('LECTURE'), findsOneWidget);

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Schedule text scale factor regression loop', (WidgetTester tester) async {
      final textScaleFactors = [1.0, 1.3, 1.5, 2.0];

      for (final scale in textScaleFactors) {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            schedulesForDaySortedByTimeProvider(1).overrideWith((ref) => Stream.value([mockSchedule])),
            schedulesForDaySortedByTimeProvider(2).overrideWith((ref) => Stream.value([mockSchedule])),
            schedulesForDaySortedByTimeProvider(3).overrideWith((ref) => Stream.value([mockSchedule])),
            schedulesForDaySortedByTimeProvider(4).overrideWith((ref) => Stream.value([mockSchedule])),
            schedulesForDaySortedByTimeProvider(5).overrideWith((ref) => Stream.value([mockSchedule])),
            subjectProvider(1).overrideWith((ref) => Future.value(Subject()..name = 'Math'..colorValue = Colors.blue.value..id = 1)),
            subjectsProvider.overrideWith((ref) => Stream.value([Subject()..name = 'Math'..colorValue = Colors.blue.value..id = 1])),
          ],
          child: MaterialApp(
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              );
            },
            home: const ScheduleScreen(),
          ),
        ));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Mon'));
        await tester.pumpAndSettle();
        
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Schedule Golden Tests', () {
    testGoldens('Schedule UI matches golden', (tester) async {
      if (!isGoldenTestsSupported) return;
      await setupGoldenTests();

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: defaultDevices)
        ..addScenario(
          widget: createWidget([mockSchedule]),
          name: 'loaded_state',
        );

      await tester.pumpDeviceBuilder(builder, wrapper: materialWrapper());
      await screenMatchesGolden(tester, 'schedule_loaded_state');
    });
  });
}

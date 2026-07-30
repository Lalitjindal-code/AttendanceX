import 'dart:collection';
import 'package:attendancex/core/enums/attendance_status.dart';
import 'package:attendancex/core/enums/lecture_type.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/features/calendar/models/calendar_state.dart';
import 'package:attendancex/features/calendar/models/daily_attendance_details.dart';
import 'package:attendancex/features/calendar/models/daily_attendance_item.dart';
import 'package:attendancex/features/calendar/providers/calendar_provider.dart';
import 'package:attendancex/features/calendar/screens/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import '../helpers/golden_helper.dart';

class FakeCalendarNotifier extends CalendarNotifier {
  final CalendarState _mockState;

  bool wasManualAttendanceAdded = false;

  FakeCalendarNotifier(this._mockState);

  @override
  Stream<CalendarState> build() async* {
    yield _mockState;
  }

  @override
  Future<void> addManualAttendance(int subjectId, AttendanceStatus status) async {
    wasManualAttendanceAdded = true;
  }
}

void main() {
  final testDate = DateTime(2026, 1, 15);
  final subject = Subject()..id = 1..name = 'Physics'..colorValue = Colors.blue.value;
  
  final loadedState = CalendarState(
    selectedDate: testDate,
    focusedDate: testDate,
    attendanceMarkers: UnmodifiableMapView({
      testDate: [AttendanceStatus.present],
    }),
    selectedDayDetails: DailyAttendanceDetails(
      date: testDate,
      items: [
        DailyAttendanceItem(
          subject: subject,
          schedule: Schedule()..startTime = '10:00'..endTime = '11:00'..type = LectureType.lecture,
          attendance: Attendance()..status = AttendanceStatus.present,
          isManual: false,
        ),
      ],
    ),
    allSubjects: [subject],
    isLoading: false,
  );

  group('Calendar Widget Tests', () {
    testWidgets('Calendar renders empty selected day details', (WidgetTester tester) async {
      final state = CalendarState(
        selectedDate: testDate,
        focusedDate: testDate,
        attendanceMarkers: UnmodifiableMapView({}),
        selectedDayDetails: DailyAttendanceDetails(date: testDate),
        allSubjects: [],
        isLoading: false,
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [
          calendarNotifierProvider.overrideWith(() => FakeCalendarNotifier(state)),
        ],
        child: const MaterialApp(home: CalendarScreen()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No classes scheduled for January 15, 2026'), findsOneWidget);
    });

    testWidgets('Calendar manual attendance interactions (bottom sheet)', (WidgetTester tester) async {
      final fakeNotifier = FakeCalendarNotifier(loadedState);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          calendarNotifierProvider.overrideWith(() => fakeNotifier),
        ],
        child: const MaterialApp(home: CalendarScreen()),
      ));
      await tester.pumpAndSettle();

      // Tap floating action button to add manual attendance
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add Manual Attendance'), findsOneWidget);
      expect(find.text('Physics'), findsOneWidget);

      // Select subject and present
      // To simulate filling the form:
      // Note: testing DropdownButton is tricky, so we will look for text widgets inside.
      await tester.tap(find.text('Physics').last);
      await tester.pumpAndSettle();
      
      // Select Present (Segmented button or normal button)
      await tester.tap(find.text('Present').last);
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(fakeNotifier.wasManualAttendanceAdded, true);
    });

    testWidgets('Calendar text scale factor regression loop', (WidgetTester tester) async {
      final textScaleFactors = [1.0, 1.3, 1.5, 2.0];

      for (final scale in textScaleFactors) {
        final fakeNotifier = FakeCalendarNotifier(loadedState);
        await tester.pumpWidget(ProviderScope(
          overrides: [
            calendarNotifierProvider.overrideWith(() => fakeNotifier),
          ],
          child: MaterialApp(
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              );
            },
            home: const CalendarScreen(),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Calendar Golden Tests', () {
    testGoldens('Calendar UI matches golden', (tester) async {
      if (!isGoldenTestsSupported) return;
      await setupGoldenTests();

      final fakeNotifier = FakeCalendarNotifier(loadedState);

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(defaultDevices)
        ..addScenario(
          widget: ProviderScope(
            overrides: [
              calendarNotifierProvider.overrideWith(() => fakeNotifier),
            ],
            child: const CalendarScreen(),
          ),
          name: 'loaded_state',
        );

      await tester.pumpDeviceBuilder(builder, wrapper: materialWrapper());
      await screenMatchesGolden(tester, 'calendar_loaded_state');
    });
  });
}

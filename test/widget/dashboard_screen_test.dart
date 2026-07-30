import 'package:attendancex/core/enums/attendance_status.dart';
import 'package:attendancex/core/enums/lecture_type.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/features/dashboard/models/attendance_summary.dart';
import 'package:attendancex/features/dashboard/models/dashboard_state.dart';
import 'package:attendancex/features/dashboard/models/smart_suggestion.dart';
import 'package:attendancex/features/dashboard/providers/dashboard_provider.dart';
import 'package:attendancex/features/dashboard/screens/dashboard_screen.dart';
import 'package:attendancex/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/golden_helper.dart';

class FakeDashboardNotifier extends DashboardNotifier {
  final DashboardState _mockState;
  
  AttendanceStatus? lastMarkedStatus;
  int? lastMarkedScheduleId;

  FakeDashboardNotifier(this._mockState);

  @override
  Stream<DashboardState> build() async* {
    yield _mockState;
  }

  @override
  Future<void> markAttendance(int scheduleId, int subjectId, AttendanceStatus status) async {
    lastMarkedScheduleId = scheduleId;
    lastMarkedStatus = status;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.instance.initialize();
  });

  const defaultSummary = SubjectAttendanceSummary(
    subjectId: 1,
    effectivePresent: 0,
    effectiveTotal: 0,
    totalPresentRecords: 0,
    totalAbsentRecords: 0,
    totalHolidayRecords: 0,
    totalMedicalRecords: 0,
    totalGTRecords: 0,
    totalPendingRecords: 0,
  );
  
  const defaultSuggestion = SmartSuggestion(
    type: SmartSuggestionType.onTrack,
    subjectId: null,
    classes: 0,
    message: 'You are on track.',
  );

  final loadedState = DashboardState(
    pendingLectures: [
      LectureCardModel(
        subject: Subject()..name = 'Math'..colorValue = Colors.blue.value,
        schedule: Schedule()..id = 1..type = LectureType.lecture..startTime = '10:00'..endTime = '11:00',
        attendance: null,
        summary: defaultSummary,
        suggestion: defaultSuggestion,
      ),
    ],
    markedLectures: const [],
    todayProgressText: '0 / 1 Classes Marked',
    todayProgressPercentage: 0.0,
    overallSummary: const OverallAttendanceSummary(
      effectivePresent: 75,
      effectiveTotal: 100,
      totalPresentRecords: 75,
      totalAbsentRecords: 25,
      totalHolidayRecords: 0,
      totalMedicalRecords: 0,
      totalGTRecords: 0,
      totalPendingRecords: 0,
    ),
    overallSuggestion: const SmartSuggestion(
      type: SmartSuggestionType.onTrack,
      subjectId: null,
      classes: 0,
      message: 'You are on track with your overall attendance.',
    ),
    isLoading: false,
  );

  group('Dashboard Widget Tests', () {
    testWidgets('Dashboard renders empty state', (WidgetTester tester) async {
      const state = DashboardState(
        pendingLectures: [],
        markedLectures: [],
        todayProgressText: '0 / 0 Classes Marked',
        todayProgressPercentage: 0.0,
        overallSummary: null,
        overallSuggestion: null,
        isLoading: false,
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [
          dashboardNotifierProvider.overrideWith(() => FakeDashboardNotifier(state)),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No lectures scheduled for today.'), findsOneWidget);
      expect(find.text('No attendance data yet.'), findsOneWidget);
    });

    testWidgets('Dashboard interactions - Mark Present/Absent/Edit', (WidgetTester tester) async {
      final fakeNotifier = FakeDashboardNotifier(loadedState);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          dashboardNotifierProvider.overrideWith(() => fakeNotifier),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ));
      await tester.pumpAndSettle();

      // Tap Present
      await tester.tap(find.text('Present'));
      await tester.pumpAndSettle();
      expect(fakeNotifier.lastMarkedStatus, AttendanceStatus.present);
      expect(fakeNotifier.lastMarkedScheduleId, 1);

      // Tap Absent
      await tester.tap(find.text('Absent'));
      await tester.pumpAndSettle();
      expect(fakeNotifier.lastMarkedStatus, AttendanceStatus.absent);

      // Now mock a state where attendance is already marked to test Edit
      final markedState = DashboardState(
        pendingLectures: const [],
        markedLectures: [
          LectureCardModel(
            subject: Subject()..name = 'Math'..colorValue = Colors.blue.value,
            schedule: Schedule()..id = 1..type = LectureType.lecture..startTime = '10:00'..endTime = '11:00',
            attendance: Attendance()..status = AttendanceStatus.present,
            summary: defaultSummary,
            suggestion: defaultSuggestion,
          ),
        ],
        todayProgressText: '1 / 1 Classes Marked',
        todayProgressPercentage: 1.0,
        overallSummary: loadedState.overallSummary,
        overallSuggestion: loadedState.overallSuggestion,
        isLoading: false,
      );

      final fakeNotifierMarked = FakeDashboardNotifier(markedState);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          dashboardNotifierProvider.overrideWith(() => fakeNotifierMarked),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Present'), findsWidgets);
      
      // Tap Edit
      await tester.tap(find.text('Edit Attendance'));
      await tester.pumpAndSettle();
      // Bottom sheet should open with options
      expect(find.text('Edit Attendance'), findsWidgets);
      expect(find.text('Absent'), findsWidgets); // Found in bottom sheet
    });

    testWidgets('Dashboard text scale factor regression loop', (WidgetTester tester) async {
      final textScaleFactors = [1.0, 1.3, 1.5, 2.0];

      for (final scale in textScaleFactors) {
        final fakeNotifier = FakeDashboardNotifier(loadedState);
        await tester.pumpWidget(ProviderScope(
          overrides: [
            dashboardNotifierProvider.overrideWith(() => fakeNotifier),
          ],
          child: MaterialApp(
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              );
            },
            home: const DashboardScreen(),
          ),
        ));
        await tester.pumpAndSettle();
        
        // Ensure no flex overflow exceptions are thrown. 
        // Flutter tester throws automatically on overflow during pump if exceptions are not caught.
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Dashboard Golden Tests', () {
    testGoldens('Dashboard UI matches golden', (tester) async {
      if (!isGoldenTestsSupported) return;
      await setupGoldenTests();

      final fakeNotifier = FakeDashboardNotifier(loadedState);

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: defaultDevices)
        ..addScenario(
          widget: ProviderScope(
            overrides: [
              dashboardNotifierProvider.overrideWith(() => fakeNotifier),
            ],
            child: const DashboardScreen(),
          ),
          name: 'loaded_state',
        );

      await tester.pumpDeviceBuilder(builder, wrapper: materialWrapper());
      await screenMatchesGolden(tester, 'dashboard_loaded_state');
    });
  });
}

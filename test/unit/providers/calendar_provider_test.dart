import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendify/database/database_providers.dart';
import 'package:attendify/features/subjects/providers/subject_providers.dart';
import 'package:attendify/features/attendance/providers/attendance_providers.dart';
import 'package:attendify/features/schedule/providers/schedule_providers.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/attendance_history_collection.dart';
import 'package:attendify/database/collections/academic_task_collection.dart';
import 'package:attendify/core/enums/attendance_status.dart';
import 'package:attendify/features/calendar/providers/calendar_provider.dart';
import 'package:attendify/database/collections/profile_collection.dart';
import 'package:attendify/database/collections/semester_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendify/services/preferences_service.dart';
import 'package:isar/isar.dart';

void main() {
  late Isar isar;
  late ProviderContainer container;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Isar.initializeIsarCore(download: true);
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.instance.initialize();
  });

  setUp(() async {
    isar = await Isar.open(
      [
        ProfileSchema,
        SemesterSchema,
        SubjectSchema,
        ScheduleSchema,
        AttendanceSchema,
        AttendanceHistorySchema,
        AcademicTaskSchema
      ],
      directory: '',
      name: 'calendar_test_db_${DateTime.now().microsecondsSinceEpoch}',
    );

    final semester = Semester()
      ..id = 1
      ..profileId = 1
      ..name = 'Semester 1'
      ..startDate = DateTime(2023, 1, 1)
      ..endDate = DateTime(2030, 1, 1);
    await isar.writeTxn(() async {
      await isar.semesters.put(semester);
    });

    container = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
    );
  });

  tearDown(() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
    await isar.close(deleteFromDisk: true);
    container.dispose();
  });

  test('CalendarNotifier handles empty subjects gracefully', () async {
    final state = await container.read(calendarNotifierProvider.future);
    expect(state.isLoading, false);
    expect(state.attendanceMarkers, isEmpty);
    expect(state.selectedDayDetails.items, isEmpty);
  });

  test('CalendarNotifier updates selected date and focused date', () async {
    final sub1 = container.listen(calendarSelectedDateProvider, (_, __) {});
    final sub2 = container.listen(calendarFocusedDateProvider, (_, __) {});

    final newDate = DateTime(2025, 1, 1);

    container.read(calendarSelectedDateProvider.notifier).setDate(newDate);
    container.read(calendarFocusedDateProvider.notifier).setDate(newDate);

    // Now start the provider and read the future
    final state = await container.read(calendarNotifierProvider.future);

    expect(state.selectedDate, newDate);
    expect(state.focusedDate, newDate);
    expect(state.selectedDayDetails.date, newDate);

    sub1.close();
    sub2.close();
  });

  test('CalendarNotifier builds correct markers and daily details', () async {
    final sub1 = container.listen(calendarSelectedDateProvider, (_, __) {});
    final sub2 = container.listen(calendarFocusedDateProvider, (_, __) {});

    final subjectRepo = container.read(subjectRepositoryProvider);
    final scheduleRepo = container.read(scheduleRepositoryProvider);
    final attendanceRepo = container.read(attendanceRepositoryProvider);

    final subSubject = Subject()
      ..semesterId = 1
      ..name = 'Math';
    await subjectRepo.create(subSubject);

    final now = DateTime.now();
    // Use the 15th of the current month so it is guaranteed to be in the visible month and not cause overflow issues
    final testDate = DateTime(now.year, now.month, 15);
    final dayOfWeek = testDate.weekday; // use actual weekday

    container.read(calendarSelectedDateProvider.notifier).setDate(testDate);
    container.read(calendarFocusedDateProvider.notifier).setDate(testDate);

    final sch = Schedule()
      ..semesterId = 1
      ..subjectId = subSubject.id
      ..dayOfWeek = dayOfWeek
      ..startTime = '10:00'
      ..endTime = '11:00';
    await scheduleRepo.create(sch);

    final savedSch = await isar.schedules.where().findFirst();

    final att = Attendance()
      ..semesterId = 1
      ..subjectId = subSubject.id
      ..scheduleId = savedSch!.id
      ..date = testDate
      ..status = AttendanceStatus.present;
    await attendanceRepo.upsertAttendance(att);

    // Read state for the first time AFTER inserting everything
    final state = await container.read(calendarNotifierProvider.future);

    // Assert markers
    expect(state.attendanceMarkers.length, 1);
    expect(state.attendanceMarkers.containsKey(testDate), isTrue);
    expect(state.attendanceMarkers[testDate]!.length, 1);
    expect(state.attendanceMarkers[testDate]!.first, AttendanceStatus.present);

    // Assert daily details
    expect(state.selectedDayDetails.items.length, 1);
    expect(state.selectedDayDetails.items.first.subject.name, 'Math');
    expect(state.selectedDayDetails.items.first.attendance?.status,
        AttendanceStatus.present);
    expect(state.selectedDayDetails.items.first.isManual, false);

    sub1.close();
    sub2.close();
  });
}

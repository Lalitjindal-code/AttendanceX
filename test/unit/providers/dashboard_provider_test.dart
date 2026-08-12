import 'package:attendify/core/enums/day_of_week.dart';
import 'package:attendify/core/enums/lecture_type.dart';
import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/attendance_history_collection.dart';
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/database/collections/academic_task_collection.dart';
import 'package:attendify/database/collections/profile_collection.dart';
import 'package:attendify/database/collections/semester_collection.dart';
import 'package:attendify/database/database_providers.dart';
import 'package:attendify/features/dashboard/providers/dashboard_provider.dart';
import 'package:attendify/features/schedule/providers/schedule_providers.dart';
import 'package:attendify/features/subjects/providers/subject_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendify/services/preferences_service.dart';

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
      name: 'dashboard_test_db_${DateTime.now().microsecondsSinceEpoch}',
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

  test('DashboardProvider correctly maps and sorts todays lectures', () async {
    final subjectRepo = container.read(subjectRepositoryProvider);
    final scheduleRepo = container.read(scheduleRepositoryProvider);

    final sub1 = Subject()
      ..semesterId = 1
      ..name = 'Math';
    final sub2 = Subject()
      ..semesterId = 1
      ..name = 'Physics';
    await subjectRepo.create(sub1);
    await subjectRepo.create(sub2);

    final day = DayOfWeek.fromInt(DateTime.now().weekday);

    final s1 = Schedule()
      ..semesterId = 1
      ..subjectId = sub1.id
      ..dayOfWeek = day.value
      ..startTime = '10:00'
      ..endTime = '11:00'
      ..type = LectureType.lecture;

    final s2 = Schedule()
      ..semesterId = 1
      ..subjectId = sub2.id
      ..dayOfWeek = day.value
      ..startTime = '09:00' // should be sorted first
      ..endTime = '10:00'
      ..type = LectureType.lab;

    await scheduleRepo.create(s1);
    await scheduleRepo.create(s2);

    // Read the future to await the first value.
    final state = await container.read(dashboardNotifierProvider.future);

    expect(state.pendingLectures.length, 2);
    // Should be sorted by time (09:00 comes before 10:00)
    expect(state.pendingLectures[0].subject.name, 'Physics');
    expect(state.pendingLectures[1].subject.name, 'Math');
  });
}

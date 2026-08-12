import 'package:attendify/core/enums/day_of_week.dart';
import 'package:attendify/core/enums/attendance_status.dart';
import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/attendance_history_collection.dart';
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/database/collections/academic_task_collection.dart';
import 'package:attendify/database/collections/semester_collection.dart';
import 'package:attendify/database/collections/profile_collection.dart';
import 'package:attendify/database/repositories/subject_repository.dart';
import 'package:attendify/database/repositories/schedule_repository.dart';
import 'package:attendify/database/repositories/attendance_repository.dart';
import 'package:attendify/features/attendance/providers/attendance_providers.dart';
import 'package:attendify/features/notifications/models/scheduled_notification.dart';
import 'package:attendify/features/notifications/providers/notification_provider.dart';
import 'package:attendify/features/schedule/providers/schedule_providers.dart';
import 'package:attendify/features/settings/models/app_settings.dart';
import 'package:attendify/features/settings/providers/settings_provider.dart';
import 'package:attendify/features/settings/providers/semester_provider.dart';
import 'package:attendify/features/subjects/providers/subject_providers.dart';
import 'package:attendify/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:attendify/database/database_providers.dart';

class MockNotificationService implements NotificationService {
  List<ScheduledNotification>? lastSyncedNotifications;

  @override
  Future<void> syncNotifications(
      List<ScheduledNotification> desiredNotifications) async {
    lastSyncedNotifications = desiredNotifications;
  }

  @override
  Future<void> init() async {}

  @override
  Future<bool?> requestPermissions() async => true;
  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      [];
  @override
  Future<void> showTestNotification() async {}

  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> cancelAllNotifications() async {}
}

class FakeSubjectRepository implements SubjectRepository {
  @override
  Stream<List<Subject>> watchAll(int semesterId) => Stream.value([
        Subject()
          ..id = 1
          ..name = 'Mock Subject'
      ]);

  @override
  Future<void> create(Subject subject) async {}
  @override
  Future<void> update(Subject subject) async {}
  @override
  Future<void> deletePermanently(int subjectId) async {}
  @override
  Future<Subject?> getById(int id) async => null;
  @override
  Future<SubjectDeletionImpact> getDeletionImpact(int subjectId) async =>
      const SubjectDeletionImpact(
        schedulesCount: 0,
        attendancesCount: 0,
        historyCount: 0,
        tasksCount: 0,
      );
  @override
  Stream<List<Subject>> watchAllActive(int semesterId) => Stream.value([]);
  @override
  Future<void> migrateNotificationDefaults() async {}
}

class FakeScheduleRepository implements ScheduleRepository {
  @override
  Stream<List<Schedule>> watchAll(int semesterId) => Stream.value([
        Schedule()
          ..id = 101
          ..subjectId = 1
          ..dayOfWeek = DayOfWeek.fromInt(DateTime.now().weekday).value
          ..startTime = '12:00'
          ..endTime = '13:00'
          ..room = '101'
      ]);

  @override
  Future<List<Schedule>> getByDay(int dayOfWeek, int semesterId) async => [];

  @override
  Future<void> create(Schedule schedule) async {}
  @override
  Future<void> update(Schedule schedule) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Future<Schedule?> getById(int id) async => null;
  @override
  Future<void> updateOrder(List<int> scheduleIds) async {}
  @override
  Stream<List<Schedule>> watchByDaySortedByOrder(
          int dayOfWeek, int semesterId) =>
      Stream.value([]);
  @override
  Stream<List<Schedule>> watchByDaySortedByTime(
          int dayOfWeek, int semesterId) =>
      Stream.value([]);
}

class FakeAttendanceRepository implements AttendanceRepository {
  @override
  Stream<List<Attendance>> watchAll(int semesterId) => Stream.value([]);

  @override
  Future<void> upsertAttendance(Attendance attendance) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> deleteAttendancesByDate(DateTime date, int semesterId) async {}
  @override
  Future<void> markFullDayStatus(
      DateTime date, int semesterId, AttendanceStatus status) async {}
  @override
  Stream<List<Attendance>> watchBySubject(int subjectId, int semesterId) =>
      Stream.value([]);
  @override
  Future<List<Attendance>> getBySubjectId(
          int subjectId, int semesterId) async =>
      [];
  @override
  Stream<List<AttendanceHistory>> watchHistoryBySubject(
          int subjectId, int semesterId) =>
      Stream.value([]);
  @override
  Stream<List<Attendance>> watchByDateRange(
          int semesterId, DateTime start, DateTime end) =>
      Stream.value([]);
  @override
  Future<Attendance?> getById(int id) async => null;
}

class FakeSettings extends Settings {
  @override
  AppSettings build() => const AppSettings(
      notificationsEnabled: true,
      lectureReminderMinutes: 10,
      dailyReminderEnabled: false);
}

class FakeSemesterState extends SemesterState {
  @override
  Semester? build() => Semester()
    ..id = 1
    ..name = 'Semester 1'
    ..startDate = DateTime(2023, 1, 1)
    ..endDate = DateTime(2030, 1, 1);
}

void main() {
  late Isar isar;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Isar.initializeIsarCore(download: true);
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
      name: 'notification_test_db_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    if (isar.isOpen) {
      await isar.writeTxn(() async => isar.clear());
      await isar.close(deleteFromDisk: true);
    }
  });
  test('NotificationOrchestrator syncs generated notifications', () async {
    final mockService = MockNotificationService();
    NotificationService.setInstanceForTesting(mockService);

    final container = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(isar),
        subjectRepositoryProvider.overrideWithValue(FakeSubjectRepository()),
        scheduleRepositoryProvider.overrideWithValue(FakeScheduleRepository()),
        attendanceRepositoryProvider
            .overrideWithValue(FakeAttendanceRepository()),
        settingsProvider.overrideWith(() => FakeSettings()),
        semesterStateProvider.overrideWith(
            () => FakeSemesterState()), // provide null or a mock semester
      ],
    );

    // Provide a listener to keep it alive
    container.listen(notificationOrchestratorProvider, (_, __) {});

    // Wait for the async map to emit
    await container.read(notificationOrchestratorProvider.future);

    expect(mockService.lastSyncedNotifications, isNotNull);

    container.dispose();
  });
}

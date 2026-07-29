import 'package:attendancex/core/enums/day_of_week.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/attendance_history_collection.dart';
import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/database/repositories/subject_repository.dart';
import 'package:attendancex/database/repositories/schedule_repository.dart';
import 'package:attendancex/database/repositories/attendance_repository.dart';
import 'package:attendancex/features/attendance/providers/attendance_providers.dart';
import 'package:attendancex/features/notifications/models/scheduled_notification.dart';
import 'package:attendancex/features/notifications/providers/notification_provider.dart';
import 'package:attendancex/features/schedule/providers/schedule_providers.dart';
import 'package:attendancex/features/settings/models/app_settings.dart';
import 'package:attendancex/features/settings/providers/settings_provider.dart';
import 'package:attendancex/features/subjects/providers/subject_providers.dart';
import 'package:attendancex/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockNotificationService implements NotificationService {
  List<ScheduledNotification>? lastSyncedNotifications;

  @override
  Future<void> syncNotifications(List<ScheduledNotification> desiredNotifications) async {
    lastSyncedNotifications = desiredNotifications;
  }
  
  @override
  Future<void> init() async {}
  
  @override
  Future<void> requestPermissions() async {}
}

class FakeSubjectRepository implements SubjectRepository {
  @override
  Stream<List<Subject>> watchAll() => Stream.value([Subject()..id = 1..name = 'Mock Subject']);
  
  @override
  Future<List<Subject>> getAllSubjects() async => [];
  @override
  Future<void> create(Subject subject) async {}
  @override
  Future<void> update(Subject subject) async {}
  @override
  Future<void> deletePermanently(int subjectId) async {}
  @override
  Future<Subject?> getById(int id) async => null;
  @override
  Future<SubjectDeletionImpact> getDeletionImpact(int subjectId) async => const SubjectDeletionImpact(schedulesCount: 0, attendancesCount: 0, historyCount: 0);
  @override
  Stream<List<Subject>> watchAllActive() => Stream.value([]);
}

class FakeScheduleRepository implements ScheduleRepository {
  @override
  Stream<List<Schedule>> watchAll() => Stream.value([
        Schedule()
          ..id = 101
          ..subjectId = 1
          ..dayOfWeek = DayOfWeek.fromInt(DateTime.now().weekday).value
          ..startTime = '12:00'
          ..endTime = '13:00'
          ..room = '101'
      ]);
      
  @override
  Future<List<Schedule>> getSchedulesForSubject(int subjectId) async => [];
  @override
  Future<List<Schedule>> getByDay(int dayOfWeek) async => [];
  @override
  Future<void> create(Schedule schedule) async {}
  @override
  Future<void> update(Schedule schedule) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> deleteSchedulesForSubject(int subjectId) async {}
  @override
  Stream<List<Schedule>> watchSchedulesForSubject(int subjectId) => Stream.value([]);
  @override
  Future<Schedule?> getById(int id) async => null;
  @override
  Future<void> updateOrder(List<int> scheduleIds) async {}
  @override
  Stream<List<Schedule>> watchByDaySortedByOrder(int dayOfWeek) => Stream.value([]);
  @override
  Stream<List<Schedule>> watchByDaySortedByTime(int dayOfWeek) => Stream.value([]);
}

class FakeAttendanceRepository implements AttendanceRepository {
  @override
  Stream<List<Attendance>> watchAll() => Stream.value([]);
  
  @override
  Future<List<Attendance>> getAllAttendances() async => [];
  @override
  Future<List<Attendance>> getAttendancesForSubject(int subjectId) async => [];
  @override
  Future<List<AttendanceHistory>> getHistoryForAttendance(int attendanceId) async => [];
  @override
  Future<void> upsertAttendance(Attendance attendance) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> deleteAttendancesForSubject(int subjectId) async {}
  @override
  Stream<List<Attendance>> watchBySubject(int subjectId) => Stream.value([]);
  @override
  Stream<List<AttendanceHistory>> watchHistoryBySubject(int subjectId) => Stream.value([]);
  @override
  Stream<List<Attendance>> watchByDateRange(DateTime start, DateTime end) => Stream.value([]);
  @override
  Future<Attendance?> getById(int id) async => null;
}

class FakeSettings extends Settings {
  @override
  AppSettings build() => const AppSettings(
    notificationsEnabled: true, 
    lectureReminderMinutes: 10, 
    dailyReminderEnabled: false
  );
}

void main() {
  test('NotificationOrchestrator syncs generated notifications', () async {
    final mockService = MockNotificationService();
    NotificationService.setInstanceForTesting(mockService);

    final container = ProviderContainer(
      overrides: [
        subjectRepositoryProvider.overrideWithValue(FakeSubjectRepository()),
        scheduleRepositoryProvider.overrideWithValue(FakeScheduleRepository()),
        attendanceRepositoryProvider.overrideWithValue(FakeAttendanceRepository()),
        settingsProvider.overrideWith(() => FakeSettings()),
      ],
    );

    // Provide a listener to keep it alive
    final sub = container.listen(notificationOrchestratorProvider, (_, __) {});
    
    // Wait for the async map to emit
    await container.read(notificationOrchestratorProvider.future);

    expect(mockService.lastSyncedNotifications, isNotNull);
    
    container.dispose();
  });
}

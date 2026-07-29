import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/features/attendance/providers/attendance_providers.dart';
import 'package:attendancex/features/notifications/engines/notification_engine.dart';
import 'package:attendancex/features/schedule/providers/schedule_providers.dart';
import 'package:attendancex/features/settings/models/app_settings.dart';
import 'package:attendancex/features/settings/providers/settings_provider.dart';
import 'package:attendancex/features/subjects/providers/subject_providers.dart';
import 'package:attendancex/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart' hide Subject;

part 'notification_provider.g.dart';

@riverpod
class NotificationOrchestrator extends _$NotificationOrchestrator {
  @override
  Stream<void> build() {
    final subjectRepo = ref.watch(subjectRepositoryProvider);
    final scheduleRepo = ref.watch(scheduleRepositoryProvider);
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    final settings = ref.watch(settingsProvider);

    return Rx.combineLatest3(
      subjectRepo.watchAll(),
      scheduleRepo.watchAll(),
      attendanceRepo.watchAll(),
      (List<Subject> subjects, List<Schedule> schedules, List<Attendance> attendances) {
        return _syncNotifications(subjects, schedules, attendances, settings);
      },
    ).asyncMap((_) async {}); // Convert to Stream<void>
  }

  Future<void> _syncNotifications(
    List<Subject> subjects,
    List<Schedule> schedules,
    List<Attendance> attendances,
    AppSettings settings,
  ) async {
    final now = DateTime.now();

    final desiredNotifications = NotificationEngine.generateNotifications(
      subjects: subjects,
      schedules: schedules,
      attendances: attendances,
      settings: settings,
      now: now,
    );

    await NotificationService.instance.syncNotifications(desiredNotifications);
  }
}

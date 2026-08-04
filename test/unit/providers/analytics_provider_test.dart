import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendancex/database/database_providers.dart';
import 'package:attendancex/features/subjects/providers/subject_providers.dart';
import 'package:attendancex/features/attendance/providers/attendance_providers.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/collections/attendance_history_collection.dart';
import 'package:attendancex/database/collections/academic_task_collection.dart';
import 'package:attendancex/core/enums/attendance_status.dart';
import 'package:attendancex/features/analytics/providers/analytics_provider.dart';
import 'package:attendancex/features/analytics/models/analytics_trend.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendancex/services/preferences_service.dart';

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
        SubjectSchema,
        ScheduleSchema,
        AttendanceSchema,
        AttendanceHistorySchema,
        AcademicTaskSchema
      ],
      directory: '',
      name: 'analytics_test_db_${DateTime.now().microsecondsSinceEpoch}',
    );

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

  test('AnalyticsNotifier handles empty subjects gracefully', () async {
    final state = await container.read(analyticsNotifierProvider.future);
    expect(state.isLoading, false);
    expect(state.subjectStats, isEmpty);
    expect(state.monthlyTrends, isEmpty);
  });

  test('AnalyticsNotifier calculates stats when subjects exist', () async {
    final subjectRepo = container.read(subjectRepositoryProvider);
    final attendanceRepo = container.read(attendanceRepositoryProvider);

    final sub1 = Subject()
      ..name = 'Physics'
      ..goalPercentage = 75.0;
    await subjectRepo.create(sub1);

    final now = DateTime.now();
    final a1 = Attendance()
      ..subjectId = sub1.id
      ..scheduleId = 1
      ..date = DateTime.utc(now.year, now.month, now.day)
      ..status = AttendanceStatus.present;

    await attendanceRepo.upsertAttendance(a1);

    // Give stream time to emit
    await Future.delayed(const Duration(milliseconds: 100));

    final state = await container.read(analyticsNotifierProvider.future);

    expect(state.isLoading, false);
    expect(state.subjectStats.length, 1);
    expect(state.subjectStats[0].subject.name, 'Physics');

    // Total should be 1, present 1, 100%
    expect(state.subjectStats[0].summary.effectivePresent, 1);
    expect(state.subjectStats[0].summary.effectiveTotal, 1);

    // Forecast should show 100% current
    expect(state.subjectStats[0].forecast.currentPercentage, 1.0);

    // Trend should be insufficientData because previous month has 0 total
    expect(state.subjectStats[0].trend, AnalyticsTrend.insufficientData);

    // Monthly trend should have 1 entry
    expect(state.monthlyTrends.length, 1);
    expect(state.monthlyTrends[0].presentCount, 1);
    expect(state.monthlyTrends[0].totalCount, 1);
    expect(state.monthlyTrends[0].percentage, 1.0);

    // Overall forecast
    expect(state.overallForecast, isNotNull);
    expect(state.overallForecast!.currentPercentage, 1.0);
  });
}

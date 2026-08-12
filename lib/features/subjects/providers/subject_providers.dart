import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../database/database_providers.dart';
import '../../../database/repositories/subject_repository.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/providers/semester_provider.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../../dashboard/models/attendance_summary.dart';
import '../../../engines/attendance_engine.dart';

part 'subject_providers.g.dart';

@Riverpod(keepAlive: true)
SubjectRepository subjectRepository(SubjectRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return SubjectRepository(isar);
}

@riverpod
Stream<List<Subject>> subjects(SubjectsRef ref) {
  final repository = ref.watch(subjectRepositoryProvider);
  final semester = ref.watch(semesterStateProvider);
  if (semester == null) return Stream.value([]);
  return repository.watchAllActive(semester.id);
}

@riverpod
Future<Subject?> subject(SubjectRef ref, int id) {
  final repository = ref.watch(subjectRepositoryProvider);
  return repository.getById(id);
}

@riverpod
Stream<SubjectAttendanceSummary> subjectSummary(
    SubjectSummaryRef ref, int subjectId) async* {
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  final semester = ref.watch(semesterStateProvider);

  if (semester == null) {
    yield SubjectAttendanceSummary(
      subjectId: subjectId,
      effectivePresent: 0,
      effectiveTotal: 0,
      totalPresentRecords: 0,
      totalAbsentRecords: 0,
      totalHolidayRecords: 0,
      totalMedicalRecords: 0,
      totalGTRecords: 0,
      totalPendingRecords: 0,
    );
    return;
  }

  final stream = attendanceRepo.watchBySubject(semester.id, subjectId);

  await for (final attendances in stream) {
    yield AttendanceEngine.calculateSubjectSummary(
        subjectId, attendances, settings, semester);
  }
}

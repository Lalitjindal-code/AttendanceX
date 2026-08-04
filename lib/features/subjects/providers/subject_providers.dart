import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../database/database_providers.dart';
import '../../../database/repositories/subject_repository.dart';
import '../../settings/providers/settings_provider.dart';
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
  return repository.watchAllActive();
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
  final stream = attendanceRepo.watchBySubject(subjectId);

  await for (final attendances in stream) {
    yield AttendanceEngine.calculateSubjectSummary(
        subjectId, attendances, settings);
  }
}

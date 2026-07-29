import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../database/database_providers.dart';
import '../../../database/repositories/subject_repository.dart';

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

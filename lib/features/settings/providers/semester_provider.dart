import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../database/database_providers.dart';
import '../../../database/collections/semester_collection.dart';
import '../../../database/collections/profile_collection.dart';
import '../../../database/repositories/semester_repository.dart';
import '../../../services/preferences_service.dart';

part 'semester_provider.g.dart';

@Riverpod(keepAlive: true)
class SemesterState extends _$SemesterState {
  @override
  Semester? build() {
    final isar = ref.watch(isarProvider);
    final prefs = PreferencesService.instance;
    final activeSemesterId = prefs.getInt('active_semester_id', defaultValue: 1);

    // Watch the active semester for the current profile
    // Note: We use the synchronous get to populate initial state
    Semester? semester = isar.semesters.getSync(activeSemesterId);
    
    if (semester == null) {
      semester = isar.semesters.where().build().findFirstSync();
      if (semester != null) {
        // Defer async side-effect — can't await inside a sync build()
        Future(() => prefs.setInt('active_semester_id', semester!.id));
      }
    }

    return semester;
  }

  Future<void> updateSemesterDates(DateTime startDate, DateTime? endDate) async {
    final current = state;
    if (current == null) return;
    
    current.startDate = DateTime(startDate.year, startDate.month, startDate.day);
    if (endDate != null) {
      current.endDate = DateTime(endDate.year, endDate.month, endDate.day);
    } else {
      current.endDate = null;
    }
    
    await ref.read(semesterRepositoryProvider).upsertSemester(current);
    // Refresh state manually since we are not listening to a stream directly
    state = await ref.read(semesterRepositoryProvider).getSemester(current.id);
  }

  Future<void> updateSemesterName(String name) async {
    final current = state;
    if (current == null) return;
    
    current.name = name;
    await ref.read(semesterRepositoryProvider).upsertSemester(current);
    state = await ref.read(semesterRepositoryProvider).getSemester(current.id);
  }

  Future<void> updateSemester(String name, DateTime startDate) async {
    var current = state;
    if (current == null) {
      final isar = ref.read(isarProvider);
      final prefs = PreferencesService.instance;
      final activeProfileId = prefs.getInt('active_profile_id', defaultValue: 1);

      // Check if profile exists, if not create default
      var profile = await isar.profiles.get(activeProfileId);
      if (profile == null) {
        profile = Profile()
          ..id = activeProfileId
          ..name = 'Default Profile'
          ..isDefault = true;
        await isar.writeTxn(() async {
          await isar.profiles.put(profile!);
        });
      }

      current = Semester()
        ..profileId = activeProfileId
        ..name = name
        ..startDate = DateTime(startDate.year, startDate.month, startDate.day);

      final newSemId = await ref.read(semesterRepositoryProvider).upsertSemester(current);
      current.id = newSemId;

      await prefs.setInt('active_semester_id', newSemId);
      state = current;
    } else {
      current.name = name;
      current.startDate = DateTime(startDate.year, startDate.month, startDate.day);
      await ref.read(semesterRepositoryProvider).upsertSemester(current);
      state = await ref.read(semesterRepositoryProvider).getSemester(current.id);
    }
  }

  Future<void> setActiveSemester(int id) async {
    final prefs = PreferencesService.instance;
    await prefs.setInt('active_semester_id', id);
    state = await ref.read(semesterRepositoryProvider).getSemester(id);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database_providers.dart';
import '../collections/profile_collection.dart';

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository(ref.watch(isarProvider));
});

class ProfileRepository {
  final Isar _isar;

  ProfileRepository(this._isar);

  Future<int> upsertProfile(Profile profile) async {
    return _isar.writeTxn(() async {
      profile.updatedAt = DateTime.now();
      return _isar.profiles.put(profile);
    });
  }

  Future<void> deleteProfile(int id) async {
    await _isar.writeTxn(() async {
      await _isar.profiles.delete(id);
    });
  }

  Future<Profile?> getProfile(int id) async {
    return _isar.profiles.get(id);
  }

  Future<List<Profile>> getAllProfiles() async {
    return _isar.profiles.where().findAll();
  }

  Stream<List<Profile>> watchAllProfiles() {
    return _isar.profiles.where().watch(fireImmediately: true);
  }

  Stream<Profile?> watchProfile(int id) {
    return _isar.profiles.watchObject(id, fireImmediately: true);
  }
}

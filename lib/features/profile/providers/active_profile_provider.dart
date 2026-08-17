import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../database/collections/profile_collection.dart';
import '../../../database/repositories/profile_repository.dart';
import '../../../services/preferences_service.dart';
import '../../settings/providers/settings_provider.dart';

part 'active_profile_provider.g.dart';

@riverpod
Stream<Profile> activeProfileStream(Ref ref) {
  final repo = ref.watch(profileRepositoryProvider);
  final activeProfileId = PreferencesService.instance.getInt('active_profile_id', defaultValue: 1);
  
  // Watch settingsProvider so that when settingsProvider updates the profile,
  // we might want to re-fetch, but Isar stream will handle DB updates automatically.
  ref.watch(settingsProvider);
  
  return repo.watchProfile(activeProfileId).map((p) => p ?? Profile());
}

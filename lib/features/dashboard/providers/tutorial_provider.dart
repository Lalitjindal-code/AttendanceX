import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/preferences_service.dart';

part 'tutorial_provider.g.dart';

@riverpod
class TutorialNotifier extends _$TutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownDashboardTutorial,
      defaultValue: false,
    );
  }

  Future<void> markDashboardTutorialShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownDashboardTutorial,
      true,
    );
    state = true;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/preferences_service.dart';

part 'tutorial_provider.g.dart';

@riverpod
class DashboardTutorialNotifier extends _$DashboardTutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownDashboardTutorial,
      defaultValue: false,
    );
  }

  Future<void> markShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownDashboardTutorial,
      true,
    );
    state = true;
  }
}

@riverpod
class SubjectsTutorialNotifier extends _$SubjectsTutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownSubjectsTutorial,
      defaultValue: false,
    );
  }

  Future<void> markShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownSubjectsTutorial,
      true,
    );
    state = true;
  }
}

@riverpod
class PlannerTutorialNotifier extends _$PlannerTutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownPlannerTutorial,
      defaultValue: false,
    );
  }

  Future<void> markShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownPlannerTutorial,
      true,
    );
    state = true;
  }
}

@riverpod
class ScheduleTutorialNotifier extends _$ScheduleTutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownScheduleTutorial,
      defaultValue: false,
    );
  }

  Future<void> markShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownScheduleTutorial,
      true,
    );
    state = true;
  }
}

@riverpod
class MoreTutorialNotifier extends _$MoreTutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownMoreTutorial,
      defaultValue: false,
    );
  }

  Future<void> markShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownMoreTutorial,
      true,
    );
    state = true;
  }
}

@riverpod
class AnalyticsTutorialNotifier extends _$AnalyticsTutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownAnalyticsTutorial,
      defaultValue: false,
    );
  }

  Future<void> markShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownAnalyticsTutorial,
      true,
    );
    state = true;
  }
}

@riverpod
class CalendarTutorialNotifier extends _$CalendarTutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownCalendarTutorial,
      defaultValue: false,
    );
  }

  Future<void> markShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownCalendarTutorial,
      true,
    );
    state = true;
  }
}

@riverpod
class FeedbackTutorialNotifier extends _$FeedbackTutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownFeedbackTutorial,
      defaultValue: false,
    );
  }

  Future<void> markShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownFeedbackTutorial,
      true,
    );
    state = true;
  }
}

// Notifier for bottom nav tutorial
@riverpod
class BottomNavTutorialNotifier extends _$BottomNavTutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownBottomNavTutorial,
      defaultValue: false,
    );
  }

  Future<void> markShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownBottomNavTutorial,
      true,
    );
    state = true;
  }
}

@riverpod
class SettingsTutorialNotifier extends _$SettingsTutorialNotifier {
  @override
  bool build() {
    return PreferencesService.instance.getBool(
      PreferencesService.keyHasShownSettingsTutorial,
      defaultValue: false,
    );
  }

  Future<void> markShown() async {
    await PreferencesService.instance.setBool(
      PreferencesService.keyHasShownSettingsTutorial,
      true,
    );
    state = true;
  }
}
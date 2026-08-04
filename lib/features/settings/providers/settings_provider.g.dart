// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsHash() => r'd00d0fd0d5ac5d86bd8e5d36fa004c5f881d4ca8';

/// Riverpod provider managing application settings state.
///
/// Reads from and writes to [PreferencesService]. Changes to state immediately
/// trigger UI rebuilds (e.g., ThemeMode changes).
///
/// Copied from [Settings].
@ProviderFor(Settings)
final settingsProvider = NotifierProvider<Settings, AppSettings>.internal(
  Settings.new,
  name: r'settingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$settingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Settings = Notifier<AppSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

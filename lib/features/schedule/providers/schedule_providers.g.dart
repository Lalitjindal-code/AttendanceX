// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scheduleRepositoryHash() =>
    r'24394ea97ae3ba68dadd71630eb890937644c515';

/// See also [scheduleRepository].
@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider = Provider<ScheduleRepository>.internal(
  scheduleRepository,
  name: r'scheduleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ScheduleRepositoryRef = ProviderRef<ScheduleRepository>;
String _$schedulesForDayHash() => r'f72792e4216284e1b5503bce76e1cb9ff09e1974';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [schedulesForDay].
@ProviderFor(schedulesForDay)
const schedulesForDayProvider = SchedulesForDayFamily();

/// See also [schedulesForDay].
class SchedulesForDayFamily extends Family<AsyncValue<List<Schedule>>> {
  /// See also [schedulesForDay].
  const SchedulesForDayFamily();

  /// See also [schedulesForDay].
  SchedulesForDayProvider call(
    int dayOfWeek,
  ) {
    return SchedulesForDayProvider(
      dayOfWeek,
    );
  }

  @override
  SchedulesForDayProvider getProviderOverride(
    covariant SchedulesForDayProvider provider,
  ) {
    return call(
      provider.dayOfWeek,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'schedulesForDayProvider';
}

/// See also [schedulesForDay].
class SchedulesForDayProvider
    extends AutoDisposeStreamProvider<List<Schedule>> {
  /// See also [schedulesForDay].
  SchedulesForDayProvider(
    int dayOfWeek,
  ) : this._internal(
          (ref) => schedulesForDay(
            ref as SchedulesForDayRef,
            dayOfWeek,
          ),
          from: schedulesForDayProvider,
          name: r'schedulesForDayProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$schedulesForDayHash,
          dependencies: SchedulesForDayFamily._dependencies,
          allTransitiveDependencies:
              SchedulesForDayFamily._allTransitiveDependencies,
          dayOfWeek: dayOfWeek,
        );

  SchedulesForDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dayOfWeek,
  }) : super.internal();

  final int dayOfWeek;

  @override
  Override overrideWith(
    Stream<List<Schedule>> Function(SchedulesForDayRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SchedulesForDayProvider._internal(
        (ref) => create(ref as SchedulesForDayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dayOfWeek: dayOfWeek,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Schedule>> createElement() {
    return _SchedulesForDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SchedulesForDayProvider && other.dayOfWeek == dayOfWeek;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dayOfWeek.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SchedulesForDayRef on AutoDisposeStreamProviderRef<List<Schedule>> {
  /// The parameter `dayOfWeek` of this provider.
  int get dayOfWeek;
}

class _SchedulesForDayProviderElement
    extends AutoDisposeStreamProviderElement<List<Schedule>>
    with SchedulesForDayRef {
  _SchedulesForDayProviderElement(super.provider);

  @override
  int get dayOfWeek => (origin as SchedulesForDayProvider).dayOfWeek;
}

String _$schedulesForDaySortedByTimeHash() =>
    r'de3b804e7d9aea787fc281451c02adcb47322c32';

/// See also [schedulesForDaySortedByTime].
@ProviderFor(schedulesForDaySortedByTime)
const schedulesForDaySortedByTimeProvider = SchedulesForDaySortedByTimeFamily();

/// See also [schedulesForDaySortedByTime].
class SchedulesForDaySortedByTimeFamily
    extends Family<AsyncValue<List<Schedule>>> {
  /// See also [schedulesForDaySortedByTime].
  const SchedulesForDaySortedByTimeFamily();

  /// See also [schedulesForDaySortedByTime].
  SchedulesForDaySortedByTimeProvider call(
    int dayOfWeek,
  ) {
    return SchedulesForDaySortedByTimeProvider(
      dayOfWeek,
    );
  }

  @override
  SchedulesForDaySortedByTimeProvider getProviderOverride(
    covariant SchedulesForDaySortedByTimeProvider provider,
  ) {
    return call(
      provider.dayOfWeek,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'schedulesForDaySortedByTimeProvider';
}

/// See also [schedulesForDaySortedByTime].
class SchedulesForDaySortedByTimeProvider
    extends AutoDisposeStreamProvider<List<Schedule>> {
  /// See also [schedulesForDaySortedByTime].
  SchedulesForDaySortedByTimeProvider(
    int dayOfWeek,
  ) : this._internal(
          (ref) => schedulesForDaySortedByTime(
            ref as SchedulesForDaySortedByTimeRef,
            dayOfWeek,
          ),
          from: schedulesForDaySortedByTimeProvider,
          name: r'schedulesForDaySortedByTimeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$schedulesForDaySortedByTimeHash,
          dependencies: SchedulesForDaySortedByTimeFamily._dependencies,
          allTransitiveDependencies:
              SchedulesForDaySortedByTimeFamily._allTransitiveDependencies,
          dayOfWeek: dayOfWeek,
        );

  SchedulesForDaySortedByTimeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dayOfWeek,
  }) : super.internal();

  final int dayOfWeek;

  @override
  Override overrideWith(
    Stream<List<Schedule>> Function(SchedulesForDaySortedByTimeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SchedulesForDaySortedByTimeProvider._internal(
        (ref) => create(ref as SchedulesForDaySortedByTimeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dayOfWeek: dayOfWeek,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Schedule>> createElement() {
    return _SchedulesForDaySortedByTimeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SchedulesForDaySortedByTimeProvider &&
        other.dayOfWeek == dayOfWeek;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dayOfWeek.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SchedulesForDaySortedByTimeRef
    on AutoDisposeStreamProviderRef<List<Schedule>> {
  /// The parameter `dayOfWeek` of this provider.
  int get dayOfWeek;
}

class _SchedulesForDaySortedByTimeProviderElement
    extends AutoDisposeStreamProviderElement<List<Schedule>>
    with SchedulesForDaySortedByTimeRef {
  _SchedulesForDaySortedByTimeProviderElement(super.provider);

  @override
  int get dayOfWeek =>
      (origin as SchedulesForDaySortedByTimeProvider).dayOfWeek;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

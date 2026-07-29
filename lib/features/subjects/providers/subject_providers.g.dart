// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subjectRepositoryHash() => r'7e395e01dee37be52d333e9ba928a829d5fea443';

/// See also [subjectRepository].
@ProviderFor(subjectRepository)
final subjectRepositoryProvider = Provider<SubjectRepository>.internal(
  subjectRepository,
  name: r'subjectRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subjectRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubjectRepositoryRef = ProviderRef<SubjectRepository>;
String _$subjectsHash() => r'234dd9948e32c056e6a786ba4501bea290aa4edc';

/// See also [subjects].
@ProviderFor(subjects)
final subjectsProvider = AutoDisposeStreamProvider<List<Subject>>.internal(
  subjects,
  name: r'subjectsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$subjectsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubjectsRef = AutoDisposeStreamProviderRef<List<Subject>>;
String _$subjectHash() => r'0f0a18a48445aa5b79058dbcfeeaa6da91a09c48';

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

/// See also [subject].
@ProviderFor(subject)
const subjectProvider = SubjectFamily();

/// See also [subject].
class SubjectFamily extends Family<AsyncValue<Subject?>> {
  /// See also [subject].
  const SubjectFamily();

  /// See also [subject].
  SubjectProvider call(
    int id,
  ) {
    return SubjectProvider(
      id,
    );
  }

  @override
  SubjectProvider getProviderOverride(
    covariant SubjectProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'subjectProvider';
}

/// See also [subject].
class SubjectProvider extends AutoDisposeFutureProvider<Subject?> {
  /// See also [subject].
  SubjectProvider(
    int id,
  ) : this._internal(
          (ref) => subject(
            ref as SubjectRef,
            id,
          ),
          from: subjectProvider,
          name: r'subjectProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subjectHash,
          dependencies: SubjectFamily._dependencies,
          allTransitiveDependencies: SubjectFamily._allTransitiveDependencies,
          id: id,
        );

  SubjectProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Subject?> Function(SubjectRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubjectProvider._internal(
        (ref) => create(ref as SubjectRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Subject?> createElement() {
    return _SubjectProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SubjectRef on AutoDisposeFutureProviderRef<Subject?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _SubjectProviderElement extends AutoDisposeFutureProviderElement<Subject?>
    with SubjectRef {
  _SubjectProviderElement(super.provider);

  @override
  int get id => (origin as SubjectProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tripsRepositoryHash() => r'a390f0526d9ce931af786a2aa123f4a4ad17e34d';

/// See also [tripsRepository].
@ProviderFor(tripsRepository)
final tripsRepositoryProvider = AutoDisposeProvider<TripsRepository>.internal(
  tripsRepository,
  name: r'tripsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripsRepositoryRef = AutoDisposeProviderRef<TripsRepository>;
String _$tripsStreamHash() => r'9de741a8be49a3ffa3fd089713fb7ef6c86863db';

/// See also [tripsStream].
@ProviderFor(tripsStream)
final tripsStreamProvider = AutoDisposeStreamProvider<List<Trip>>.internal(
  tripsStream,
  name: r'tripsStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tripsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripsStreamRef = AutoDisposeStreamProviderRef<List<Trip>>;
String _$checklistStreamHash() => r'd24b9852943194332a92cd30a727e7fe0913fed5';

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

/// See also [checklistStream].
@ProviderFor(checklistStream)
const checklistStreamProvider = ChecklistStreamFamily();

/// See also [checklistStream].
class ChecklistStreamFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [checklistStream].
  const ChecklistStreamFamily();

  /// See also [checklistStream].
  ChecklistStreamProvider call(
    String tripId,
  ) {
    return ChecklistStreamProvider(
      tripId,
    );
  }

  @override
  ChecklistStreamProvider getProviderOverride(
    covariant ChecklistStreamProvider provider,
  ) {
    return call(
      provider.tripId,
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
  String? get name => r'checklistStreamProvider';
}

/// See also [checklistStream].
class ChecklistStreamProvider
    extends AutoDisposeStreamProvider<List<Map<String, dynamic>>> {
  /// See also [checklistStream].
  ChecklistStreamProvider(
    String tripId,
  ) : this._internal(
          (ref) => checklistStream(
            ref as ChecklistStreamRef,
            tripId,
          ),
          from: checklistStreamProvider,
          name: r'checklistStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$checklistStreamHash,
          dependencies: ChecklistStreamFamily._dependencies,
          allTransitiveDependencies:
              ChecklistStreamFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  ChecklistStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tripId,
  }) : super.internal();

  final String tripId;

  @override
  Override overrideWith(
    Stream<List<Map<String, dynamic>>> Function(ChecklistStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChecklistStreamProvider._internal(
        (ref) => create(ref as ChecklistStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tripId: tripId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Map<String, dynamic>>> createElement() {
    return _ChecklistStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChecklistStreamProvider && other.tripId == tripId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tripId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChecklistStreamRef
    on AutoDisposeStreamProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _ChecklistStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Map<String, dynamic>>>
    with ChecklistStreamRef {
  _ChecklistStreamProviderElement(super.provider);

  @override
  String get tripId => (origin as ChecklistStreamProvider).tripId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

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

String _$expensesStreamHash() => r'25315419999ebcabd061daf90a3974936a74d37a';

/// See also [expensesStream].
@ProviderFor(expensesStream)
const expensesStreamProvider = ExpensesStreamFamily();

/// See also [expensesStream].
class ExpensesStreamFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [expensesStream].
  const ExpensesStreamFamily();

  /// See also [expensesStream].
  ExpensesStreamProvider call(
    String tripId,
  ) {
    return ExpensesStreamProvider(
      tripId,
    );
  }

  @override
  ExpensesStreamProvider getProviderOverride(
    covariant ExpensesStreamProvider provider,
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
  String? get name => r'expensesStreamProvider';
}

/// See also [expensesStream].
class ExpensesStreamProvider
    extends AutoDisposeStreamProvider<List<Map<String, dynamic>>> {
  /// See also [expensesStream].
  ExpensesStreamProvider(
    String tripId,
  ) : this._internal(
          (ref) => expensesStream(
            ref as ExpensesStreamRef,
            tripId,
          ),
          from: expensesStreamProvider,
          name: r'expensesStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$expensesStreamHash,
          dependencies: ExpensesStreamFamily._dependencies,
          allTransitiveDependencies:
              ExpensesStreamFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  ExpensesStreamProvider._internal(
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
    Stream<List<Map<String, dynamic>>> Function(ExpensesStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExpensesStreamProvider._internal(
        (ref) => create(ref as ExpensesStreamRef),
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
    return _ExpensesStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpensesStreamProvider && other.tripId == tripId;
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
mixin ExpensesStreamRef
    on AutoDisposeStreamProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _ExpensesStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Map<String, dynamic>>>
    with ExpensesStreamRef {
  _ExpensesStreamProviderElement(super.provider);

  @override
  String get tripId => (origin as ExpensesStreamProvider).tripId;
}

String _$itineraryStreamHash() => r'7be22ac8753588641e40e9a5dd4857cbdb9b20a2';

/// See also [itineraryStream].
@ProviderFor(itineraryStream)
const itineraryStreamProvider = ItineraryStreamFamily();

/// See also [itineraryStream].
class ItineraryStreamFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [itineraryStream].
  const ItineraryStreamFamily();

  /// See also [itineraryStream].
  ItineraryStreamProvider call(
    String tripId,
  ) {
    return ItineraryStreamProvider(
      tripId,
    );
  }

  @override
  ItineraryStreamProvider getProviderOverride(
    covariant ItineraryStreamProvider provider,
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
  String? get name => r'itineraryStreamProvider';
}

/// See also [itineraryStream].
class ItineraryStreamProvider
    extends AutoDisposeStreamProvider<List<Map<String, dynamic>>> {
  /// See also [itineraryStream].
  ItineraryStreamProvider(
    String tripId,
  ) : this._internal(
          (ref) => itineraryStream(
            ref as ItineraryStreamRef,
            tripId,
          ),
          from: itineraryStreamProvider,
          name: r'itineraryStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itineraryStreamHash,
          dependencies: ItineraryStreamFamily._dependencies,
          allTransitiveDependencies:
              ItineraryStreamFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  ItineraryStreamProvider._internal(
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
    Stream<List<Map<String, dynamic>>> Function(ItineraryStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItineraryStreamProvider._internal(
        (ref) => create(ref as ItineraryStreamRef),
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
    return _ItineraryStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItineraryStreamProvider && other.tripId == tripId;
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
mixin ItineraryStreamRef
    on AutoDisposeStreamProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _ItineraryStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Map<String, dynamic>>>
    with ItineraryStreamRef {
  _ItineraryStreamProviderElement(super.provider);

  @override
  String get tripId => (origin as ItineraryStreamProvider).tripId;
}

String _$galleryStreamHash() => r'abe6213535a5085014f20a6a923b46aaf0666380';

/// See also [galleryStream].
@ProviderFor(galleryStream)
const galleryStreamProvider = GalleryStreamFamily();

/// See also [galleryStream].
class GalleryStreamFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [galleryStream].
  const GalleryStreamFamily();

  /// See also [galleryStream].
  GalleryStreamProvider call(
    String tripId,
  ) {
    return GalleryStreamProvider(
      tripId,
    );
  }

  @override
  GalleryStreamProvider getProviderOverride(
    covariant GalleryStreamProvider provider,
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
  String? get name => r'galleryStreamProvider';
}

/// See also [galleryStream].
class GalleryStreamProvider
    extends AutoDisposeStreamProvider<List<Map<String, dynamic>>> {
  /// See also [galleryStream].
  GalleryStreamProvider(
    String tripId,
  ) : this._internal(
          (ref) => galleryStream(
            ref as GalleryStreamRef,
            tripId,
          ),
          from: galleryStreamProvider,
          name: r'galleryStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$galleryStreamHash,
          dependencies: GalleryStreamFamily._dependencies,
          allTransitiveDependencies:
              GalleryStreamFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  GalleryStreamProvider._internal(
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
    Stream<List<Map<String, dynamic>>> Function(GalleryStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GalleryStreamProvider._internal(
        (ref) => create(ref as GalleryStreamRef),
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
    return _GalleryStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GalleryStreamProvider && other.tripId == tripId;
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
mixin GalleryStreamRef
    on AutoDisposeStreamProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _GalleryStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Map<String, dynamic>>>
    with GalleryStreamRef {
  _GalleryStreamProviderElement(super.provider);

  @override
  String get tripId => (origin as GalleryStreamProvider).tripId;
}

String _$documentsStreamHash() => r'418fa9f9b9671e3a83fc3795e27c86f8ad127156';

/// See also [documentsStream].
@ProviderFor(documentsStream)
const documentsStreamProvider = DocumentsStreamFamily();

/// See also [documentsStream].
class DocumentsStreamFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [documentsStream].
  const DocumentsStreamFamily();

  /// See also [documentsStream].
  DocumentsStreamProvider call(
    String tripId,
  ) {
    return DocumentsStreamProvider(
      tripId,
    );
  }

  @override
  DocumentsStreamProvider getProviderOverride(
    covariant DocumentsStreamProvider provider,
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
  String? get name => r'documentsStreamProvider';
}

/// See also [documentsStream].
class DocumentsStreamProvider
    extends AutoDisposeStreamProvider<List<Map<String, dynamic>>> {
  /// See also [documentsStream].
  DocumentsStreamProvider(
    String tripId,
  ) : this._internal(
          (ref) => documentsStream(
            ref as DocumentsStreamRef,
            tripId,
          ),
          from: documentsStreamProvider,
          name: r'documentsStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$documentsStreamHash,
          dependencies: DocumentsStreamFamily._dependencies,
          allTransitiveDependencies:
              DocumentsStreamFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  DocumentsStreamProvider._internal(
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
    Stream<List<Map<String, dynamic>>> Function(DocumentsStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentsStreamProvider._internal(
        (ref) => create(ref as DocumentsStreamRef),
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
    return _DocumentsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentsStreamProvider && other.tripId == tripId;
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
mixin DocumentsStreamRef
    on AutoDisposeStreamProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _DocumentsStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Map<String, dynamic>>>
    with DocumentsStreamRef {
  _DocumentsStreamProviderElement(super.provider);

  @override
  String get tripId => (origin as DocumentsStreamProvider).tripId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

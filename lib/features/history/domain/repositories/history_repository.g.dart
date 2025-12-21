// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the Hive box.

@ProviderFor(historyBox)
const historyBoxProvider = HistoryBoxProvider._();

/// Provider for the Hive box.

final class HistoryBoxProvider
    extends $FunctionalProvider<Box<String>, Box<String>, Box<String>>
    with $Provider<Box<String>> {
  /// Provider for the Hive box.
  const HistoryBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyBoxHash();

  @$internal
  @override
  $ProviderElement<Box<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Box<String> create(Ref ref) {
    return historyBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<String>>(value),
    );
  }
}

String _$historyBoxHash() => r'3998ee23260344900b346a3b7507959a134af328';

/// Provider for the history repository.

@ProviderFor(historyRepository)
const historyRepositoryProvider = HistoryRepositoryProvider._();

/// Provider for the history repository.

final class HistoryRepositoryProvider
    extends
        $FunctionalProvider<
          HistoryRepository,
          HistoryRepository,
          HistoryRepository
        >
    with $Provider<HistoryRepository> {
  /// Provider for the history repository.
  const HistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyRepositoryHash();

  @$internal
  @override
  $ProviderElement<HistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HistoryRepository create(Ref ref) {
    return historyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryRepository>(value),
    );
  }
}

String _$historyRepositoryHash() => r'dece46b37eca244d90e8c27588594c3bcc18a233';

/// Provider for the list of calculation records.

@ProviderFor(HistoryRecords)
const historyRecordsProvider = HistoryRecordsProvider._();

/// Provider for the list of calculation records.
final class HistoryRecordsProvider
    extends $NotifierProvider<HistoryRecords, List<CalculationRecord>> {
  /// Provider for the list of calculation records.
  const HistoryRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyRecordsHash();

  @$internal
  @override
  HistoryRecords create() => HistoryRecords();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CalculationRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CalculationRecord>>(value),
    );
  }
}

String _$historyRecordsHash() => r'406a151503be19eaff0dc66312c2687d7651b305';

/// Provider for the list of calculation records.

abstract class _$HistoryRecords extends $Notifier<List<CalculationRecord>> {
  List<CalculationRecord> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<List<CalculationRecord>, List<CalculationRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<CalculationRecord>, List<CalculationRecord>>,
              List<CalculationRecord>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

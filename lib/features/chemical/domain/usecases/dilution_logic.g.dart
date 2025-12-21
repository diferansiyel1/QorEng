// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dilution_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Dilution Calculator.
///
/// Formula: C1 × V1 = C2 × V2
/// V1 (stock) = (C2 × V2) / C1
/// V_water = V2 - V1

@ProviderFor(DilutionCalculator)
const dilutionCalculatorProvider = DilutionCalculatorProvider._();

/// Dilution Calculator.
///
/// Formula: C1 × V1 = C2 × V2
/// V1 (stock) = (C2 × V2) / C1
/// V_water = V2 - V1
final class DilutionCalculatorProvider
    extends $NotifierProvider<DilutionCalculator, DilutionInput> {
  /// Dilution Calculator.
  ///
  /// Formula: C1 × V1 = C2 × V2
  /// V1 (stock) = (C2 × V2) / C1
  /// V_water = V2 - V1
  const DilutionCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dilutionCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dilutionCalculatorHash();

  @$internal
  @override
  DilutionCalculator create() => DilutionCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DilutionInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DilutionInput>(value),
    );
  }
}

String _$dilutionCalculatorHash() =>
    r'6f9e46965691c62659e0b400a0d2c141a7550753';

/// Dilution Calculator.
///
/// Formula: C1 × V1 = C2 × V2
/// V1 (stock) = (C2 × V2) / C1
/// V_water = V2 - V1

abstract class _$DilutionCalculator extends $Notifier<DilutionInput> {
  DilutionInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DilutionInput, DilutionInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DilutionInput, DilutionInput>,
              DilutionInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed dilution result.

@ProviderFor(dilutionResult)
const dilutionResultProvider = DilutionResultProvider._();

/// Computed dilution result.

final class DilutionResultProvider
    extends
        $FunctionalProvider<DilutionResult?, DilutionResult?, DilutionResult?>
    with $Provider<DilutionResult?> {
  /// Computed dilution result.
  const DilutionResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dilutionResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dilutionResultHash();

  @$internal
  @override
  $ProviderElement<DilutionResult?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DilutionResult? create(Ref ref) {
    return dilutionResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DilutionResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DilutionResult?>(value),
    );
  }
}

String _$dilutionResultHash() => r'dc23c77a3160a9b5b62725c99067303867e3ebb1';

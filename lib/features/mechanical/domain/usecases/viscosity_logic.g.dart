// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viscosity_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Viscosity Converter Calculator.

@ProviderFor(ViscosityConverter)
const viscosityConverterProvider = ViscosityConverterProvider._();

/// Viscosity Converter Calculator.
final class ViscosityConverterProvider
    extends $NotifierProvider<ViscosityConverter, ViscosityConverterInput> {
  /// Viscosity Converter Calculator.
  const ViscosityConverterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viscosityConverterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viscosityConverterHash();

  @$internal
  @override
  ViscosityConverter create() => ViscosityConverter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViscosityConverterInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViscosityConverterInput>(value),
    );
  }
}

String _$viscosityConverterHash() =>
    r'5d0b03027d7610eff0b1997a7704e2a8196affdf';

/// Viscosity Converter Calculator.

abstract class _$ViscosityConverter extends $Notifier<ViscosityConverterInput> {
  ViscosityConverterInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<ViscosityConverterInput, ViscosityConverterInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ViscosityConverterInput, ViscosityConverterInput>,
              ViscosityConverterInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed viscosity conversion.

@ProviderFor(viscosityConverterResult)
const viscosityConverterResultProvider = ViscosityConverterResultProvider._();

/// Computed viscosity conversion.

final class ViscosityConverterResultProvider
    extends
        $FunctionalProvider<
          ViscosityConverterResult?,
          ViscosityConverterResult?,
          ViscosityConverterResult?
        >
    with $Provider<ViscosityConverterResult?> {
  /// Computed viscosity conversion.
  const ViscosityConverterResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viscosityConverterResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viscosityConverterResultHash();

  @$internal
  @override
  $ProviderElement<ViscosityConverterResult?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ViscosityConverterResult? create(Ref ref) {
    return viscosityConverterResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViscosityConverterResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViscosityConverterResult?>(value),
    );
  }
}

String _$viscosityConverterResultHash() =>
    r'40d7e2b507ac09f8b31f2971ec2065c746619833';

/// Efflux Cup Calculator.

@ProviderFor(EffluxCupCalculator)
const effluxCupCalculatorProvider = EffluxCupCalculatorProvider._();

/// Efflux Cup Calculator.
final class EffluxCupCalculatorProvider
    extends $NotifierProvider<EffluxCupCalculator, EffluxCupInput> {
  /// Efflux Cup Calculator.
  const EffluxCupCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effluxCupCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effluxCupCalculatorHash();

  @$internal
  @override
  EffluxCupCalculator create() => EffluxCupCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EffluxCupInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EffluxCupInput>(value),
    );
  }
}

String _$effluxCupCalculatorHash() =>
    r'2d0e335960b7f94c1e24b478128d19ccf0e82ad4';

/// Efflux Cup Calculator.

abstract class _$EffluxCupCalculator extends $Notifier<EffluxCupInput> {
  EffluxCupInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<EffluxCupInput, EffluxCupInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EffluxCupInput, EffluxCupInput>,
              EffluxCupInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed efflux cup result.

@ProviderFor(effluxCupResult)
const effluxCupResultProvider = EffluxCupResultProvider._();

/// Computed efflux cup result.

final class EffluxCupResultProvider
    extends
        $FunctionalProvider<
          EffluxCupResult?,
          EffluxCupResult?,
          EffluxCupResult?
        >
    with $Provider<EffluxCupResult?> {
  /// Computed efflux cup result.
  const EffluxCupResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effluxCupResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effluxCupResultHash();

  @$internal
  @override
  $ProviderElement<EffluxCupResult?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EffluxCupResult? create(Ref ref) {
    return effluxCupResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EffluxCupResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EffluxCupResult?>(value),
    );
  }
}

String _$effluxCupResultHash() => r'a3e4a937c90956c7303d43ea14accbb7b8ef332e';

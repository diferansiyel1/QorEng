// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'electrochemistry_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// pH Sensor Diagnostics (Nernst Equation).
///
/// E = E0 - (2.303 * R * T / F) * (pH - 7)
/// Solving for pH: pH = 7 - (E - E0) / slope
/// Theoretical slope = -0.1984 * T(K) mV/pH

@ProviderFor(PhSensorCalculator)
const phSensorCalculatorProvider = PhSensorCalculatorProvider._();

/// pH Sensor Diagnostics (Nernst Equation).
///
/// E = E0 - (2.303 * R * T / F) * (pH - 7)
/// Solving for pH: pH = 7 - (E - E0) / slope
/// Theoretical slope = -0.1984 * T(K) mV/pH
final class PhSensorCalculatorProvider
    extends $NotifierProvider<PhSensorCalculator, PhSensorInput> {
  /// pH Sensor Diagnostics (Nernst Equation).
  ///
  /// E = E0 - (2.303 * R * T / F) * (pH - 7)
  /// Solving for pH: pH = 7 - (E - E0) / slope
  /// Theoretical slope = -0.1984 * T(K) mV/pH
  const PhSensorCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'phSensorCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$phSensorCalculatorHash();

  @$internal
  @override
  PhSensorCalculator create() => PhSensorCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhSensorInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhSensorInput>(value),
    );
  }
}

String _$phSensorCalculatorHash() =>
    r'f2dc139e46a6cb9dc2b63e9eb446bfaa0a608acb';

/// pH Sensor Diagnostics (Nernst Equation).
///
/// E = E0 - (2.303 * R * T / F) * (pH - 7)
/// Solving for pH: pH = 7 - (E - E0) / slope
/// Theoretical slope = -0.1984 * T(K) mV/pH

abstract class _$PhSensorCalculator extends $Notifier<PhSensorInput> {
  PhSensorInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PhSensorInput, PhSensorInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PhSensorInput, PhSensorInput>,
              PhSensorInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed pH sensor result.

@ProviderFor(phSensorResult)
const phSensorResultProvider = PhSensorResultProvider._();

/// Computed pH sensor result.

final class PhSensorResultProvider
    extends
        $FunctionalProvider<PhSensorResult?, PhSensorResult?, PhSensorResult?>
    with $Provider<PhSensorResult?> {
  /// Computed pH sensor result.
  const PhSensorResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'phSensorResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$phSensorResultHash();

  @$internal
  @override
  $ProviderElement<PhSensorResult?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhSensorResult? create(Ref ref) {
    return phSensorResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhSensorResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhSensorResult?>(value),
    );
  }
}

String _$phSensorResultHash() => r'c90ea3ebb61bbd4888cb711d09856ea38e97e516';

/// Arrhenius Rate Ratio Calculator.
///
/// k2/k1 = exp[(Ea/R) * (1/T1 - 1/T2)]
/// Where:
/// - Ea: Activation energy (J/mol)
/// - R: Gas constant (8.314 J/(mol·K))
/// - T1, T2: Temperatures (K)

@ProviderFor(ArrheniusCalculator)
const arrheniusCalculatorProvider = ArrheniusCalculatorProvider._();

/// Arrhenius Rate Ratio Calculator.
///
/// k2/k1 = exp[(Ea/R) * (1/T1 - 1/T2)]
/// Where:
/// - Ea: Activation energy (J/mol)
/// - R: Gas constant (8.314 J/(mol·K))
/// - T1, T2: Temperatures (K)
final class ArrheniusCalculatorProvider
    extends $NotifierProvider<ArrheniusCalculator, ArrheniusInput> {
  /// Arrhenius Rate Ratio Calculator.
  ///
  /// k2/k1 = exp[(Ea/R) * (1/T1 - 1/T2)]
  /// Where:
  /// - Ea: Activation energy (J/mol)
  /// - R: Gas constant (8.314 J/(mol·K))
  /// - T1, T2: Temperatures (K)
  const ArrheniusCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'arrheniusCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$arrheniusCalculatorHash();

  @$internal
  @override
  ArrheniusCalculator create() => ArrheniusCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArrheniusInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArrheniusInput>(value),
    );
  }
}

String _$arrheniusCalculatorHash() =>
    r'543c27cec7122f3ee78308fe71a248f1356a1e57';

/// Arrhenius Rate Ratio Calculator.
///
/// k2/k1 = exp[(Ea/R) * (1/T1 - 1/T2)]
/// Where:
/// - Ea: Activation energy (J/mol)
/// - R: Gas constant (8.314 J/(mol·K))
/// - T1, T2: Temperatures (K)

abstract class _$ArrheniusCalculator extends $Notifier<ArrheniusInput> {
  ArrheniusInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ArrheniusInput, ArrheniusInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ArrheniusInput, ArrheniusInput>,
              ArrheniusInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed Arrhenius rate ratio result.

@ProviderFor(arrheniusResult)
const arrheniusResultProvider = ArrheniusResultProvider._();

/// Computed Arrhenius rate ratio result.

final class ArrheniusResultProvider
    extends
        $FunctionalProvider<
          ArrheniusResult?,
          ArrheniusResult?,
          ArrheniusResult?
        >
    with $Provider<ArrheniusResult?> {
  /// Computed Arrhenius rate ratio result.
  const ArrheniusResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'arrheniusResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$arrheniusResultHash();

  @$internal
  @override
  $ProviderElement<ArrheniusResult?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ArrheniusResult? create(Ref ref) {
    return arrheniusResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArrheniusResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArrheniusResult?>(value),
    );
  }
}

String _$arrheniusResultHash() => r'8295180454e577034ab1190e73ae3d9cf52e0234';

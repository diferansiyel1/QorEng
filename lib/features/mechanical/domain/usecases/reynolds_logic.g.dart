// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reynolds_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reynolds Number Calculator.
///
/// Formula: Re = (ρ × V × D) / μ
/// Where:
/// - ρ: Density (kg/m³)
/// - V: Velocity (m/s)
/// - D: Diameter (m)
/// - μ: Dynamic Viscosity (Pa·s)

@ProviderFor(ReynoldsCalculator)
const reynoldsCalculatorProvider = ReynoldsCalculatorProvider._();

/// Reynolds Number Calculator.
///
/// Formula: Re = (ρ × V × D) / μ
/// Where:
/// - ρ: Density (kg/m³)
/// - V: Velocity (m/s)
/// - D: Diameter (m)
/// - μ: Dynamic Viscosity (Pa·s)
final class ReynoldsCalculatorProvider
    extends $NotifierProvider<ReynoldsCalculator, ReynoldsInput> {
  /// Reynolds Number Calculator.
  ///
  /// Formula: Re = (ρ × V × D) / μ
  /// Where:
  /// - ρ: Density (kg/m³)
  /// - V: Velocity (m/s)
  /// - D: Diameter (m)
  /// - μ: Dynamic Viscosity (Pa·s)
  const ReynoldsCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reynoldsCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reynoldsCalculatorHash();

  @$internal
  @override
  ReynoldsCalculator create() => ReynoldsCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReynoldsInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReynoldsInput>(value),
    );
  }
}

String _$reynoldsCalculatorHash() =>
    r'2f2bf6b080f71035473f6bc9a108c783ee27d39e';

/// Reynolds Number Calculator.
///
/// Formula: Re = (ρ × V × D) / μ
/// Where:
/// - ρ: Density (kg/m³)
/// - V: Velocity (m/s)
/// - D: Diameter (m)
/// - μ: Dynamic Viscosity (Pa·s)

abstract class _$ReynoldsCalculator extends $Notifier<ReynoldsInput> {
  ReynoldsInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ReynoldsInput, ReynoldsInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReynoldsInput, ReynoldsInput>,
              ReynoldsInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed Reynolds number result.

@ProviderFor(reynoldsResult)
const reynoldsResultProvider = ReynoldsResultProvider._();

/// Computed Reynolds number result.

final class ReynoldsResultProvider
    extends
        $FunctionalProvider<ReynoldsResult?, ReynoldsResult?, ReynoldsResult?>
    with $Provider<ReynoldsResult?> {
  /// Computed Reynolds number result.
  const ReynoldsResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reynoldsResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reynoldsResultHash();

  @$internal
  @override
  $ProviderElement<ReynoldsResult?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReynoldsResult? create(Ref ref) {
    return reynoldsResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReynoldsResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReynoldsResult?>(value),
    );
  }
}

String _$reynoldsResultHash() => r'd4afed4d300e66ec08589324b15fecb25104d923';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hydraulic_force_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Hydraulic Cylinder Force Calculator.
///
/// Push Force = P × A_bore (using full bore area)
/// Pull Force = P × A_annular (bore area minus rod area)
///
/// Where:
/// - P: Pressure (bar)
/// - A: Area (mm²)
/// - Force in kN = (P × A) / 10000

@ProviderFor(HydraulicForceCalculator)
const hydraulicForceCalculatorProvider = HydraulicForceCalculatorProvider._();

/// Hydraulic Cylinder Force Calculator.
///
/// Push Force = P × A_bore (using full bore area)
/// Pull Force = P × A_annular (bore area minus rod area)
///
/// Where:
/// - P: Pressure (bar)
/// - A: Area (mm²)
/// - Force in kN = (P × A) / 10000
final class HydraulicForceCalculatorProvider
    extends $NotifierProvider<HydraulicForceCalculator, HydraulicForceInput> {
  /// Hydraulic Cylinder Force Calculator.
  ///
  /// Push Force = P × A_bore (using full bore area)
  /// Pull Force = P × A_annular (bore area minus rod area)
  ///
  /// Where:
  /// - P: Pressure (bar)
  /// - A: Area (mm²)
  /// - Force in kN = (P × A) / 10000
  const HydraulicForceCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hydraulicForceCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hydraulicForceCalculatorHash();

  @$internal
  @override
  HydraulicForceCalculator create() => HydraulicForceCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HydraulicForceInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HydraulicForceInput>(value),
    );
  }
}

String _$hydraulicForceCalculatorHash() =>
    r'5876d0e7da1d2d0b574e4e7a3c87e4ca3e919456';

/// Hydraulic Cylinder Force Calculator.
///
/// Push Force = P × A_bore (using full bore area)
/// Pull Force = P × A_annular (bore area minus rod area)
///
/// Where:
/// - P: Pressure (bar)
/// - A: Area (mm²)
/// - Force in kN = (P × A) / 10000

abstract class _$HydraulicForceCalculator
    extends $Notifier<HydraulicForceInput> {
  HydraulicForceInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<HydraulicForceInput, HydraulicForceInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HydraulicForceInput, HydraulicForceInput>,
              HydraulicForceInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed hydraulic force result based on current input.

@ProviderFor(hydraulicForceResult)
const hydraulicForceResultProvider = HydraulicForceResultProvider._();

/// Computed hydraulic force result based on current input.

final class HydraulicForceResultProvider
    extends
        $FunctionalProvider<
          HydraulicForceResult?,
          HydraulicForceResult?,
          HydraulicForceResult?
        >
    with $Provider<HydraulicForceResult?> {
  /// Computed hydraulic force result based on current input.
  const HydraulicForceResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hydraulicForceResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hydraulicForceResultHash();

  @$internal
  @override
  $ProviderElement<HydraulicForceResult?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HydraulicForceResult? create(Ref ref) {
    return hydraulicForceResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HydraulicForceResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HydraulicForceResult?>(value),
    );
  }
}

String _$hydraulicForceResultHash() =>
    r'a90ee45cd0ceec9f8701755428603ee0954220ea';

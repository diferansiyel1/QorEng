// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voltage_drop_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Calculate voltage drop using the formula:
/// V_drop = (k × I × L × ρ) / S
///
/// Where:
/// - k: 2 for Single Phase, √3 for Three Phase
/// - I: Current (Amperes)
/// - L: Length (meters)
/// - ρ: Resistivity (Ω·mm²/m)
/// - S: Cross-section area (mm²)

@ProviderFor(VoltageDropCalculator)
const voltageDropCalculatorProvider = VoltageDropCalculatorProvider._();

/// Calculate voltage drop using the formula:
/// V_drop = (k × I × L × ρ) / S
///
/// Where:
/// - k: 2 for Single Phase, √3 for Three Phase
/// - I: Current (Amperes)
/// - L: Length (meters)
/// - ρ: Resistivity (Ω·mm²/m)
/// - S: Cross-section area (mm²)
final class VoltageDropCalculatorProvider
    extends $NotifierProvider<VoltageDropCalculator, VoltageDropInput> {
  /// Calculate voltage drop using the formula:
  /// V_drop = (k × I × L × ρ) / S
  ///
  /// Where:
  /// - k: 2 for Single Phase, √3 for Three Phase
  /// - I: Current (Amperes)
  /// - L: Length (meters)
  /// - ρ: Resistivity (Ω·mm²/m)
  /// - S: Cross-section area (mm²)
  const VoltageDropCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voltageDropCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voltageDropCalculatorHash();

  @$internal
  @override
  VoltageDropCalculator create() => VoltageDropCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoltageDropInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoltageDropInput>(value),
    );
  }
}

String _$voltageDropCalculatorHash() =>
    r'23318ee3bf8ce607de81748a8808547aa1824c9f';

/// Calculate voltage drop using the formula:
/// V_drop = (k × I × L × ρ) / S
///
/// Where:
/// - k: 2 for Single Phase, √3 for Three Phase
/// - I: Current (Amperes)
/// - L: Length (meters)
/// - ρ: Resistivity (Ω·mm²/m)
/// - S: Cross-section area (mm²)

abstract class _$VoltageDropCalculator extends $Notifier<VoltageDropInput> {
  VoltageDropInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VoltageDropInput, VoltageDropInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoltageDropInput, VoltageDropInput>,
              VoltageDropInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed voltage drop result based on current input.

@ProviderFor(voltageDropResult)
const voltageDropResultProvider = VoltageDropResultProvider._();

/// Computed voltage drop result based on current input.

final class VoltageDropResultProvider
    extends
        $FunctionalProvider<
          VoltageDropResult?,
          VoltageDropResult?,
          VoltageDropResult?
        >
    with $Provider<VoltageDropResult?> {
  /// Computed voltage drop result based on current input.
  const VoltageDropResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voltageDropResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voltageDropResultHash();

  @$internal
  @override
  $ProviderElement<VoltageDropResult?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VoltageDropResult? create(Ref ref) {
    return voltageDropResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoltageDropResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoltageDropResult?>(value),
    );
  }
}

String _$voltageDropResultHash() => r'c4b4bca8da23c0de15983ad7d0664637a6e6499a';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pressure_drop_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pipe Pressure Drop Calculator (Darcy-Weisbach).
///
/// Formula: ΔP = f × (L/D) × (ρ × V²) / 2
/// Where:
/// - f: Friction factor
/// - L: Length (m)
/// - D: Diameter (m)
/// - ρ: Density (kg/m³)
/// - V: Velocity (m/s)

@ProviderFor(PressureDropCalculator)
const pressureDropCalculatorProvider = PressureDropCalculatorProvider._();

/// Pipe Pressure Drop Calculator (Darcy-Weisbach).
///
/// Formula: ΔP = f × (L/D) × (ρ × V²) / 2
/// Where:
/// - f: Friction factor
/// - L: Length (m)
/// - D: Diameter (m)
/// - ρ: Density (kg/m³)
/// - V: Velocity (m/s)
final class PressureDropCalculatorProvider
    extends $NotifierProvider<PressureDropCalculator, PressureDropInput> {
  /// Pipe Pressure Drop Calculator (Darcy-Weisbach).
  ///
  /// Formula: ΔP = f × (L/D) × (ρ × V²) / 2
  /// Where:
  /// - f: Friction factor
  /// - L: Length (m)
  /// - D: Diameter (m)
  /// - ρ: Density (kg/m³)
  /// - V: Velocity (m/s)
  const PressureDropCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pressureDropCalculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pressureDropCalculatorHash();

  @$internal
  @override
  PressureDropCalculator create() => PressureDropCalculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PressureDropInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PressureDropInput>(value),
    );
  }
}

String _$pressureDropCalculatorHash() =>
    r'f79578698f2425a4ff348474c60fe8a135e544a2';

/// Pipe Pressure Drop Calculator (Darcy-Weisbach).
///
/// Formula: ΔP = f × (L/D) × (ρ × V²) / 2
/// Where:
/// - f: Friction factor
/// - L: Length (m)
/// - D: Diameter (m)
/// - ρ: Density (kg/m³)
/// - V: Velocity (m/s)

abstract class _$PressureDropCalculator extends $Notifier<PressureDropInput> {
  PressureDropInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PressureDropInput, PressureDropInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PressureDropInput, PressureDropInput>,
              PressureDropInput,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Computed pressure drop result.

@ProviderFor(pressureDropResult)
const pressureDropResultProvider = PressureDropResultProvider._();

/// Computed pressure drop result.

final class PressureDropResultProvider
    extends
        $FunctionalProvider<
          PressureDropResult?,
          PressureDropResult?,
          PressureDropResult?
        >
    with $Provider<PressureDropResult?> {
  /// Computed pressure drop result.
  const PressureDropResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pressureDropResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pressureDropResultHash();

  @$internal
  @override
  $ProviderElement<PressureDropResult?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PressureDropResult? create(Ref ref) {
    return pressureDropResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PressureDropResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PressureDropResult?>(value),
    );
  }
}

String _$pressureDropResultHash() =>
    r'c80f9c48a205f77088a2bef630a89df14d89e527';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pressure_drop_logic.g.dart';

/// Input parameters for pipe pressure drop calculation.
class PressureDropInput {
  const PressureDropInput({
    required this.length,
    required this.diameter,
    required this.velocity,
    required this.density,
    required this.frictionFactor,
  });

  /// Pipe length in meters
  final double length;

  /// Pipe diameter in mm
  final double diameter;

  /// Flow velocity in m/s
  final double velocity;

  /// Fluid density in kg/m³
  final double density;

  /// Darcy friction factor (dimensionless)
  final double frictionFactor;

  /// Get diameter in meters
  double get diameterInMeters => diameter / 1000;

  PressureDropInput copyWith({
    double? length,
    double? diameter,
    double? velocity,
    double? density,
    double? frictionFactor,
  }) {
    return PressureDropInput(
      length: length ?? this.length,
      diameter: diameter ?? this.diameter,
      velocity: velocity ?? this.velocity,
      density: density ?? this.density,
      frictionFactor: frictionFactor ?? this.frictionFactor,
    );
  }
}

/// Result of pressure drop calculation.
class PressureDropResult {
  const PressureDropResult({
    required this.pressureDropBar,
    required this.pressureDropPsi,
    required this.pressureDropPa,
    required this.formula,
  });

  /// Pressure drop in Bar
  final double pressureDropBar;

  /// Pressure drop in PSI
  final double pressureDropPsi;

  /// Pressure drop in Pascal
  final double pressureDropPa;

  /// Formula representation
  final String formula;
}

/// Pipe Pressure Drop Calculator (Darcy-Weisbach).
///
/// Formula: ΔP = f × (L/D) × (ρ × V²) / 2
/// Where:
/// - f: Friction factor
/// - L: Length (m)
/// - D: Diameter (m)
/// - ρ: Density (kg/m³)
/// - V: Velocity (m/s)
@riverpod
class PressureDropCalculator extends _$PressureDropCalculator {
  @override
  PressureDropInput build() {
    return const PressureDropInput(
      length: 0,
      diameter: 0,
      velocity: 0,
      density: 1000, // Water
      frictionFactor: 0.02, // Typical value
    );
  }

  void updateLength(double value) {
    state = state.copyWith(length: value);
  }

  void updateDiameter(double value) {
    state = state.copyWith(diameter: value);
  }

  void updateVelocity(double value) {
    state = state.copyWith(velocity: value);
  }

  void updateDensity(double value) {
    state = state.copyWith(density: value);
  }

  void updateFrictionFactor(double value) {
    state = state.copyWith(frictionFactor: value);
  }

  void reset() {
    state = const PressureDropInput(
      length: 0,
      diameter: 0,
      velocity: 0,
      density: 1000,
      frictionFactor: 0.02,
    );
  }
}

/// Computed pressure drop result.
@riverpod
PressureDropResult? pressureDropResult(Ref ref) {
  final input = ref.watch(pressureDropCalculatorProvider);

  // Validate inputs - avoid division by zero
  if (input.length <= 0 ||
      input.diameter <= 0 ||
      input.velocity <= 0 ||
      input.density <= 0 ||
      input.frictionFactor <= 0) {
    return null;
  }

  final diameterM = input.diameterInMeters;

  // ΔP (Pa) = f × (L/D) × (ρ × V²) / 2
  final pressurePa = input.frictionFactor *
      (input.length / diameterM) *
      (input.density * input.velocity * input.velocity) /
      2;

  // Convert to Bar and PSI
  final pressureBar = pressurePa / 100000; // 1 Bar = 100000 Pa
  final pressurePsi = pressurePa / 6894.76; // 1 PSI = 6894.76 Pa

  final formula =
      'ΔP = ${input.frictionFactor} × (${input.length}/${diameterM.toStringAsFixed(4)}) × (${input.density} × ${input.velocity}²) / 2';

  return PressureDropResult(
    pressureDropBar: pressureBar,
    pressureDropPsi: pressurePsi,
    pressureDropPa: pressurePa,
    formula: formula,
  );
}

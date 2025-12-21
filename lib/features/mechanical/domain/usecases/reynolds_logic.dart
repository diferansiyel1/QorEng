import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reynolds_logic.g.dart';

/// Flow regime based on Reynolds number.
enum FlowRegime {
  laminar('Laminar Flow', 'Smooth, orderly flow'),
  transient('Transient Flow', 'Unstable, transitional flow'),
  turbulent('Turbulent Flow', 'Chaotic, mixing flow');

  const FlowRegime(this.label, this.description);

  final String label;
  final String description;
}

/// Input parameters for Reynolds number calculation.
class ReynoldsInput {
  const ReynoldsInput({
    required this.density,
    required this.velocity,
    required this.diameter,
    required this.viscosity,
  });

  /// Fluid density in kg/m³
  final double density;

  /// Flow velocity in m/s
  final double velocity;

  /// Pipe diameter in mm
  final double diameter;

  /// Dynamic viscosity in Pa·s
  final double viscosity;

  /// Get diameter in meters
  double get diameterInMeters => diameter / 1000;

  ReynoldsInput copyWith({
    double? density,
    double? velocity,
    double? diameter,
    double? viscosity,
  }) {
    return ReynoldsInput(
      density: density ?? this.density,
      velocity: velocity ?? this.velocity,
      diameter: diameter ?? this.diameter,
      viscosity: viscosity ?? this.viscosity,
    );
  }
}

/// Result of Reynolds number calculation.
class ReynoldsResult {
  const ReynoldsResult({
    required this.reynoldsNumber,
    required this.regime,
    required this.formula,
  });

  /// Calculated Reynolds number (dimensionless)
  final double reynoldsNumber;

  /// Flow regime classification
  final FlowRegime regime;

  /// Formula representation
  final String formula;
}

/// Reynolds Number Calculator.
///
/// Formula: Re = (ρ × V × D) / μ
/// Where:
/// - ρ: Density (kg/m³)
/// - V: Velocity (m/s)
/// - D: Diameter (m)
/// - μ: Dynamic Viscosity (Pa·s)
@riverpod
class ReynoldsCalculator extends _$ReynoldsCalculator {
  @override
  ReynoldsInput build() {
    return const ReynoldsInput(
      density: 1000, // Water at 20°C
      velocity: 0,
      diameter: 0,
      viscosity: 0.001, // Water at 20°C
    );
  }

  void updateDensity(double value) {
    state = state.copyWith(density: value);
  }

  void updateVelocity(double value) {
    state = state.copyWith(velocity: value);
  }

  void updateDiameter(double value) {
    state = state.copyWith(diameter: value);
  }

  void updateViscosity(double value) {
    state = state.copyWith(viscosity: value);
  }

  void reset() {
    state = const ReynoldsInput(
      density: 1000,
      velocity: 0,
      diameter: 0,
      viscosity: 0.001,
    );
  }
}

/// Computed Reynolds number result.
@riverpod
ReynoldsResult? reynoldsResult(Ref ref) {
  final input = ref.watch(reynoldsCalculatorProvider);

  // Validate inputs - avoid division by zero
  if (input.velocity <= 0 ||
      input.diameter <= 0 ||
      input.density <= 0 ||
      input.viscosity <= 0) {
    return null;
  }

  final diameterM = input.diameterInMeters;

  // Re = (ρ × V × D) / μ
  final re = (input.density * input.velocity * diameterM) / input.viscosity;

  // Determine flow regime
  final FlowRegime regime;
  if (re < 2300) {
    regime = FlowRegime.laminar;
  } else if (re < 4000) {
    regime = FlowRegime.transient;
  } else {
    regime = FlowRegime.turbulent;
  }

  final formula =
      'Re = (${input.density} × ${input.velocity} × $diameterM) / ${input.viscosity}';

  return ReynoldsResult(
    reynoldsNumber: re,
    regime: regime,
    formula: formula,
  );
}

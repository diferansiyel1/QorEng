import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'electrochemistry_logic.g.dart';

/// Constants for electrochemistry calculations
abstract final class ElectrochemConstants {
  /// Gas constant R in J/(mol·K)
  static const double gasConstant = 8.314;

  /// Faraday constant F in C/mol
  static const double faradayConstant = 96485;

  /// Nernst slope coefficient: 2.303 * R / F
  static const double nernstCoefficient = 0.0001984;
}

/// Input for pH sensor diagnostics.
class PhSensorInput {
  const PhSensorInput({
    required this.measuredMv,
    required this.temperatureC,
    required this.e0,
  });

  /// Measured mV from sensor
  final double measuredMv;

  /// Temperature in Celsius
  final double temperatureC;

  /// Isopotential point (usually 0 mV at pH 7)
  final double e0;

  /// Temperature in Kelvin
  double get temperatureK => temperatureC + 273.15;

  PhSensorInput copyWith({
    double? measuredMv,
    double? temperatureC,
    double? e0,
  }) {
    return PhSensorInput(
      measuredMv: measuredMv ?? this.measuredMv,
      temperatureC: temperatureC ?? this.temperatureC,
      e0: e0 ?? this.e0,
    );
  }
}

/// Result of pH sensor diagnostics.
class PhSensorResult {
  const PhSensorResult({
    required this.calculatedPh,
    required this.theoreticalSlope,
    required this.actualSlope,
    required this.slopeEfficiency,
    required this.formula,
  });

  /// Calculated pH value
  final double calculatedPh;

  /// Theoretical Nernst slope (mV/pH) at given temperature
  final double theoreticalSlope;

  /// Actual measured slope (mV/pH)
  final double actualSlope;

  /// Slope efficiency as percentage
  final double slopeEfficiency;

  /// Formula representation
  final String formula;
}

/// pH Sensor Diagnostics (Nernst Equation).
///
/// E = E0 - (2.303 * R * T / F) * (pH - 7)
/// Solving for pH: pH = 7 - (E - E0) / slope
/// Theoretical slope = -0.1984 * T(K) mV/pH
@riverpod
class PhSensorCalculator extends _$PhSensorCalculator {
  @override
  PhSensorInput build() {
    return const PhSensorInput(
      measuredMv: 0,
      temperatureC: 25.0, // Standard lab temperature
      e0: 0, // Isopotential at pH 7
    );
  }

  void updateMeasuredMv(double value) =>
      state = state.copyWith(measuredMv: value);
  void updateTemperatureC(double value) =>
      state = state.copyWith(temperatureC: value);
  void updateE0(double value) => state = state.copyWith(e0: value);

  void reset() {
    state = const PhSensorInput(
      measuredMv: 0,
      temperatureC: 25.0,
      e0: 0,
    );
  }
}

/// Computed pH sensor result.
@riverpod
PhSensorResult? phSensorResult(Ref ref) {
  final input = ref.watch(phSensorCalculatorProvider);

  // Theoretical slope = -0.1984 * T(K) mV/pH = -59.16 mV/pH at 25°C
  final theoreticalSlope = -ElectrochemConstants.nernstCoefficient *
      input.temperatureK *
      1000; // Convert to mV

  if (theoreticalSlope == 0) return null;

  // pH = 7 - (E - E0) / slope
  final calculatedPh = 7 - (input.measuredMv - input.e0) / theoreticalSlope;

  // Calculate actual slope efficiency (comparing to theoretical)
  final actualSlope = (input.measuredMv - input.e0) / (7 - calculatedPh);
  final slopeEfficiency =
      (actualSlope / theoreticalSlope * 100).abs().clamp(0.0, 150.0);

  final formula =
      'pH = 7 - (${input.measuredMv} - ${input.e0}) / ${theoreticalSlope.toStringAsFixed(2)}';

  return PhSensorResult(
    calculatedPh: calculatedPh,
    theoreticalSlope: theoreticalSlope,
    actualSlope: actualSlope,
    slopeEfficiency: slopeEfficiency,
    formula: formula,
  );
}

/// Input for Arrhenius rate ratio calculation.
class ArrheniusInput {
  const ArrheniusInput({
    required this.temperature1C,
    required this.temperature2C,
    required this.activationEnergy,
  });

  /// Initial temperature in Celsius
  final double temperature1C;

  /// Final temperature in Celsius
  final double temperature2C;

  /// Activation energy in kJ/mol
  final double activationEnergy;

  /// Temperatures in Kelvin
  double get temperature1K => temperature1C + 273.15;
  double get temperature2K => temperature2C + 273.15;

  /// Activation energy in J/mol
  double get activationEnergyJ => activationEnergy * 1000;

  ArrheniusInput copyWith({
    double? temperature1C,
    double? temperature2C,
    double? activationEnergy,
  }) {
    return ArrheniusInput(
      temperature1C: temperature1C ?? this.temperature1C,
      temperature2C: temperature2C ?? this.temperature2C,
      activationEnergy: activationEnergy ?? this.activationEnergy,
    );
  }
}

/// Result of Arrhenius rate ratio calculation.
class ArrheniusResult {
  const ArrheniusResult({
    required this.rateRatio,
    required this.isFaster,
    required this.formula,
  });

  /// Ratio of k2/k1
  final double rateRatio;

  /// Whether reaction is faster at T2
  final bool isFaster;

  /// Formula representation
  final String formula;
}

/// Arrhenius Rate Ratio Calculator.
///
/// k2/k1 = exp[(Ea/R) * (1/T1 - 1/T2)]
/// Where:
/// - Ea: Activation energy (J/mol)
/// - R: Gas constant (8.314 J/(mol·K))
/// - T1, T2: Temperatures (K)
@riverpod
class ArrheniusCalculator extends _$ArrheniusCalculator {
  @override
  ArrheniusInput build() {
    return const ArrheniusInput(
      temperature1C: 25.0,
      temperature2C: 35.0,
      activationEnergy: 50.0, // Typical enzyme reaction
    );
  }

  void updateTemperature1C(double value) =>
      state = state.copyWith(temperature1C: value);
  void updateTemperature2C(double value) =>
      state = state.copyWith(temperature2C: value);
  void updateActivationEnergy(double value) =>
      state = state.copyWith(activationEnergy: value);

  void reset() {
    state = const ArrheniusInput(
      temperature1C: 25.0,
      temperature2C: 35.0,
      activationEnergy: 50.0,
    );
  }
}

/// Computed Arrhenius rate ratio result.
@riverpod
ArrheniusResult? arrheniusResult(Ref ref) {
  final input = ref.watch(arrheniusCalculatorProvider);

  // Validate temperatures
  if (input.temperature1K <= 0 ||
      input.temperature2K <= 0 ||
      input.activationEnergy <= 0) {
    return null;
  }

  // k2/k1 = exp[(Ea/R) * (1/T1 - 1/T2)]
  final exponent = (input.activationEnergyJ / ElectrochemConstants.gasConstant) *
      (1 / input.temperature1K - 1 / input.temperature2K);
  final rateRatio = math.exp(exponent);

  final isFaster = rateRatio > 1;

  final formula =
      'k₂/k₁ = exp[(${input.activationEnergy} × 1000 / 8.314) × (1/${input.temperature1K.toStringAsFixed(1)} - 1/${input.temperature2K.toStringAsFixed(1)})]';

  return ArrheniusResult(
    rateRatio: rateRatio,
    isFaster: isFaster,
    formula: formula,
  );
}

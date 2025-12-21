import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tip_speed_provider.g.dart';

/// Status of tip speed assessment for cell culture safety.
enum TipSpeedStatus {
  /// Safe for mammalian cells (< 5.0 m/s)
  safe('Safe', 'Suitable for mammalian cell culture'),

  /// Caution zone for bacterial/yeast fermentation (5.0 - 8.0 m/s)
  caution('Caution', 'Suitable for bacterial/yeast fermentation'),

  /// High shear - potential cell damage (> 8.0 m/s)
  highShear('High Shear', 'Risk of cell damage!');

  const TipSpeedStatus(this.label, this.message);

  final String label;
  final String message;
}

/// Diameter unit for impeller.
enum DiameterUnit {
  meters('m', 1.0),
  centimeters('cm', 0.01);

  const DiameterUnit(this.symbol, this.toMeters);

  final String symbol;
  final double toMeters;
}

/// Input parameters for tip speed calculation.
class TipSpeedInput {
  const TipSpeedInput({
    required this.diameter,
    required this.diameterUnit,
    required this.rpm,
  });

  /// Impeller diameter in selected unit
  final double diameter;

  /// Unit for diameter
  final DiameterUnit diameterUnit;

  /// Agitation speed in RPM
  final double rpm;

  /// Get diameter in meters
  double get diameterInMeters => diameter * diameterUnit.toMeters;

  TipSpeedInput copyWith({
    double? diameter,
    DiameterUnit? diameterUnit,
    double? rpm,
  }) {
    return TipSpeedInput(
      diameter: diameter ?? this.diameter,
      diameterUnit: diameterUnit ?? this.diameterUnit,
      rpm: rpm ?? this.rpm,
    );
  }
}

/// Result of tip speed calculation with safety assessment.
class TipSpeedResult {
  const TipSpeedResult({
    required this.tipSpeed,
    required this.status,
    required this.formula,
  });

  /// Calculated tip speed in m/s
  final double tipSpeed;

  /// Safety status assessment
  final TipSpeedStatus status;

  /// Formula representation
  final String formula;
}

/// Impeller Tip Speed Calculator.
///
/// Formula: V_tip (m/s) = π × D × (N / 60)
/// Where:
/// - D: Impeller Diameter (meters)
/// - N: Agitation Speed (RPM)
@riverpod
class TipSpeedCalculator extends _$TipSpeedCalculator {
  @override
  TipSpeedInput build() {
    return const TipSpeedInput(
      diameter: 0,
      diameterUnit: DiameterUnit.centimeters,
      rpm: 0,
    );
  }

  void updateDiameter(double value) {
    state = state.copyWith(diameter: value);
  }

  void updateDiameterUnit(DiameterUnit unit) {
    state = state.copyWith(diameterUnit: unit);
  }

  void updateRpm(double value) {
    state = state.copyWith(rpm: value);
  }

  void reset() {
    state = const TipSpeedInput(
      diameter: 0,
      diameterUnit: DiameterUnit.centimeters,
      rpm: 0,
    );
  }
}

/// Computed tip speed result based on current input.
@riverpod
TipSpeedResult? tipSpeedResult(Ref ref) {
  final input = ref.watch(tipSpeedCalculatorProvider);

  // Validate inputs - must be positive
  if (input.diameter <= 0 || input.rpm <= 0) {
    return null;
  }

  // Convert diameter to meters
  final diameterM = input.diameterInMeters;

  // V_tip = π × D × (N / 60)
  final tipSpeed = math.pi * diameterM * (input.rpm / 60);

  // Determine status based on tip speed
  final TipSpeedStatus status;
  if (tipSpeed < 5.0) {
    status = TipSpeedStatus.safe;
  } else if (tipSpeed <= 8.0) {
    status = TipSpeedStatus.caution;
  } else {
    status = TipSpeedStatus.highShear;
  }

  final formula =
      'V = π × ${diameterM.toStringAsFixed(3)} m × (${input.rpm.toStringAsFixed(0)} / 60)';

  return TipSpeedResult(
    tipSpeed: tipSpeed,
    status: status,
    formula: formula,
  );
}

import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hydraulic_force_logic.g.dart';

/// Input parameters for hydraulic cylinder force calculation.
class HydraulicForceInput {
  const HydraulicForceInput({
    required this.boreDiameter,
    required this.rodDiameter,
    required this.pressure,
  });

  /// Bore diameter in mm
  final double boreDiameter;

  /// Rod diameter in mm
  final double rodDiameter;

  /// System pressure in bar
  final double pressure;

  HydraulicForceInput copyWith({
    double? boreDiameter,
    double? rodDiameter,
    double? pressure,
  }) {
    return HydraulicForceInput(
      boreDiameter: boreDiameter ?? this.boreDiameter,
      rodDiameter: rodDiameter ?? this.rodDiameter,
      pressure: pressure ?? this.pressure,
    );
  }
}

/// Result of hydraulic force calculation.
class HydraulicForceResult {
  const HydraulicForceResult({
    required this.pushForce,
    required this.pullForce,
    required this.boreArea,
    required this.annularArea,
    required this.pushFormula,
    required this.pullFormula,
  });

  /// Push force (extend) in kN
  final double pushForce;

  /// Pull force (retract) in kN
  final double pullForce;

  /// Bore area in mm²
  final double boreArea;

  /// Annular area (bore - rod) in mm²
  final double annularArea;

  /// Formula representation
  final String pushFormula;
  final String pullFormula;
}

/// Hydraulic Cylinder Force Calculator.
///
/// Push Force = P × A_bore (using full bore area)
/// Pull Force = P × A_annular (bore area minus rod area)
///
/// Where:
/// - P: Pressure (bar)
/// - A: Area (mm²)
/// - Force in kN = (P × A) / 10000
@riverpod
class HydraulicForceCalculator extends _$HydraulicForceCalculator {
  @override
  HydraulicForceInput build() {
    return const HydraulicForceInput(
      boreDiameter: 0,
      rodDiameter: 0,
      pressure: 0,
    );
  }

  void updateBoreDiameter(double value) {
    state = state.copyWith(boreDiameter: value);
  }

  void updateRodDiameter(double value) {
    state = state.copyWith(rodDiameter: value);
  }

  void updatePressure(double value) {
    state = state.copyWith(pressure: value);
  }

  void reset() {
    state = const HydraulicForceInput(
      boreDiameter: 0,
      rodDiameter: 0,
      pressure: 0,
    );
  }
}

/// Computed hydraulic force result based on current input.
@riverpod
HydraulicForceResult? hydraulicForceResult(Ref ref) {
  final input = ref.watch(hydraulicForceCalculatorProvider);

  // Validate inputs
  if (input.boreDiameter <= 0 || input.pressure <= 0) {
    return null;
  }

  // Validate rod < bore
  if (input.rodDiameter >= input.boreDiameter) {
    return null;
  }

  final boreRadius = input.boreDiameter / 2;
  final rodRadius = input.rodDiameter / 2;

  // Areas in mm²
  final boreArea = math.pi * boreRadius * boreRadius;
  final rodArea = math.pi * rodRadius * rodRadius;
  final annularArea = boreArea - rodArea;

  // Force in kN = (Pressure in bar × Area in mm²) / 10000
  // 1 bar = 0.1 N/mm², so F(N) = P × A × 0.1, F(kN) = P × A / 10000
  final pushForce = (input.pressure * boreArea) / 10000;
  final pullForce = (input.pressure * annularArea) / 10000;

  final pushFormula =
      'F_push = ${input.pressure} bar × ${boreArea.toStringAsFixed(1)} mm² / 10000';
  final pullFormula =
      'F_pull = ${input.pressure} bar × ${annularArea.toStringAsFixed(1)} mm² / 10000';

  return HydraulicForceResult(
    pushForce: pushForce,
    pullForce: pullForce,
    boreArea: boreArea,
    annularArea: annularArea,
    pushFormula: pushFormula,
    pullFormula: pullFormula,
  );
}

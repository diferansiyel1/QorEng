import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'beer_lambert_logic.g.dart';

/// Variable to solve for in Beer-Lambert equation.
enum BeerLambertSolveFor {
  absorbance('Absorbance (A)'),
  concentration('Concentration (c)'),
  molarAbsorptivity('Molar Absorptivity (ε)'),
  pathLength('Path Length (l)');

  const BeerLambertSolveFor(this.label);

  final String label;
}

/// Input parameters for Beer-Lambert calculation.
class BeerLambertInput {
  const BeerLambertInput({
    required this.solveFor,
    required this.absorbance,
    required this.molarAbsorptivity,
    required this.pathLength,
    required this.concentration,
  });

  final BeerLambertSolveFor solveFor;

  /// Absorbance (dimensionless)
  final double absorbance;

  /// Molar absorptivity (L/(mol·cm))
  final double molarAbsorptivity;

  /// Path length (cm)
  final double pathLength;

  /// Concentration (mol/L)
  final double concentration;

  BeerLambertInput copyWith({
    BeerLambertSolveFor? solveFor,
    double? absorbance,
    double? molarAbsorptivity,
    double? pathLength,
    double? concentration,
  }) {
    return BeerLambertInput(
      solveFor: solveFor ?? this.solveFor,
      absorbance: absorbance ?? this.absorbance,
      molarAbsorptivity: molarAbsorptivity ?? this.molarAbsorptivity,
      pathLength: pathLength ?? this.pathLength,
      concentration: concentration ?? this.concentration,
    );
  }
}

/// Result of Beer-Lambert calculation.
class BeerLambertResult {
  const BeerLambertResult({
    required this.result,
    required this.resultLabel,
    required this.unit,
    required this.formula,
  });

  final double result;
  final String resultLabel;
  final String unit;
  final String formula;
}

/// Beer-Lambert Law Calculator.
///
/// A = ε × l × c
/// Where:
/// - A = Absorbance (dimensionless)
/// - ε = Molar absorptivity (L/(mol·cm))
/// - l = Path length (cm)
/// - c = Concentration (mol/L)
@riverpod
class BeerLambertCalculator extends _$BeerLambertCalculator {
  @override
  BeerLambertInput build() {
    return const BeerLambertInput(
      solveFor: BeerLambertSolveFor.concentration,
      absorbance: 0,
      molarAbsorptivity: 0,
      pathLength: 1.0, // Default 1 cm cuvette
      concentration: 0,
    );
  }

  void updateSolveFor(BeerLambertSolveFor value) =>
      state = state.copyWith(solveFor: value);
  void updateAbsorbance(double value) =>
      state = state.copyWith(absorbance: value);
  void updateMolarAbsorptivity(double value) =>
      state = state.copyWith(molarAbsorptivity: value);
  void updatePathLength(double value) =>
      state = state.copyWith(pathLength: value);
  void updateConcentration(double value) =>
      state = state.copyWith(concentration: value);

  void reset() {
    state = const BeerLambertInput(
      solveFor: BeerLambertSolveFor.concentration,
      absorbance: 0,
      molarAbsorptivity: 0,
      pathLength: 1.0,
      concentration: 0,
    );
  }
}

/// Computed Beer-Lambert result.
@riverpod
BeerLambertResult? beerLambertResult(Ref ref) {
  final input = ref.watch(beerLambertCalculatorProvider);

  switch (input.solveFor) {
    case BeerLambertSolveFor.absorbance:
      // A = ε × l × c
      if (input.molarAbsorptivity <= 0 ||
          input.pathLength <= 0 ||
          input.concentration <= 0) {
        return null;
      }
      final a = input.molarAbsorptivity * input.pathLength * input.concentration;
      return BeerLambertResult(
        result: a,
        resultLabel: 'Absorbance',
        unit: 'AU',
        formula: 'A = ${input.molarAbsorptivity} × ${input.pathLength} × ${input.concentration}',
      );

    case BeerLambertSolveFor.concentration:
      // c = A / (ε × l)
      if (input.absorbance <= 0 ||
          input.molarAbsorptivity <= 0 ||
          input.pathLength <= 0) {
        return null;
      }
      final c = input.absorbance / (input.molarAbsorptivity * input.pathLength);
      return BeerLambertResult(
        result: c,
        resultLabel: 'Concentration',
        unit: 'mol/L',
        formula: 'c = ${input.absorbance} / (${input.molarAbsorptivity} × ${input.pathLength})',
      );

    case BeerLambertSolveFor.molarAbsorptivity:
      // ε = A / (l × c)
      if (input.absorbance <= 0 ||
          input.pathLength <= 0 ||
          input.concentration <= 0) {
        return null;
      }
      final epsilon = input.absorbance / (input.pathLength * input.concentration);
      return BeerLambertResult(
        result: epsilon,
        resultLabel: 'Molar Absorptivity',
        unit: 'L/(mol·cm)',
        formula: 'ε = ${input.absorbance} / (${input.pathLength} × ${input.concentration})',
      );

    case BeerLambertSolveFor.pathLength:
      // l = A / (ε × c)
      if (input.absorbance <= 0 ||
          input.molarAbsorptivity <= 0 ||
          input.concentration <= 0) {
        return null;
      }
      final l = input.absorbance / (input.molarAbsorptivity * input.concentration);
      return BeerLambertResult(
        result: l,
        resultLabel: 'Path Length',
        unit: 'cm',
        formula: 'l = ${input.absorbance} / (${input.molarAbsorptivity} × ${input.concentration})',
      );
  }
}

/// Transmittance <-> Absorbance Converter.
@riverpod
class TransmittanceConverter extends _$TransmittanceConverter {
  @override
  ({double transmittance, double absorbance}) build() {
    return (transmittance: 100, absorbance: 0);
  }

  /// Update from transmittance (%T)
  void updateFromTransmittance(double t) {
    if (t <= 0) {
      state = (transmittance: t, absorbance: double.infinity);
      return;
    }
    if (t > 100) t = 100;
    // A = 2 - log10(%T)
    final a = 2 - math.log(t) / math.ln10;
    state = (transmittance: t, absorbance: a.clamp(0, 10));
  }

  /// Update from absorbance
  void updateFromAbsorbance(double a) {
    if (a < 0) a = 0;
    // %T = 10^(2 - A)
    final t = math.pow(10, 2 - a).clamp(0, 100);
    state = (transmittance: t.toDouble(), absorbance: a);
  }

  void reset() {
    state = (transmittance: 100, absorbance: 0);
  }
}

/// OD Cell Density input.
class OdCellDensityInput {
  const OdCellDensityInput({
    required this.measuredOd,
    required this.dilutionFactor,
    required this.cellsPerOdUnit,
  });

  /// Measured OD600 value
  final double measuredOd;

  /// Dilution factor (e.g., 10 for 1:10 dilution)
  final double dilutionFactor;

  /// Cells per mL per OD unit (default 8e8 for E. coli)
  final double cellsPerOdUnit;

  OdCellDensityInput copyWith({
    double? measuredOd,
    double? dilutionFactor,
    double? cellsPerOdUnit,
  }) {
    return OdCellDensityInput(
      measuredOd: measuredOd ?? this.measuredOd,
      dilutionFactor: dilutionFactor ?? this.dilutionFactor,
      cellsPerOdUnit: cellsPerOdUnit ?? this.cellsPerOdUnit,
    );
  }
}

/// OD Cell Density result.
class OdCellDensityResult {
  const OdCellDensityResult({
    required this.realOd,
    required this.totalCells,
    required this.isNonLinear,
  });

  final double realOd;
  final double totalCells;
  final bool isNonLinear;
}

/// OD / Cell Density Calculator.
@riverpod
class OdCellDensityCalculator extends _$OdCellDensityCalculator {
  @override
  OdCellDensityInput build() {
    return const OdCellDensityInput(
      measuredOd: 0,
      dilutionFactor: 1,
      cellsPerOdUnit: 8e8, // E. coli default
    );
  }

  void updateMeasuredOd(double value) =>
      state = state.copyWith(measuredOd: value);
  void updateDilutionFactor(double value) =>
      state = state.copyWith(dilutionFactor: value);
  void updateCellsPerOdUnit(double value) =>
      state = state.copyWith(cellsPerOdUnit: value);

  void reset() {
    state = const OdCellDensityInput(
      measuredOd: 0,
      dilutionFactor: 1,
      cellsPerOdUnit: 8e8,
    );
  }
}

/// Computed OD / Cell Density result.
@riverpod
OdCellDensityResult? odCellDensityResult(Ref ref) {
  final input = ref.watch(odCellDensityCalculatorProvider);

  if (input.measuredOd <= 0 ||
      input.dilutionFactor <= 0 ||
      input.cellsPerOdUnit <= 0) {
    return null;
  }

  final realOd = input.measuredOd * input.dilutionFactor;
  final totalCells = realOd * input.cellsPerOdUnit;
  final isNonLinear = input.measuredOd > 1.0;

  return OdCellDensityResult(
    realOd: realOd,
    totalCells: totalCells,
    isNonLinear: isNonLinear,
  );
}

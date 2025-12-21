import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'molarity_logic.g.dart';

/// Input parameters for molarity conversion.
class MolarityInput {
  const MolarityInput({
    required this.concentrationGL,
    required this.molecularWeight,
  });

  /// Concentration in g/L
  final double concentrationGL;

  /// Molecular weight in g/mol
  final double molecularWeight;

  MolarityInput copyWith({
    double? concentrationGL,
    double? molecularWeight,
  }) {
    return MolarityInput(
      concentrationGL: concentrationGL ?? this.concentrationGL,
      molecularWeight: molecularWeight ?? this.molecularWeight,
    );
  }
}

/// Result of molarity conversion.
class MolarityResult {
  const MolarityResult({
    required this.molarity,
    required this.molarityMM,
    required this.formula,
  });

  /// Molarity in M (mol/L)
  final double molarity;

  /// Molarity in mM (millimolar)
  final double molarityMM;

  /// Formula representation
  final String formula;
}

/// Molarity Converter.
///
/// Formula: M (mol/L) = (g/L) / MW (g/mol)
@riverpod
class MolarityCalculator extends _$MolarityCalculator {
  @override
  MolarityInput build() {
    return const MolarityInput(
      concentrationGL: 0,
      molecularWeight: 0,
    );
  }

  void updateConcentration(double value) {
    state = state.copyWith(concentrationGL: value);
  }

  void updateMolecularWeight(double value) {
    state = state.copyWith(molecularWeight: value);
  }

  void reset() {
    state = const MolarityInput(
      concentrationGL: 0,
      molecularWeight: 0,
    );
  }
}

/// Computed molarity result.
@riverpod
MolarityResult? molarityResult(Ref ref) {
  final input = ref.watch(molarityCalculatorProvider);

  // Validate inputs
  if (input.concentrationGL <= 0 || input.molecularWeight <= 0) {
    return null;
  }

  // M = (g/L) / MW
  final molarity = input.concentrationGL / input.molecularWeight;
  final molarityMM = molarity * 1000;

  final formula = 'M = ${input.concentrationGL} g/L ÷ ${input.molecularWeight} g/mol';

  return MolarityResult(
    molarity: molarity,
    molarityMM: molarityMM,
    formula: formula,
  );
}

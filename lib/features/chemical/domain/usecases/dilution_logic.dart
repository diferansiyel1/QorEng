import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dilution_logic.g.dart';

/// Input parameters for dilution calculation (C1V1 = C2V2).
class DilutionInput {
  const DilutionInput({
    required this.stockConcentration,
    required this.targetConcentration,
    required this.targetVolume,
  });

  /// Stock solution concentration (any unit - %, M, g/L)
  final double stockConcentration;

  /// Target concentration (same unit as stock)
  final double targetConcentration;

  /// Target final volume (mL)
  final double targetVolume;

  DilutionInput copyWith({
    double? stockConcentration,
    double? targetConcentration,
    double? targetVolume,
  }) {
    return DilutionInput(
      stockConcentration: stockConcentration ?? this.stockConcentration,
      targetConcentration: targetConcentration ?? this.targetConcentration,
      targetVolume: targetVolume ?? this.targetVolume,
    );
  }
}

/// Result of dilution calculation.
class DilutionResult {
  const DilutionResult({
    required this.stockVolume,
    required this.waterVolume,
    required this.formula,
    this.error,
  });

  /// Volume of stock solution needed (mL)
  final double stockVolume;

  /// Volume of water/diluent needed (mL)
  final double waterVolume;

  /// Formula representation
  final String formula;

  /// Error message if any
  final String? error;

  bool get hasError => error != null;
}

/// Dilution Calculator.
///
/// Formula: C1 × V1 = C2 × V2
/// V1 (stock) = (C2 × V2) / C1
/// V_water = V2 - V1
@riverpod
class DilutionCalculator extends _$DilutionCalculator {
  @override
  DilutionInput build() {
    return const DilutionInput(
      stockConcentration: 0,
      targetConcentration: 0,
      targetVolume: 0,
    );
  }

  void updateStockConcentration(double value) {
    state = state.copyWith(stockConcentration: value);
  }

  void updateTargetConcentration(double value) {
    state = state.copyWith(targetConcentration: value);
  }

  void updateTargetVolume(double value) {
    state = state.copyWith(targetVolume: value);
  }

  void reset() {
    state = const DilutionInput(
      stockConcentration: 0,
      targetConcentration: 0,
      targetVolume: 0,
    );
  }
}

/// Computed dilution result.
@riverpod
DilutionResult? dilutionResult(Ref ref) {
  final input = ref.watch(dilutionCalculatorProvider);

  // Validate basic inputs
  if (input.stockConcentration <= 0 ||
      input.targetConcentration <= 0 ||
      input.targetVolume <= 0) {
    return null;
  }

  // Check if target > stock (impossible dilution)
  if (input.targetConcentration > input.stockConcentration) {
    return const DilutionResult(
      stockVolume: 0,
      waterVolume: 0,
      formula: '',
      error: 'Target concentration cannot exceed stock concentration!',
    );
  }

  // C1 × V1 = C2 × V2
  // V1 = (C2 × V2) / C1
  final stockVolume =
      (input.targetConcentration * input.targetVolume) / input.stockConcentration;
  final waterVolume = input.targetVolume - stockVolume;

  final formula =
      'V₁ = (${input.targetConcentration} × ${input.targetVolume}) / ${input.stockConcentration}';

  return DilutionResult(
    stockVolume: stockVolume,
    waterVolume: waterVolume,
    formula: formula,
  );
}

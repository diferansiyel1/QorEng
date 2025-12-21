import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voltage_drop_logic.g.dart';

/// Phase system type for voltage drop calculation.
enum PhaseSystem {
  singlePhase('Single Phase (1Φ)', 2.0),
  threePhase('Three Phase (3Φ)', 1.732);

  const PhaseSystem(this.label, this.kFactor);

  final String label;
  final double kFactor;
}

/// Conductor material with resistivity values.
enum ConductorMaterial {
  copper('Copper (Cu)', 0.0175),
  aluminum('Aluminum (Al)', 0.028);

  const ConductorMaterial(this.label, this.resistivity);

  final String label;

  /// Resistivity in Ω·mm²/m at 20°C
  final double resistivity;
}

/// Warning level for voltage drop percentage.
enum VoltageDropWarning {
  none,
  lighting,
  power,
}

/// Input parameters for voltage drop calculation.
class VoltageDropInput {
  const VoltageDropInput({
    required this.current,
    required this.length,
    required this.crossSection,
    required this.systemVoltage,
    required this.phaseSystem,
    required this.material,
  });

  /// Current in Amperes
  final double current;

  /// Cable length in meters
  final double length;

  /// Cable cross-section area in mm²
  final double crossSection;

  /// System voltage in Volts
  final double systemVoltage;

  /// Phase system (single or three phase)
  final PhaseSystem phaseSystem;

  /// Conductor material (copper or aluminum)
  final ConductorMaterial material;

  VoltageDropInput copyWith({
    double? current,
    double? length,
    double? crossSection,
    double? systemVoltage,
    PhaseSystem? phaseSystem,
    ConductorMaterial? material,
  }) {
    return VoltageDropInput(
      current: current ?? this.current,
      length: length ?? this.length,
      crossSection: crossSection ?? this.crossSection,
      systemVoltage: systemVoltage ?? this.systemVoltage,
      phaseSystem: phaseSystem ?? this.phaseSystem,
      material: material ?? this.material,
    );
  }
}

/// Result of voltage drop calculation.
class VoltageDropResult {
  const VoltageDropResult({
    required this.voltageDrop,
    required this.voltageDropPercentage,
    required this.warning,
    required this.formula,
  });

  /// Voltage drop in Volts
  final double voltageDrop;

  /// Voltage drop as percentage of system voltage
  final double voltageDropPercentage;

  /// Warning level based on percentage
  final VoltageDropWarning warning;

  /// Formula representation
  final String formula;
}

/// Calculate voltage drop using the formula:
/// V_drop = (k × I × L × ρ) / S
///
/// Where:
/// - k: 2 for Single Phase, √3 for Three Phase
/// - I: Current (Amperes)
/// - L: Length (meters)
/// - ρ: Resistivity (Ω·mm²/m)
/// - S: Cross-section area (mm²)
@riverpod
class VoltageDropCalculator extends _$VoltageDropCalculator {
  @override
  VoltageDropInput build() {
    return const VoltageDropInput(
      current: 0,
      length: 0,
      crossSection: 2.5,
      systemVoltage: 230,
      phaseSystem: PhaseSystem.singlePhase,
      material: ConductorMaterial.copper,
    );
  }

  void updateCurrent(double value) {
    state = state.copyWith(current: value);
  }

  void updateLength(double value) {
    state = state.copyWith(length: value);
  }

  void updateCrossSection(double value) {
    state = state.copyWith(crossSection: value);
  }

  void updateSystemVoltage(double value) {
    state = state.copyWith(systemVoltage: value);
  }

  void updatePhaseSystem(PhaseSystem value) {
    state = state.copyWith(phaseSystem: value);
  }

  void updateMaterial(ConductorMaterial value) {
    state = state.copyWith(material: value);
  }

  void reset() {
    state = const VoltageDropInput(
      current: 0,
      length: 0,
      crossSection: 2.5,
      systemVoltage: 230,
      phaseSystem: PhaseSystem.singlePhase,
      material: ConductorMaterial.copper,
    );
  }
}

/// Computed voltage drop result based on current input.
@riverpod
VoltageDropResult? voltageDropResult(Ref ref) {
  final input = ref.watch(voltageDropCalculatorProvider);

  // Validate inputs
  if (input.current <= 0 ||
      input.length <= 0 ||
      input.crossSection <= 0 ||
      input.systemVoltage <= 0) {
    return null;
  }

  final k = input.phaseSystem.kFactor;
  final rho = input.material.resistivity;
  final i = input.current;
  final l = input.length;
  final s = input.crossSection;
  final systemVoltage = input.systemVoltage;

  // V_drop = (k × I × L × ρ) / S
  final voltageDrop = (k * i * l * rho) / s;
  final percentage = (voltageDrop / systemVoltage) * 100;

  // Determine warning level
  VoltageDropWarning warning;
  if (percentage > 5) {
    warning = VoltageDropWarning.power;
  } else if (percentage > 3) {
    warning = VoltageDropWarning.lighting;
  } else {
    warning = VoltageDropWarning.none;
  }

  final kStr = k == 2.0 ? '2' : '√3';
  final formula =
      'V = ($kStr × $i × $l × $rho) / $s = ${voltageDrop.toStringAsFixed(2)} V';

  return VoltageDropResult(
    voltageDrop: voltageDrop,
    voltageDropPercentage: percentage,
    warning: warning,
    formula: formula,
  );
}

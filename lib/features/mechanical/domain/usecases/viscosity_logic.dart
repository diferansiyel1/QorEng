import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'viscosity_logic.g.dart';

// ============================================================================
// UNIT DEFINITIONS AND CONVERSIONS
// ============================================================================

/// Dynamic viscosity units.
enum DynamicViscosityUnit {
  cP('cP (Centipoise)', 1.0), // Base unit
  pas('Pa·s', 1000.0), // 1 Pa·s = 1000 cP
  mPas('mPa·s', 1.0), // 1 mPa·s = 1 cP
  poise('P (Poise)', 100.0); // 1 P = 100 cP

  const DynamicViscosityUnit(this.label, this.toCpFactor);

  final String label;

  /// Multiply by this to convert TO cP
  final double toCpFactor;

  double toCp(double value) => value * toCpFactor;
  double fromCp(double cp) => cp / toCpFactor;
}

/// Kinematic viscosity units.
enum KinematicViscosityUnit {
  cSt('cSt (Centistokes)', 1.0), // Base unit
  m2s('m²/s', 1e6), // 1 m²/s = 1e6 cSt
  stokes('St (Stokes)', 100.0); // 1 St = 100 cSt

  const KinematicViscosityUnit(this.label, this.toCstFactor);

  final String label;

  /// Multiply by this to convert TO cSt
  final double toCstFactor;

  double toCst(double value) => value * toCstFactor;
  double fromCst(double cst) => cst / toCstFactor;
}

/// Density units.
enum DensityUnit {
  gcm3('g/cm³', 1.0), // Base unit
  kgm3('kg/m³', 0.001); // 1 kg/m³ = 0.001 g/cm³

  const DensityUnit(this.label, this.toGcm3Factor);

  final String label;
  final double toGcm3Factor;

  double toGcm3(double value) => value * toGcm3Factor;
  double fromGcm3(double gcm3) => gcm3 / toGcm3Factor;
}

// ============================================================================
// VISCOSITY CONVERTER (Dynamic <-> Kinematic)
// ============================================================================

/// Input for viscosity converter.
class ViscosityConverterInput {
  const ViscosityConverterInput({
    required this.dynamicValue,
    required this.dynamicUnit,
    required this.kinematicValue,
    required this.kinematicUnit,
    required this.density,
    required this.densityUnit,
    required this.isDynamicMode,
  });

  /// Dynamic viscosity value
  final double dynamicValue;
  final DynamicViscosityUnit dynamicUnit;

  /// Kinematic viscosity value
  final double kinematicValue;
  final KinematicViscosityUnit kinematicUnit;

  /// Density value
  final double density;
  final DensityUnit densityUnit;

  /// True = input dynamic, calculate kinematic
  /// False = input kinematic, calculate dynamic
  final bool isDynamicMode;

  ViscosityConverterInput copyWith({
    double? dynamicValue,
    DynamicViscosityUnit? dynamicUnit,
    double? kinematicValue,
    KinematicViscosityUnit? kinematicUnit,
    double? density,
    DensityUnit? densityUnit,
    bool? isDynamicMode,
  }) {
    return ViscosityConverterInput(
      dynamicValue: dynamicValue ?? this.dynamicValue,
      dynamicUnit: dynamicUnit ?? this.dynamicUnit,
      kinematicValue: kinematicValue ?? this.kinematicValue,
      kinematicUnit: kinematicUnit ?? this.kinematicUnit,
      density: density ?? this.density,
      densityUnit: densityUnit ?? this.densityUnit,
      isDynamicMode: isDynamicMode ?? this.isDynamicMode,
    );
  }
}

/// Result of viscosity conversion.
class ViscosityConverterResult {
  const ViscosityConverterResult({
    required this.dynamicCp,
    required this.kinematicCst,
    required this.formula,
  });

  /// Dynamic viscosity in cP
  final double dynamicCp;

  /// Kinematic viscosity in cSt
  final double kinematicCst;

  /// Formula display
  final String formula;
}

/// Viscosity Converter Calculator.
@riverpod
class ViscosityConverter extends _$ViscosityConverter {
  @override
  ViscosityConverterInput build() {
    return const ViscosityConverterInput(
      dynamicValue: 0,
      dynamicUnit: DynamicViscosityUnit.cP,
      kinematicValue: 0,
      kinematicUnit: KinematicViscosityUnit.cSt,
      density: 1.0, // Water
      densityUnit: DensityUnit.gcm3,
      isDynamicMode: true,
    );
  }

  void updateDynamicValue(double v) =>
      state = state.copyWith(dynamicValue: v, isDynamicMode: true);
  void updateDynamicUnit(DynamicViscosityUnit u) =>
      state = state.copyWith(dynamicUnit: u);
  void updateKinematicValue(double v) =>
      state = state.copyWith(kinematicValue: v, isDynamicMode: false);
  void updateKinematicUnit(KinematicViscosityUnit u) =>
      state = state.copyWith(kinematicUnit: u);
  void updateDensity(double v) => state = state.copyWith(density: v);
  void updateDensityUnit(DensityUnit u) => state = state.copyWith(densityUnit: u);

  void reset() {
    state = const ViscosityConverterInput(
      dynamicValue: 0,
      dynamicUnit: DynamicViscosityUnit.cP,
      kinematicValue: 0,
      kinematicUnit: KinematicViscosityUnit.cSt,
      density: 1.0,
      densityUnit: DensityUnit.gcm3,
      isDynamicMode: true,
    );
  }
}

/// Computed viscosity conversion.
@riverpod
ViscosityConverterResult? viscosityConverterResult(Ref ref) {
  final input = ref.watch(viscosityConverterProvider);

  // Get density in g/cm³
  final densityGcm3 = input.densityUnit.toGcm3(input.density);
  if (densityGcm3 <= 0) return null;

  double dynamicCp;
  double kinematicCst;
  String formula;

  if (input.isDynamicMode) {
    // Input dynamic -> calculate kinematic
    dynamicCp = input.dynamicUnit.toCp(input.dynamicValue);
    if (dynamicCp <= 0) return null;

    // ν (cSt) = μ (cP) / ρ (g/cm³)
    kinematicCst = dynamicCp / densityGcm3;
    formula = 'ν = $dynamicCp cP / $densityGcm3 g/cm³';
  } else {
    // Input kinematic -> calculate dynamic
    kinematicCst = input.kinematicUnit.toCst(input.kinematicValue);
    if (kinematicCst <= 0) return null;

    // μ (cP) = ν (cSt) × ρ (g/cm³)
    dynamicCp = kinematicCst * densityGcm3;
    formula = 'μ = $kinematicCst cSt × $densityGcm3 g/cm³';
  }

  return ViscosityConverterResult(
    dynamicCp: dynamicCp,
    kinematicCst: kinematicCst,
    formula: formula,
  );
}

// ============================================================================
// EFFLUX CUP CALCULATOR (Ford, Zahn, DIN)
// ============================================================================

/// Efflux cup types with their formulas.
enum EffluxCupType {
  ford2(
    'Ford Cup #2',
    'cSt = 1.44 × (t - 18)',
    25,
    120,
  ),
  ford3(
    'Ford Cup #3',
    'cSt = 2.31 × (t - 3.7)',
    25,
    105,
  ),
  ford4(
    'Ford Cup #4',
    'cSt = 3.85 × (t - 4.49)',
    20,
    105,
  ),
  zahn2(
    'Zahn Cup #2',
    'cSt = 3.5 × (t - 14)',
    20,
    80,
  ),
  din4(
    'DIN 4mm',
    'cSt = 4.57×t - 452/t',
    30,
    100,
  );

  const EffluxCupType(
    this.label,
    this.formula,
    this.minSeconds,
    this.maxSeconds,
  );

  final String label;
  final String formula;
  final int minSeconds;
  final int maxSeconds;

  /// Calculate cSt from flow time in seconds.
  double calculateCst(double t) {
    return switch (this) {
      EffluxCupType.ford2 => 1.44 * (t - 18),
      EffluxCupType.ford3 => 2.31 * (t - 3.7),
      EffluxCupType.ford4 => 3.85 * (t - 4.49),
      EffluxCupType.zahn2 => 3.5 * (t - 14),
      EffluxCupType.din4 => 4.57 * t - 452 / t,
    };
  }

  /// Check if time is within valid range.
  bool isValidRange(double t) => t >= minSeconds && t <= maxSeconds;
}

/// Input for efflux cup calculator.
class EffluxCupInput {
  const EffluxCupInput({
    required this.cupType,
    required this.flowTime,
    required this.density,
    required this.densityUnit,
  });

  final EffluxCupType cupType;

  /// Flow time in seconds
  final double flowTime;

  /// Density for dynamic viscosity calculation
  final double density;
  final DensityUnit densityUnit;

  EffluxCupInput copyWith({
    EffluxCupType? cupType,
    double? flowTime,
    double? density,
    DensityUnit? densityUnit,
  }) {
    return EffluxCupInput(
      cupType: cupType ?? this.cupType,
      flowTime: flowTime ?? this.flowTime,
      density: density ?? this.density,
      densityUnit: densityUnit ?? this.densityUnit,
    );
  }
}

/// Result of efflux cup calculation.
class EffluxCupResult {
  const EffluxCupResult({
    required this.kinematicCst,
    required this.dynamicCp,
    required this.isValidRange,
    required this.warningMessage,
    required this.formula,
  });

  /// Kinematic viscosity in cSt
  final double kinematicCst;

  /// Dynamic viscosity in cP
  final double dynamicCp;

  /// Whether time is within valid range
  final bool isValidRange;

  /// Warning message if out of range
  final String? warningMessage;

  /// Formula used
  final String formula;
}

/// Efflux Cup Calculator.
@riverpod
class EffluxCupCalculator extends _$EffluxCupCalculator {
  @override
  EffluxCupInput build() {
    return const EffluxCupInput(
      cupType: EffluxCupType.ford4,
      flowTime: 0,
      density: 1.0,
      densityUnit: DensityUnit.gcm3,
    );
  }

  void updateCupType(EffluxCupType t) => state = state.copyWith(cupType: t);
  void updateFlowTime(double v) => state = state.copyWith(flowTime: v);
  void updateDensity(double v) => state = state.copyWith(density: v);
  void updateDensityUnit(DensityUnit u) => state = state.copyWith(densityUnit: u);

  void reset() {
    state = const EffluxCupInput(
      cupType: EffluxCupType.ford4,
      flowTime: 0,
      density: 1.0,
      densityUnit: DensityUnit.gcm3,
    );
  }
}

/// Computed efflux cup result.
@riverpod
EffluxCupResult? effluxCupResult(Ref ref) {
  final input = ref.watch(effluxCupCalculatorProvider);

  if (input.flowTime <= 0) return null;

  final densityGcm3 = input.densityUnit.toGcm3(input.density);
  if (densityGcm3 <= 0) return null;

  final cst = input.cupType.calculateCst(input.flowTime);
  if (cst <= 0) return null;

  final cp = cst * densityGcm3;
  final isValid = input.cupType.isValidRange(input.flowTime);

  String? warning;
  if (!isValid) {
    warning =
        'Flow time ${input.flowTime}s is outside valid range (${input.cupType.minSeconds}-${input.cupType.maxSeconds}s). Results may be inaccurate.';
  }

  return EffluxCupResult(
    kinematicCst: cst,
    dynamicCp: cp,
    isValidRange: isValid,
    warningMessage: warning,
    formula: input.cupType.formula,
  );
}

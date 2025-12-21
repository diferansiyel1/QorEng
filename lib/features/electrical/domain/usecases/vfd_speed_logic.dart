import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vfd_speed_logic.g.dart';

/// Standard motor pole configurations.
enum MotorPoles {
  poles2(2, '2 Poles (3600 RPM @ 60Hz)'),
  poles4(4, '4 Poles (1800 RPM @ 60Hz)'),
  poles6(6, '6 Poles (1200 RPM @ 60Hz)'),
  poles8(8, '8 Poles (900 RPM @ 60Hz)');

  const MotorPoles(this.value, this.label);

  final int value;
  final String label;
}

/// Input parameters for VFD motor speed calculation.
class VfdSpeedInput {
  const VfdSpeedInput({
    required this.frequency,
    required this.poles,
    required this.slipPercent,
  });

  /// Drive frequency in Hz
  final double frequency;

  /// Number of motor poles
  final MotorPoles poles;

  /// Slip percentage (0-10 typical)
  final double slipPercent;

  VfdSpeedInput copyWith({
    double? frequency,
    MotorPoles? poles,
    double? slipPercent,
  }) {
    return VfdSpeedInput(
      frequency: frequency ?? this.frequency,
      poles: poles ?? this.poles,
      slipPercent: slipPercent ?? this.slipPercent,
    );
  }
}

/// Result of VFD speed calculation.
class VfdSpeedResult {
  const VfdSpeedResult({
    required this.synchronousSpeed,
    required this.actualSpeed,
    required this.slipSpeed,
    required this.formula,
  });

  /// Synchronous speed (theoretical) in RPM
  final double synchronousSpeed;

  /// Actual motor speed (accounting for slip) in RPM
  final double actualSpeed;

  /// Speed lost to slip in RPM
  final double slipSpeed;

  /// Formula representation
  final String formula;
}

/// VFD Motor Speed Calculator.
///
/// Synchronous Speed: N_s = (120 × f) / P
/// Actual Speed: N = N_s × (1 - slip/100)
/// Where:
/// - f: Frequency (Hz)
/// - P: Number of poles
/// - slip: Slip percentage
@riverpod
class VfdSpeedCalculator extends _$VfdSpeedCalculator {
  @override
  VfdSpeedInput build() {
    return const VfdSpeedInput(
      frequency: 50, // Default 50Hz (EU standard)
      poles: MotorPoles.poles4,
      slipPercent: 3, // Typical slip
    );
  }

  void updateFrequency(double value) {
    state = state.copyWith(frequency: value);
  }

  void updatePoles(MotorPoles value) {
    state = state.copyWith(poles: value);
  }

  void updateSlipPercent(double value) {
    state = state.copyWith(slipPercent: value);
  }

  void reset() {
    state = const VfdSpeedInput(
      frequency: 50,
      poles: MotorPoles.poles4,
      slipPercent: 3,
    );
  }
}

/// Computed VFD speed result.
@riverpod
VfdSpeedResult? vfdSpeedResult(Ref ref) {
  final input = ref.watch(vfdSpeedCalculatorProvider);

  // Validate inputs
  if (input.frequency <= 0 || input.poles.value <= 0) {
    return null;
  }

  // N_s = (120 × f) / P
  final synchronousSpeed = (120 * input.frequency) / input.poles.value;

  // N = N_s × (1 - slip/100)
  final slipFactor = 1 - (input.slipPercent / 100);
  final actualSpeed = synchronousSpeed * slipFactor;
  final slipSpeed = synchronousSpeed - actualSpeed;

  final formula = 'N_s = (120 × ${input.frequency}) / ${input.poles.value}';

  return VfdSpeedResult(
    synchronousSpeed: synchronousSpeed,
    actualSpeed: actualSpeed,
    slipSpeed: slipSpeed,
    formula: formula,
  );
}

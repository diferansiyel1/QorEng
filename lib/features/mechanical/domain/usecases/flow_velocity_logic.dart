import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flow_velocity_logic.g.dart';

/// Velocity warning level.
enum VelocityWarning {
  safe,
  warning,
  high,
}

/// Input parameters for flow velocity calculation.
class FlowVelocityInput {
  const FlowVelocityInput({
    required this.flowRate,
    required this.diameter,
  });

  /// Flow rate in m³/h
  final double flowRate;

  /// Pipe diameter (DN) in mm
  final double diameter;

  /// Get flow rate in m³/s
  double get flowRateM3s => flowRate / 3600;

  /// Get diameter in meters
  double get diameterInMeters => diameter / 1000;

  /// Get cross-sectional area in m²
  double get areaM2 {
    final radius = diameterInMeters / 2;
    return math.pi * radius * radius;
  }

  FlowVelocityInput copyWith({
    double? flowRate,
    double? diameter,
  }) {
    return FlowVelocityInput(
      flowRate: flowRate ?? this.flowRate,
      diameter: diameter ?? this.diameter,
    );
  }
}

/// Result of flow velocity calculation.
class FlowVelocityResult {
  const FlowVelocityResult({
    required this.velocity,
    required this.warning,
    required this.crossSectionArea,
    required this.formula,
  });

  /// Flow velocity in m/s
  final double velocity;

  /// Warning level
  final VelocityWarning warning;

  /// Cross-section area in m²
  final double crossSectionArea;

  /// Formula representation
  final String formula;

  String get warningMessage {
    return switch (warning) {
      VelocityWarning.safe => 'Optimal velocity for liquid flow',
      VelocityWarning.warning => 'Approaching velocity limit (3 m/s)',
      VelocityWarning.high => 'Velocity exceeds 3 m/s limit! Risk of erosion.',
    };
  }
}

/// Flow Velocity Calculator.
///
/// Formula: V = Q / A
/// Where:
/// - Q: Volumetric flow rate (m³/s)
/// - A: Cross-sectional area (m²)
@riverpod
class FlowVelocityCalculator extends _$FlowVelocityCalculator {
  @override
  FlowVelocityInput build() {
    return const FlowVelocityInput(
      flowRate: 0,
      diameter: 0,
    );
  }

  void updateFlowRate(double value) {
    state = state.copyWith(flowRate: value);
  }

  void updateDiameter(double value) {
    state = state.copyWith(diameter: value);
  }

  void reset() {
    state = const FlowVelocityInput(
      flowRate: 0,
      diameter: 0,
    );
  }
}

/// Computed flow velocity result.
@riverpod
FlowVelocityResult? flowVelocityResult(Ref ref) {
  final input = ref.watch(flowVelocityCalculatorProvider);

  // Validate inputs - avoid division by zero
  if (input.flowRate <= 0 || input.diameter <= 0) {
    return null;
  }

  final area = input.areaM2;
  final flowRateM3s = input.flowRateM3s;

  // V = Q / A
  final velocity = flowRateM3s / area;

  // Determine warning level (3 m/s is typical limit for liquids)
  final VelocityWarning warning;
  if (velocity <= 2.5) {
    warning = VelocityWarning.safe;
  } else if (velocity <= 3.0) {
    warning = VelocityWarning.warning;
  } else {
    warning = VelocityWarning.high;
  }

  final formula =
      'V = ${flowRateM3s.toStringAsFixed(6)} m³/s / ${area.toStringAsFixed(6)} m²';

  return FlowVelocityResult(
    velocity: velocity,
    warning: warning,
    crossSectionArea: area,
    formula: formula,
  );
}

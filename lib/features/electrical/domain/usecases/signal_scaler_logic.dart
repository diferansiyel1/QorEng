import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signal_scaler_logic.g.dart';

/// Common signal types for process control.
enum SignalType {
  ma4to20('4-20 mA', 4, 20),
  v0to10('0-10 V', 0, 10),
  ma0to20('0-20 mA', 0, 20),
  custom('Custom', 0, 100);

  const SignalType(this.label, this.defaultLow, this.defaultHigh);

  final String label;
  final double defaultLow;
  final double defaultHigh;
}

/// Input parameters for signal scaling.
class SignalScalerInput {
  const SignalScalerInput({
    required this.signalType,
    required this.rawLow,
    required this.rawHigh,
    required this.engLow,
    required this.engHigh,
    required this.measuredValue,
    required this.isReverse,
    required this.engUnit,
  });

  /// Signal type (4-20mA, 0-10V, etc.)
  final SignalType signalType;

  /// Raw signal range low
  final double rawLow;

  /// Raw signal range high
  final double rawHigh;

  /// Engineering range low
  final double engLow;

  /// Engineering range high
  final double engHigh;

  /// Measured value (raw signal OR PV in reverse mode)
  final double measuredValue;

  /// Reverse mode: PV to mA instead of mA to PV
  final bool isReverse;

  /// Engineering unit label
  final String engUnit;

  SignalScalerInput copyWith({
    SignalType? signalType,
    double? rawLow,
    double? rawHigh,
    double? engLow,
    double? engHigh,
    double? measuredValue,
    bool? isReverse,
    String? engUnit,
  }) {
    return SignalScalerInput(
      signalType: signalType ?? this.signalType,
      rawLow: rawLow ?? this.rawLow,
      rawHigh: rawHigh ?? this.rawHigh,
      engLow: engLow ?? this.engLow,
      engHigh: engHigh ?? this.engHigh,
      measuredValue: measuredValue ?? this.measuredValue,
      isReverse: isReverse ?? this.isReverse,
      engUnit: engUnit ?? this.engUnit,
    );
  }
}

/// Result of signal scaling calculation.
class SignalScalerResult {
  const SignalScalerResult({
    required this.outputValue,
    required this.percentageOfRange,
    required this.formula,
  });

  /// Output value (PV or mA depending on mode)
  final double outputValue;

  /// Percentage of full range (0-100)
  final double percentageOfRange;

  /// Formula representation
  final String formula;
}

/// Signal Scaler Calculator (4-20mA Converter).
///
/// Forward: PV = ((Measured - RawLow) / (RawHigh - RawLow)) * (EngHigh - EngLow) + EngLow
/// Reverse: mA = ((PV - EngLow) / (EngHigh - EngLow)) * (RawHigh - RawLow) + RawLow
@riverpod
class SignalScalerCalculator extends _$SignalScalerCalculator {
  @override
  SignalScalerInput build() {
    return const SignalScalerInput(
      signalType: SignalType.ma4to20,
      rawLow: 4,
      rawHigh: 20,
      engLow: 0,
      engHigh: 100,
      measuredValue: 0,
      isReverse: false,
      engUnit: 'Bar',
    );
  }

  void updateSignalType(SignalType type) {
    state = state.copyWith(
      signalType: type,
      rawLow: type.defaultLow,
      rawHigh: type.defaultHigh,
    );
  }

  void updateRawLow(double value) => state = state.copyWith(rawLow: value);
  void updateRawHigh(double value) => state = state.copyWith(rawHigh: value);
  void updateEngLow(double value) => state = state.copyWith(engLow: value);
  void updateEngHigh(double value) => state = state.copyWith(engHigh: value);
  void updateMeasuredValue(double value) =>
      state = state.copyWith(measuredValue: value);
  void updateEngUnit(String value) => state = state.copyWith(engUnit: value);
  void toggleReverse() => state = state.copyWith(isReverse: !state.isReverse);

  void reset() {
    state = const SignalScalerInput(
      signalType: SignalType.ma4to20,
      rawLow: 4,
      rawHigh: 20,
      engLow: 0,
      engHigh: 100,
      measuredValue: 0,
      isReverse: false,
      engUnit: 'Bar',
    );
  }
}

/// Computed signal scaling result.
@riverpod
SignalScalerResult? signalScalerResult(Ref ref) {
  final input = ref.watch(signalScalerCalculatorProvider);

  // Validate ranges - prevent division by zero
  final rawRange = input.rawHigh - input.rawLow;
  final engRange = input.engHigh - input.engLow;

  if (input.isReverse) {
    if (engRange == 0) return null;
  } else {
    if (rawRange == 0) return null;
  }

  if (input.measuredValue == 0) return null;

  double outputValue;
  double percentageOfRange;
  String formula;

  if (input.isReverse) {
    // PV to mA: ((PV - EngLow) / (EngHigh - EngLow)) * (RawHigh - RawLow) + RawLow
    percentageOfRange = ((input.measuredValue - input.engLow) / engRange) * 100;
    outputValue = ((input.measuredValue - input.engLow) / engRange) * rawRange +
        input.rawLow;
    formula = '((${input.measuredValue} - ${input.engLow}) / $engRange) '
        '× $rawRange + ${input.rawLow}';
  } else {
    // mA to PV: ((Measured - RawLow) / (RawHigh - RawLow)) * (EngHigh - EngLow) + EngLow
    percentageOfRange = ((input.measuredValue - input.rawLow) / rawRange) * 100;
    outputValue =
        ((input.measuredValue - input.rawLow) / rawRange) * engRange +
            input.engLow;
    formula = '((${input.measuredValue} - ${input.rawLow}) / $rawRange) '
        '× $engRange + ${input.engLow}';
  }

  return SignalScalerResult(
    outputValue: outputValue,
    percentageOfRange: percentageOfRange.clamp(0, 100),
    formula: formula,
  );
}

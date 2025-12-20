import 'package:engicore/core/utils/converters.dart';
import 'package:engicore/core/utils/units.dart';

/// Ohm's Law calculation modes.
enum OhmsLawMode {
  /// Calculate Voltage: V = I × R
  voltage,

  /// Calculate Current: I = V / R
  current,

  /// Calculate Resistance: R = V / I
  resistance,
}

/// Result of an Ohm's Law calculation.
class OhmsLawResult {
  const OhmsLawResult({
    required this.voltage,
    required this.current,
    required this.resistance,
    required this.mode,
    required this.formula,
  });

  final double voltage;
  final double current;
  final double resistance;
  final OhmsLawMode mode;
  final String formula;
}

/// Ohm's Law calculator use case.
///
/// Ohm's Law states that the current through a conductor between
/// two points is directly proportional to the voltage across the
/// two points, and inversely proportional to the resistance between them.
///
/// Formulas:
/// - V = I × R (Voltage)
/// - I = V / R (Current)
/// - R = V / I (Resistance)
abstract final class OhmsLawCalculator {
  /// Calculate voltage given current and resistance.
  ///
  /// V = I × R
  static OhmsLawResult calculateVoltage({
    required double current,
    required CurrentUnit currentUnit,
    required double resistance,
    required ResistanceUnit resistanceUnit,
  }) {
    // Convert to base units
    final iBase = UnitConverter.currentToBase(current, currentUnit);
    final rBase = UnitConverter.resistanceToBase(resistance, resistanceUnit);

    // Calculate voltage in base unit (V)
    final vBase = iBase * rBase;

    return OhmsLawResult(
      voltage: vBase,
      current: iBase,
      resistance: rBase,
      mode: OhmsLawMode.voltage,
      formula: 'V = $current ${currentUnit.symbol} × $resistance ${resistanceUnit.symbol}',
    );
  }

  /// Calculate current given voltage and resistance.
  ///
  /// I = V / R
  static OhmsLawResult calculateCurrent({
    required double voltage,
    required VoltageUnit voltageUnit,
    required double resistance,
    required ResistanceUnit resistanceUnit,
  }) {
    // Convert to base units
    final vBase = UnitConverter.voltageToBase(voltage, voltageUnit);
    final rBase = UnitConverter.resistanceToBase(resistance, resistanceUnit);

    // Guard against division by zero
    if (rBase == 0) {
      return OhmsLawResult(
        voltage: vBase,
        current: double.infinity,
        resistance: rBase,
        mode: OhmsLawMode.current,
        formula: 'I = $voltage ${voltageUnit.symbol} / 0 = ∞',
      );
    }

    // Calculate current in base unit (A)
    final iBase = vBase / rBase;

    return OhmsLawResult(
      voltage: vBase,
      current: iBase,
      resistance: rBase,
      mode: OhmsLawMode.current,
      formula: 'I = $voltage ${voltageUnit.symbol} / $resistance ${resistanceUnit.symbol}',
    );
  }

  /// Calculate resistance given voltage and current.
  ///
  /// R = V / I
  static OhmsLawResult calculateResistance({
    required double voltage,
    required VoltageUnit voltageUnit,
    required double current,
    required CurrentUnit currentUnit,
  }) {
    // Convert to base units
    final vBase = UnitConverter.voltageToBase(voltage, voltageUnit);
    final iBase = UnitConverter.currentToBase(current, currentUnit);

    // Guard against division by zero
    if (iBase == 0) {
      return OhmsLawResult(
        voltage: vBase,
        current: iBase,
        resistance: double.infinity,
        mode: OhmsLawMode.resistance,
        formula: 'R = $voltage ${voltageUnit.symbol} / 0 = ∞',
      );
    }

    // Calculate resistance in base unit (Ω)
    final rBase = vBase / iBase;

    return OhmsLawResult(
      voltage: vBase,
      current: iBase,
      resistance: rBase,
      mode: OhmsLawMode.resistance,
      formula: 'R = $voltage ${voltageUnit.symbol} / $current ${currentUnit.symbol}',
    );
  }
}

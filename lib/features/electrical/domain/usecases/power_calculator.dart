import 'package:engicore/core/utils/converters.dart';
import 'package:engicore/core/utils/units.dart';

/// Power calculation modes.
enum PowerMode {
  /// Calculate Power using P = V × I
  fromVoltageAndCurrent,

  /// Calculate Power using P = I² × R
  fromCurrentAndResistance,

  /// Calculate Power using P = V² / R
  fromVoltageAndResistance,
}

/// Result of a power calculation.
class PowerResult {
  const PowerResult({
    required this.power,
    required this.mode,
    required this.formula,
    this.voltage,
    this.current,
    this.resistance,
  });

  final double power;
  final PowerMode mode;
  final String formula;
  final double? voltage;
  final double? current;
  final double? resistance;
}

/// Power calculator use case.
///
/// Electrical power is the rate at which electrical energy is
/// transferred by an electric circuit.
///
/// Formulas:
/// - P = V × I (from voltage and current)
/// - P = I² × R (from current and resistance)
/// - P = V² / R (from voltage and resistance)
abstract final class PowerCalculator {
  /// Calculate power from voltage and current.
  ///
  /// P = V × I
  static PowerResult fromVoltageAndCurrent({
    required double voltage,
    required VoltageUnit voltageUnit,
    required double current,
    required CurrentUnit currentUnit,
  }) {
    // Convert to base units
    final vBase = UnitConverter.voltageToBase(voltage, voltageUnit);
    final iBase = UnitConverter.currentToBase(current, currentUnit);

    // Calculate power in base unit (W)
    final power = vBase * iBase;

    return PowerResult(
      power: power,
      mode: PowerMode.fromVoltageAndCurrent,
      formula: 'P = $voltage ${voltageUnit.symbol} × $current ${currentUnit.symbol}',
      voltage: vBase,
      current: iBase,
    );
  }

  /// Calculate power from current and resistance.
  ///
  /// P = I² × R
  static PowerResult fromCurrentAndResistance({
    required double current,
    required CurrentUnit currentUnit,
    required double resistance,
    required ResistanceUnit resistanceUnit,
  }) {
    // Convert to base units
    final iBase = UnitConverter.currentToBase(current, currentUnit);
    final rBase = UnitConverter.resistanceToBase(resistance, resistanceUnit);

    // Calculate power in base unit (W)
    final power = iBase * iBase * rBase;

    return PowerResult(
      power: power,
      mode: PowerMode.fromCurrentAndResistance,
      formula: 'P = ($current ${currentUnit.symbol})² × $resistance ${resistanceUnit.symbol}',
      current: iBase,
      resistance: rBase,
    );
  }

  /// Calculate power from voltage and resistance.
  ///
  /// P = V² / R
  static PowerResult fromVoltageAndResistance({
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
      return PowerResult(
        power: double.infinity,
        mode: PowerMode.fromVoltageAndResistance,
        formula: 'P = ($voltage ${voltageUnit.symbol})² / 0 = ∞',
        voltage: vBase,
        resistance: rBase,
      );
    }

    // Calculate power in base unit (W)
    final power = (vBase * vBase) / rBase;

    return PowerResult(
      power: power,
      mode: PowerMode.fromVoltageAndResistance,
      formula: 'P = ($voltage ${voltageUnit.symbol})² / $resistance ${resistanceUnit.symbol}',
      voltage: vBase,
      resistance: rBase,
    );
  }
}

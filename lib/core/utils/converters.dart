import 'package:engicore/core/utils/units.dart';

/// Utility class for unit conversions.
///
/// All conversions go through base SI units internally.
abstract final class UnitConverter {
  // ═══════════════════════════════════════════════════════════════════════════
  // Voltage Conversions
  // ═══════════════════════════════════════════════════════════════════════════

  /// Convert voltage from one unit to another.
  static double convertVoltage(
    double value,
    VoltageUnit from,
    VoltageUnit to,
  ) {
    final baseValue = value * from.toBaseMultiplier;
    return baseValue / to.toBaseMultiplier;
  }

  /// Convert voltage to base unit (Volts).
  static double voltageToBase(double value, VoltageUnit unit) {
    return value * unit.toBaseMultiplier;
  }

  /// Convert voltage from base unit (Volts).
  static double voltageFromBase(double value, VoltageUnit unit) {
    return value / unit.toBaseMultiplier;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Current Conversions
  // ═══════════════════════════════════════════════════════════════════════════

  /// Convert current from one unit to another.
  static double convertCurrent(
    double value,
    CurrentUnit from,
    CurrentUnit to,
  ) {
    final baseValue = value * from.toBaseMultiplier;
    return baseValue / to.toBaseMultiplier;
  }

  /// Convert current to base unit (Amperes).
  static double currentToBase(double value, CurrentUnit unit) {
    return value * unit.toBaseMultiplier;
  }

  /// Convert current from base unit (Amperes).
  static double currentFromBase(double value, CurrentUnit unit) {
    return value / unit.toBaseMultiplier;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Resistance Conversions
  // ═══════════════════════════════════════════════════════════════════════════

  /// Convert resistance from one unit to another.
  static double convertResistance(
    double value,
    ResistanceUnit from,
    ResistanceUnit to,
  ) {
    final baseValue = value * from.toBaseMultiplier;
    return baseValue / to.toBaseMultiplier;
  }

  /// Convert resistance to base unit (Ohms).
  static double resistanceToBase(double value, ResistanceUnit unit) {
    return value * unit.toBaseMultiplier;
  }

  /// Convert resistance from base unit (Ohms).
  static double resistanceFromBase(double value, ResistanceUnit unit) {
    return value / unit.toBaseMultiplier;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Power Conversions
  // ═══════════════════════════════════════════════════════════════════════════

  /// Convert power from one unit to another.
  static double convertPower(
    double value,
    PowerUnit from,
    PowerUnit to,
  ) {
    final baseValue = value * from.toBaseMultiplier;
    return baseValue / to.toBaseMultiplier;
  }

  /// Convert power to base unit (Watts).
  static double powerToBase(double value, PowerUnit unit) {
    return value * unit.toBaseMultiplier;
  }

  /// Convert power from base unit (Watts).
  static double powerFromBase(double value, PowerUnit unit) {
    return value / unit.toBaseMultiplier;
  }
}

import 'package:flutter/material.dart';

/// Represents an available electrical calculation.
class ElectricalCalculation {
  const ElectricalCalculation({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
    this.formula,
  });

  /// Unique identifier for the calculation.
  final String id;

  /// Display name of the calculation.
  final String name;

  /// Brief description of what the calculation does.
  final String description;

  /// Icon to display in the list.
  final IconData icon;

  /// Route path to navigate to.
  final String route;

  /// Optional formula representation.
  final String? formula;
}

/// Available calculations for Power & Cables tab.
abstract final class PowerCablesCalculations {
  static const List<ElectricalCalculation> all = [
    ElectricalCalculation(
      id: 'ohms-law',
      name: "Ohm's Law",
      description: 'Calculate voltage, current, or resistance',
      icon: Icons.electric_bolt,
      route: '/electrical/ohms-law',
      formula: 'V = I × R',
    ),
    ElectricalCalculation(
      id: 'power',
      name: 'Power Calculator',
      description: 'Calculate electrical power consumption',
      icon: Icons.power,
      route: '/electrical/power',
      formula: 'P = V × I',
    ),
    ElectricalCalculation(
      id: 'voltage-drop',
      name: 'Voltage Drop Calculator',
      description: 'Calculate cable voltage drop and percentage',
      icon: Icons.trending_down,
      route: '/electrical/voltage-drop',
      formula: 'V = (k×I×L×ρ)/S',
    ),
  ];
}

/// Available calculations for Automation & Control tab.
abstract final class AutomationControlCalculations {
  static const List<ElectricalCalculation> all = [
    ElectricalCalculation(
      id: 'signal-scaler',
      name: 'Signal Scaler (4-20mA)',
      description: 'Convert raw signals to engineering units',
      icon: Icons.straighten,
      route: '/electrical/signal-scaler',
      formula: 'PV = Scale(mA)',
    ),
    ElectricalCalculation(
      id: 'vfd-speed',
      name: 'VFD Motor Speed',
      description: 'Calculate motor RPM from frequency',
      icon: Icons.speed,
      route: '/electrical/vfd-speed',
      formula: 'N = 120f/P',
    ),
  ];
}

/// Legacy: All electrical calculations combined.
abstract final class ElectricalCalculations {
  static const List<ElectricalCalculation> all = [
    ...PowerCablesCalculations.all,
    ...AutomationControlCalculations.all,
  ];
}

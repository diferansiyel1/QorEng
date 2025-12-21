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

/// Available electrical calculations in the app.
abstract final class ElectricalCalculations {
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

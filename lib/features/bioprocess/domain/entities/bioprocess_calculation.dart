import 'package:flutter/material.dart';

/// Represents an available bioprocess calculation.
class BioprocessCalculation {
  const BioprocessCalculation({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
    this.formula,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String route;
  final String? formula;
}

/// Available bioprocess calculations in the app.
abstract final class BioprocessCalculations {
  static const List<BioprocessCalculation> all = [
    BioprocessCalculation(
      id: 'tip-speed',
      name: 'Impeller Tip Speed',
      description: 'Calculate mixing tip speed and assess shear stress',
      icon: Icons.settings_suggest,
      route: '/bioprocess/tip-speed',
      formula: 'V = π × D × N/60',
    ),
  ];
}

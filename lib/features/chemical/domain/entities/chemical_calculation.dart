import 'package:flutter/material.dart';

/// Represents an available chemical calculation.
class ChemicalCalculation {
  const ChemicalCalculation({
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

/// Available chemical calculations in the app.
abstract final class ChemicalCalculations {
  static const List<ChemicalCalculation> all = [
    ChemicalCalculation(
      id: 'dilution',
      name: 'Dilution Calculator',
      description: 'Calculate stock solution and water volumes',
      icon: Icons.water_drop,
      route: '/chemical/dilution',
      formula: 'C₁V₁ = C₂V₂',
    ),
    ChemicalCalculation(
      id: 'molarity',
      name: 'Molarity Converter',
      description: 'Convert g/L to Molarity given molecular weight',
      icon: Icons.science,
      route: '/chemical/molarity',
      formula: 'M = (g/L) / MW',
    ),
  ];
}

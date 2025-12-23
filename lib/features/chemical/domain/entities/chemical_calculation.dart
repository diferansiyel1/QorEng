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

/// General chemistry calculations (Tab 1).
abstract final class GeneralChemistryCalculations {
  static const List<ChemicalCalculation> all = [
    ChemicalCalculation(
      id: 'chem-guard',
      name: 'ChemGuard',
      description: 'Check chemical-material compatibility ratings',
      icon: Icons.shield,
      route: '/chemical/chem-guard',
      formula: 'A/B/C/D Ratings',
    ),
    ChemicalCalculation(
      id: 'material-finder',
      name: 'Material Finder',
      description: 'Find compatible materials for a chemical',
      icon: Icons.search,
      route: '/chemical/material-finder',
      formula: 'Reverse Lookup',
    ),
    ChemicalCalculation(
      id: 'dilution',
      name: 'Dilution Calculator',
      description: 'Calculate stock and water volumes for dilutions',
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

/// Spectroscopy calculations (Tab 2).
abstract final class SpectroscopyCalculations {
  static const List<ChemicalCalculation> all = [
    ChemicalCalculation(
      id: 'beer-lambert',
      name: 'Beer-Lambert Solver',
      description: 'Solve for absorbance, concentration, or extinction',
      icon: Icons.lightbulb,
      route: '/chemical/beer-lambert',
      formula: 'A = ε × l × c',
    ),
    ChemicalCalculation(
      id: 'transmittance',
      name: 'Transmittance Converter',
      description: 'Convert between %T and Absorbance',
      icon: Icons.swap_horiz,
      route: '/chemical/transmittance',
      formula: 'A = 2 - log(%T)',
    ),
    ChemicalCalculation(
      id: 'od-cell-density',
      name: 'OD / Cell Density',
      description: 'Estimate cell count from OD600 readings',
      icon: Icons.biotech,
      route: '/chemical/od-cell-density',
      formula: 'Cells = OD × Dilution × Factor',
    ),
  ];
}

/// Electrochemistry & kinetics calculations (Tab 3).
abstract final class ElectrochemCalculations {
  static const List<ChemicalCalculation> all = [
    ChemicalCalculation(
      id: 'ph-sensor',
      name: 'pH Sensor Diagnostics',
      description: 'Calculate pH from mV using Nernst equation',
      icon: Icons.monitor_heart,
      route: '/chemical/ph-sensor',
      formula: 'E = E₀ - (RT/F)×2.303×pH',
    ),
    ChemicalCalculation(
      id: 'arrhenius',
      name: 'Arrhenius Rate Calculator',
      description: 'Calculate reaction rate change with temperature',
      icon: Icons.speed,
      route: '/chemical/arrhenius',
      formula: 'k₂/k₁ = exp(Ea/R × ΔT⁻¹)',
    ),
  ];
}

/// Legacy: All chemical calculations combined.
abstract final class ChemicalCalculations {
  static const List<ChemicalCalculation> all = [
    ...GeneralChemistryCalculations.all,
    ...SpectroscopyCalculations.all,
    ...ElectrochemCalculations.all,
  ];
}

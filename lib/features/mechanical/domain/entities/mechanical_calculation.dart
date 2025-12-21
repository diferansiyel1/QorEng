import 'package:flutter/material.dart';

/// Represents an available mechanical calculation.
class MechanicalCalculation {
  const MechanicalCalculation({
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

/// Available calculations for Solids & Hydraulics tab.
abstract final class SolidsHydraulicsCalculations {
  static const List<MechanicalCalculation> all = [
    MechanicalCalculation(
      id: 'hydraulic-force',
      name: 'Hydraulic Cylinder Force',
      description: 'Calculate push and pull forces for hydraulic cylinders',
      icon: Icons.compress,
      route: '/mechanical/hydraulic-force',
      formula: 'F = P × A',
    ),
  ];
}

/// Available calculations for Fluid & Flow tab.
abstract final class FluidFlowCalculations {
  static const List<MechanicalCalculation> all = [
    MechanicalCalculation(
      id: 'reynolds',
      name: 'Reynolds Number',
      description: 'Determine if flow is laminar or turbulent',
      icon: Icons.waves,
      route: '/mechanical/reynolds',
      formula: 'Re = ρVD/μ',
    ),
    MechanicalCalculation(
      id: 'pressure-drop',
      name: 'Pipe Pressure Drop',
      description: 'Calculate pressure loss using Darcy-Weisbach',
      icon: Icons.trending_down,
      route: '/mechanical/pressure-drop',
      formula: 'ΔP = f(L/D)(ρV²/2)',
    ),
    MechanicalCalculation(
      id: 'flow-velocity',
      name: 'Flow Velocity',
      description: 'Calculate velocity from flow rate and pipe size',
      icon: Icons.speed,
      route: '/mechanical/flow-velocity',
      formula: 'V = Q/A',
    ),
    MechanicalCalculation(
      id: 'viscosity',
      name: 'Viscosity Lab',
      description: 'Dynamic/Kinematic converter and Efflux Cup calculator',
      icon: Icons.water_drop,
      route: '/mechanical/viscosity',
      formula: 'ν = μ/ρ',
    ),
  ];
}

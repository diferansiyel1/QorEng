import 'package:flutter/material.dart';

/// Searchable tool definition for global search.
class SearchableTool {
  const SearchableTool({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.keywords,
    required this.accentColor,
    required this.moduleType,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final List<String> keywords;
  final Color accentColor;
  final String moduleType;
}

/// All available tools in the app for search indexing.
abstract final class AppToolsRegistry {
  static const List<SearchableTool> all = [
    // Electrical - Power & Cables
    SearchableTool(
      id: 'ohms-law',
      title: "Ohm's Law",
      subtitle: 'Voltage, Current, Resistance',
      icon: Icons.electric_bolt,
      route: '/electrical/ohms-law',
      keywords: ['voltage', 'current', 'resistance', 'ohm', 'vir', 'electrical'],
      accentColor: Color(0xFF00E5FF),
      moduleType: 'Electrical',
    ),
    SearchableTool(
      id: 'power',
      title: 'Power Calculator',
      subtitle: 'Electrical power P = V × I',
      icon: Icons.power,
      route: '/electrical/power',
      keywords: ['power', 'watt', 'voltage', 'current', 'electrical'],
      accentColor: Color(0xFF00E5FF),
      moduleType: 'Electrical',
    ),
    SearchableTool(
      id: 'voltage-drop',
      title: 'Voltage Drop',
      subtitle: 'Cable sizing and voltage loss',
      icon: Icons.trending_down,
      route: '/electrical/voltage-drop',
      keywords: ['voltage', 'drop', 'cable', 'wire', 'sizing', 'loss', 'conductor'],
      accentColor: Color(0xFF00E5FF),
      moduleType: 'Electrical',
    ),
    // Electrical - Automation
    SearchableTool(
      id: 'signal-scaler',
      title: 'Signal Scaler (4-20mA)',
      subtitle: 'Convert raw signals to PV',
      icon: Icons.straighten,
      route: '/electrical/signal-scaler',
      keywords: ['signal', '4-20ma', 'scaler', 'plc', 'transmitter', 'scaling', 'analog'],
      accentColor: Color(0xFF00E5FF),
      moduleType: 'Electrical',
    ),
    SearchableTool(
      id: 'vfd-speed',
      title: 'VFD Motor Speed',
      subtitle: 'Frequency to RPM calculation',
      icon: Icons.speed,
      route: '/electrical/vfd-speed',
      keywords: ['vfd', 'motor', 'speed', 'rpm', 'frequency', 'poles', 'drive'],
      accentColor: Color(0xFF00E5FF),
      moduleType: 'Electrical',
    ),

    // Mechanical - Solids & Hydraulics
    SearchableTool(
      id: 'hydraulic-force',
      title: 'Hydraulic Cylinder Force',
      subtitle: 'Push/pull force calculation',
      icon: Icons.compress,
      route: '/mechanical/hydraulic-force',
      keywords: ['hydraulic', 'cylinder', 'force', 'pressure', 'piston', 'bore'],
      accentColor: Color(0xFFFF6D00),
      moduleType: 'Mechanical',
    ),
    // Mechanical - Fluid & Flow
    SearchableTool(
      id: 'reynolds',
      title: 'Reynolds Number',
      subtitle: 'Laminar vs Turbulent flow',
      icon: Icons.waves,
      route: '/mechanical/reynolds',
      keywords: ['reynolds', 'flow', 'laminar', 'turbulent', 'pipe', 'fluid'],
      accentColor: Color(0xFFFF6D00),
      moduleType: 'Mechanical',
    ),
    SearchableTool(
      id: 'pressure-drop',
      title: 'Pipe Pressure Drop',
      subtitle: 'Darcy-Weisbach pressure loss',
      icon: Icons.trending_down,
      route: '/mechanical/pressure-drop',
      keywords: ['pressure', 'drop', 'pipe', 'flow', 'darcy', 'friction', 'loss'],
      accentColor: Color(0xFFFF6D00),
      moduleType: 'Mechanical',
    ),
    SearchableTool(
      id: 'flow-velocity',
      title: 'Flow Velocity',
      subtitle: 'V = Q / A calculation',
      icon: Icons.speed,
      route: '/mechanical/flow-velocity',
      keywords: ['flow', 'velocity', 'rate', 'pipe', 'diameter', 'area'],
      accentColor: Color(0xFFFF6D00),
      moduleType: 'Mechanical',
    ),
    SearchableTool(
      id: 'viscosity',
      title: 'Viscosity Lab',
      subtitle: 'Dynamic/Kinematic & Efflux Cup',
      icon: Icons.water_drop,
      route: '/mechanical/viscosity',
      keywords: ['viscosity', 'dynamic', 'kinematic', 'ford', 'zahn', 'cup', 'efflux', 'coating'],
      accentColor: Color(0xFFFF6D00),
      moduleType: 'Mechanical',
    ),

    // Chemical - General
    SearchableTool(
      id: 'dilution',
      title: 'Dilution Calculator',
      subtitle: 'C₁V₁ = C₂V₂ formula',
      icon: Icons.water_drop,
      route: '/chemical/dilution',
      keywords: ['dilution', 'concentration', 'stock', 'solution', 'c1v1'],
      accentColor: Color(0xFF7C4DFF),
      moduleType: 'Chemical',
    ),
    SearchableTool(
      id: 'molarity',
      title: 'Molarity Converter',
      subtitle: 'g/L to Molar conversion',
      icon: Icons.science,
      route: '/chemical/molarity',
      keywords: ['molarity', 'molar', 'molecular', 'weight', 'concentration'],
      accentColor: Color(0xFF7C4DFF),
      moduleType: 'Chemical',
    ),
    // Chemical - Spectroscopy
    SearchableTool(
      id: 'beer-lambert',
      title: 'Beer-Lambert Solver',
      subtitle: 'A = ε × l × c',
      icon: Icons.lightbulb,
      route: '/chemical/beer-lambert',
      keywords: ['beer', 'lambert', 'absorbance', 'extinction', 'spectroscopy', 'uv-vis'],
      accentColor: Color(0xFF7C4DFF),
      moduleType: 'Chemical',
    ),
    SearchableTool(
      id: 'transmittance',
      title: 'Transmittance Converter',
      subtitle: '%T ↔ Absorbance',
      icon: Icons.swap_horiz,
      route: '/chemical/transmittance',
      keywords: ['transmittance', 'absorbance', 'light', 'spectroscopy'],
      accentColor: Color(0xFF7C4DFF),
      moduleType: 'Chemical',
    ),
    SearchableTool(
      id: 'od-cell-density',
      title: 'OD / Cell Density',
      subtitle: 'Estimate cells from OD600',
      icon: Icons.biotech,
      route: '/chemical/od-cell-density',
      keywords: ['od', 'cell', 'density', 'od600', 'bacteria', 'culture'],
      accentColor: Color(0xFF7C4DFF),
      moduleType: 'Chemical',
    ),
    // Chemical - Electrochem
    SearchableTool(
      id: 'ph-sensor',
      title: 'pH Sensor Diagnostics',
      subtitle: 'Nernst equation & slope',
      icon: Icons.monitor_heart,
      route: '/chemical/ph-sensor',
      keywords: ['ph', 'sensor', 'nernst', 'electrode', 'calibration', 'slope'],
      accentColor: Color(0xFF7C4DFF),
      moduleType: 'Chemical',
    ),
    SearchableTool(
      id: 'arrhenius',
      title: 'Arrhenius Rate Calculator',
      subtitle: 'Temperature effect on rate',
      icon: Icons.speed,
      route: '/chemical/arrhenius',
      keywords: ['arrhenius', 'rate', 'temperature', 'kinetics', 'activation', 'energy'],
      accentColor: Color(0xFF7C4DFF),
      moduleType: 'Chemical',
    ),

    // Bioprocess
    SearchableTool(
      id: 'tip-speed',
      title: 'Impeller Tip Speed',
      subtitle: 'Bioreactor shear analysis',
      icon: Icons.rotate_right,
      route: '/bioprocess/tip-speed',
      keywords: ['tip', 'speed', 'impeller', 'bioreactor', 'shear', 'agitation', 'rpm'],
      accentColor: Color(0xFF00C853),
      moduleType: 'Bioprocess',
    ),
  ];

  /// Search tools by query string.
  static List<SearchableTool> search(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return all.where((tool) {
      final titleMatch = tool.title.toLowerCase().contains(lowerQuery);
      final subtitleMatch = tool.subtitle.toLowerCase().contains(lowerQuery);
      final keywordMatch = tool.keywords.any((k) => k.contains(lowerQuery));
      final moduleMatch = tool.moduleType.toLowerCase().contains(lowerQuery);
      return titleMatch || subtitleMatch || keywordMatch || moduleMatch;
    }).toList();
  }
}

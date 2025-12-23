/// Piping Master - Industrial Standards Data
///
/// Exhaustive reference data for process flanges (DIN EN 1092-1 & ANSI B16.5)
/// and sensor fittings for 12mm glass sensors.
library;

import 'package:flutter/foundation.dart';

// ============================================================================
// FLANGE STANDARDS
// ============================================================================

/// Flange standard enumeration.
enum FlangeStandard {
  din('DIN EN 1092-1', 'Metric (mm)'),
  ansi('ANSI B16.5', 'Imperial (inch)');

  const FlangeStandard(this.name, this.unit);
  final String name;
  final String unit;
}

/// Pressure class for DIN flanges.
enum DinPressureClass {
  pn10('PN10', 10),
  pn16('PN16', 16),
  pn40('PN40', 40);

  const DinPressureClass(this.name, this.bar);
  final String name;
  final int bar;
}

/// Pressure class for ANSI flanges.
enum AnsiPressureClass {
  class150('Class 150', 150),
  class300('Class 300', 300);

  const AnsiPressureClass(this.name, this.rating);
  final String name;
  final int rating;
}

/// Flange dimension data class.
@immutable
class FlangeDim {
  const FlangeDim({
    required this.nominalSize,
    required this.outerDiameter,
    required this.boltCircleDiameter,
    required this.boltCount,
    required this.boltSize,
    required this.boltLength,
    required this.holeDiameter,
    this.pipeOD,
  });

  /// Nominal size (DN or NPS as string).
  final String nominalSize;

  /// Flange outer diameter in mm.
  final double outerDiameter;

  /// Bolt circle diameter (BCD/k) in mm.
  final double boltCircleDiameter;

  /// Number of bolt holes.
  final int boltCount;

  /// Bolt size (e.g., "M16", "5/8\"").
  final String boltSize;

  /// Recommended bolt length in mm.
  final double boltLength;

  /// Bolt hole diameter in mm.
  final double holeDiameter;

  /// Pipe outer diameter in mm (for reference).
  final double? pipeOD;
}

// ============================================================================
// DIN PN10 FLANGE DATA (EN 1092-1 Type 11 Welding Neck)
// ============================================================================

/// DIN PN10 flange dimensions for DN15 to DN300.
const Map<String, FlangeDim> dinPn10Flanges = {
  'DN15': FlangeDim(
    nominalSize: 'DN15',
    outerDiameter: 95,
    boltCircleDiameter: 65,
    boltCount: 4,
    boltSize: 'M12',
    boltLength: 45,
    holeDiameter: 14,
    pipeOD: 21.3,
  ),
  'DN20': FlangeDim(
    nominalSize: 'DN20',
    outerDiameter: 105,
    boltCircleDiameter: 75,
    boltCount: 4,
    boltSize: 'M12',
    boltLength: 45,
    holeDiameter: 14,
    pipeOD: 26.9,
  ),
  'DN25': FlangeDim(
    nominalSize: 'DN25',
    outerDiameter: 115,
    boltCircleDiameter: 85,
    boltCount: 4,
    boltSize: 'M12',
    boltLength: 50,
    holeDiameter: 14,
    pipeOD: 33.7,
  ),
  'DN32': FlangeDim(
    nominalSize: 'DN32',
    outerDiameter: 140,
    boltCircleDiameter: 100,
    boltCount: 4,
    boltSize: 'M16',
    boltLength: 55,
    holeDiameter: 18,
    pipeOD: 42.4,
  ),
  'DN40': FlangeDim(
    nominalSize: 'DN40',
    outerDiameter: 150,
    boltCircleDiameter: 110,
    boltCount: 4,
    boltSize: 'M16',
    boltLength: 55,
    holeDiameter: 18,
    pipeOD: 48.3,
  ),
  'DN50': FlangeDim(
    nominalSize: 'DN50',
    outerDiameter: 165,
    boltCircleDiameter: 125,
    boltCount: 4,
    boltSize: 'M16',
    boltLength: 60,
    holeDiameter: 18,
    pipeOD: 60.3,
  ),
  'DN65': FlangeDim(
    nominalSize: 'DN65',
    outerDiameter: 185,
    boltCircleDiameter: 145,
    boltCount: 4,
    boltSize: 'M16',
    boltLength: 60,
    holeDiameter: 18,
    pipeOD: 76.1,
  ),
  'DN80': FlangeDim(
    nominalSize: 'DN80',
    outerDiameter: 200,
    boltCircleDiameter: 160,
    boltCount: 8,
    boltSize: 'M16',
    boltLength: 65,
    holeDiameter: 18,
    pipeOD: 88.9,
  ),
  'DN100': FlangeDim(
    nominalSize: 'DN100',
    outerDiameter: 220,
    boltCircleDiameter: 180,
    boltCount: 8,
    boltSize: 'M16',
    boltLength: 65,
    holeDiameter: 18,
    pipeOD: 114.3,
  ),
  'DN125': FlangeDim(
    nominalSize: 'DN125',
    outerDiameter: 250,
    boltCircleDiameter: 210,
    boltCount: 8,
    boltSize: 'M16',
    boltLength: 70,
    holeDiameter: 18,
    pipeOD: 139.7,
  ),
  'DN150': FlangeDim(
    nominalSize: 'DN150',
    outerDiameter: 285,
    boltCircleDiameter: 240,
    boltCount: 8,
    boltSize: 'M20',
    boltLength: 75,
    holeDiameter: 22,
    pipeOD: 168.3,
  ),
  'DN200': FlangeDim(
    nominalSize: 'DN200',
    outerDiameter: 340,
    boltCircleDiameter: 295,
    boltCount: 8,
    boltSize: 'M20',
    boltLength: 80,
    holeDiameter: 22,
    pipeOD: 219.1,
  ),
  'DN250': FlangeDim(
    nominalSize: 'DN250',
    outerDiameter: 395,
    boltCircleDiameter: 350,
    boltCount: 12,
    boltSize: 'M20',
    boltLength: 85,
    holeDiameter: 22,
    pipeOD: 273.0,
  ),
  'DN300': FlangeDim(
    nominalSize: 'DN300',
    outerDiameter: 445,
    boltCircleDiameter: 400,
    boltCount: 12,
    boltSize: 'M20',
    boltLength: 90,
    holeDiameter: 22,
    pipeOD: 323.9,
  ),
};

// ============================================================================
// DIN PN16 FLANGE DATA (EN 1092-1 Type 11 Welding Neck)
// ============================================================================

/// DIN PN16 flange dimensions for DN15 to DN300.
const Map<String, FlangeDim> dinPn16Flanges = {
  'DN15': FlangeDim(
    nominalSize: 'DN15',
    outerDiameter: 95,
    boltCircleDiameter: 65,
    boltCount: 4,
    boltSize: 'M12',
    boltLength: 50,
    holeDiameter: 14,
    pipeOD: 21.3,
  ),
  'DN20': FlangeDim(
    nominalSize: 'DN20',
    outerDiameter: 105,
    boltCircleDiameter: 75,
    boltCount: 4,
    boltSize: 'M12',
    boltLength: 50,
    holeDiameter: 14,
    pipeOD: 26.9,
  ),
  'DN25': FlangeDim(
    nominalSize: 'DN25',
    outerDiameter: 115,
    boltCircleDiameter: 85,
    boltCount: 4,
    boltSize: 'M12',
    boltLength: 55,
    holeDiameter: 14,
    pipeOD: 33.7,
  ),
  'DN32': FlangeDim(
    nominalSize: 'DN32',
    outerDiameter: 140,
    boltCircleDiameter: 100,
    boltCount: 4,
    boltSize: 'M16',
    boltLength: 60,
    holeDiameter: 18,
    pipeOD: 42.4,
  ),
  'DN40': FlangeDim(
    nominalSize: 'DN40',
    outerDiameter: 150,
    boltCircleDiameter: 110,
    boltCount: 4,
    boltSize: 'M16',
    boltLength: 60,
    holeDiameter: 18,
    pipeOD: 48.3,
  ),
  'DN50': FlangeDim(
    nominalSize: 'DN50',
    outerDiameter: 165,
    boltCircleDiameter: 125,
    boltCount: 4,
    boltSize: 'M16',
    boltLength: 65,
    holeDiameter: 18,
    pipeOD: 60.3,
  ),
  'DN65': FlangeDim(
    nominalSize: 'DN65',
    outerDiameter: 185,
    boltCircleDiameter: 145,
    boltCount: 8,
    boltSize: 'M16',
    boltLength: 65,
    holeDiameter: 18,
    pipeOD: 76.1,
  ),
  'DN80': FlangeDim(
    nominalSize: 'DN80',
    outerDiameter: 200,
    boltCircleDiameter: 160,
    boltCount: 8,
    boltSize: 'M16',
    boltLength: 70,
    holeDiameter: 18,
    pipeOD: 88.9,
  ),
  'DN100': FlangeDim(
    nominalSize: 'DN100',
    outerDiameter: 220,
    boltCircleDiameter: 180,
    boltCount: 8,
    boltSize: 'M16',
    boltLength: 75,
    holeDiameter: 18,
    pipeOD: 114.3,
  ),
  'DN125': FlangeDim(
    nominalSize: 'DN125',
    outerDiameter: 250,
    boltCircleDiameter: 210,
    boltCount: 8,
    boltSize: 'M16',
    boltLength: 80,
    holeDiameter: 18,
    pipeOD: 139.7,
  ),
  'DN150': FlangeDim(
    nominalSize: 'DN150',
    outerDiameter: 285,
    boltCircleDiameter: 240,
    boltCount: 8,
    boltSize: 'M20',
    boltLength: 80,
    holeDiameter: 22,
    pipeOD: 168.3,
  ),
  'DN200': FlangeDim(
    nominalSize: 'DN200',
    outerDiameter: 340,
    boltCircleDiameter: 295,
    boltCount: 12,
    boltSize: 'M20',
    boltLength: 85,
    holeDiameter: 22,
    pipeOD: 219.1,
  ),
  'DN250': FlangeDim(
    nominalSize: 'DN250',
    outerDiameter: 405,
    boltCircleDiameter: 355,
    boltCount: 12,
    boltSize: 'M24',
    boltLength: 95,
    holeDiameter: 26,
    pipeOD: 273.0,
  ),
  'DN300': FlangeDim(
    nominalSize: 'DN300',
    outerDiameter: 460,
    boltCircleDiameter: 410,
    boltCount: 12,
    boltSize: 'M24',
    boltLength: 100,
    holeDiameter: 26,
    pipeOD: 323.9,
  ),
};

// ============================================================================
// DIN PN40 FLANGE DATA (EN 1092-1 Type 11 Welding Neck)
// ============================================================================

/// DIN PN40 flange dimensions for DN15 to DN300.
const Map<String, FlangeDim> dinPn40Flanges = {
  'DN15': FlangeDim(
    nominalSize: 'DN15',
    outerDiameter: 95,
    boltCircleDiameter: 65,
    boltCount: 4,
    boltSize: 'M12',
    boltLength: 55,
    holeDiameter: 14,
    pipeOD: 21.3,
  ),
  'DN20': FlangeDim(
    nominalSize: 'DN20',
    outerDiameter: 105,
    boltCircleDiameter: 75,
    boltCount: 4,
    boltSize: 'M12',
    boltLength: 55,
    holeDiameter: 14,
    pipeOD: 26.9,
  ),
  'DN25': FlangeDim(
    nominalSize: 'DN25',
    outerDiameter: 115,
    boltCircleDiameter: 85,
    boltCount: 4,
    boltSize: 'M12',
    boltLength: 60,
    holeDiameter: 14,
    pipeOD: 33.7,
  ),
  'DN32': FlangeDim(
    nominalSize: 'DN32',
    outerDiameter: 140,
    boltCircleDiameter: 100,
    boltCount: 4,
    boltSize: 'M16',
    boltLength: 65,
    holeDiameter: 18,
    pipeOD: 42.4,
  ),
  'DN40': FlangeDim(
    nominalSize: 'DN40',
    outerDiameter: 150,
    boltCircleDiameter: 110,
    boltCount: 4,
    boltSize: 'M16',
    boltLength: 70,
    holeDiameter: 18,
    pipeOD: 48.3,
  ),
  'DN50': FlangeDim(
    nominalSize: 'DN50',
    outerDiameter: 165,
    boltCircleDiameter: 125,
    boltCount: 4,
    boltSize: 'M16',
    boltLength: 75,
    holeDiameter: 18,
    pipeOD: 60.3,
  ),
  'DN65': FlangeDim(
    nominalSize: 'DN65',
    outerDiameter: 185,
    boltCircleDiameter: 145,
    boltCount: 8,
    boltSize: 'M16',
    boltLength: 75,
    holeDiameter: 18,
    pipeOD: 76.1,
  ),
  'DN80': FlangeDim(
    nominalSize: 'DN80',
    outerDiameter: 200,
    boltCircleDiameter: 160,
    boltCount: 8,
    boltSize: 'M16',
    boltLength: 80,
    holeDiameter: 18,
    pipeOD: 88.9,
  ),
  'DN100': FlangeDim(
    nominalSize: 'DN100',
    outerDiameter: 235,
    boltCircleDiameter: 190,
    boltCount: 8,
    boltSize: 'M20',
    boltLength: 90,
    holeDiameter: 22,
    pipeOD: 114.3,
  ),
  'DN125': FlangeDim(
    nominalSize: 'DN125',
    outerDiameter: 270,
    boltCircleDiameter: 220,
    boltCount: 8,
    boltSize: 'M24',
    boltLength: 100,
    holeDiameter: 26,
    pipeOD: 139.7,
  ),
  'DN150': FlangeDim(
    nominalSize: 'DN150',
    outerDiameter: 300,
    boltCircleDiameter: 250,
    boltCount: 8,
    boltSize: 'M24',
    boltLength: 105,
    holeDiameter: 26,
    pipeOD: 168.3,
  ),
  'DN200': FlangeDim(
    nominalSize: 'DN200',
    outerDiameter: 360,
    boltCircleDiameter: 310,
    boltCount: 12,
    boltSize: 'M24',
    boltLength: 115,
    holeDiameter: 26,
    pipeOD: 219.1,
  ),
  'DN250': FlangeDim(
    nominalSize: 'DN250',
    outerDiameter: 425,
    boltCircleDiameter: 370,
    boltCount: 12,
    boltSize: 'M27',
    boltLength: 125,
    holeDiameter: 30,
    pipeOD: 273.0,
  ),
  'DN300': FlangeDim(
    nominalSize: 'DN300',
    outerDiameter: 485,
    boltCircleDiameter: 430,
    boltCount: 16,
    boltSize: 'M27',
    boltLength: 135,
    holeDiameter: 30,
    pipeOD: 323.9,
  ),
};

// ============================================================================
// ANSI CLASS 150 FLANGE DATA (B16.5)
// ============================================================================

/// ANSI Class 150 flange dimensions for 1/2" to 12".
const Map<String, FlangeDim> ansi150Flanges = {
  '1/2"': FlangeDim(
    nominalSize: '1/2"',
    outerDiameter: 88.9,
    boltCircleDiameter: 60.3,
    boltCount: 4,
    boltSize: '1/2"',
    boltLength: 57,
    holeDiameter: 15.9,
    pipeOD: 21.3,
  ),
  '3/4"': FlangeDim(
    nominalSize: '3/4"',
    outerDiameter: 98.4,
    boltCircleDiameter: 69.9,
    boltCount: 4,
    boltSize: '1/2"',
    boltLength: 63,
    holeDiameter: 15.9,
    pipeOD: 26.7,
  ),
  '1"': FlangeDim(
    nominalSize: '1"',
    outerDiameter: 108.0,
    boltCircleDiameter: 79.4,
    boltCount: 4,
    boltSize: '1/2"',
    boltLength: 63,
    holeDiameter: 15.9,
    pipeOD: 33.4,
  ),
  '1-1/4"': FlangeDim(
    nominalSize: '1-1/4"',
    outerDiameter: 117.5,
    boltCircleDiameter: 88.9,
    boltCount: 4,
    boltSize: '1/2"',
    boltLength: 70,
    holeDiameter: 15.9,
    pipeOD: 42.2,
  ),
  '1-1/2"': FlangeDim(
    nominalSize: '1-1/2"',
    outerDiameter: 127.0,
    boltCircleDiameter: 98.4,
    boltCount: 4,
    boltSize: '1/2"',
    boltLength: 70,
    holeDiameter: 15.9,
    pipeOD: 48.3,
  ),
  '2"': FlangeDim(
    nominalSize: '2"',
    outerDiameter: 152.4,
    boltCircleDiameter: 120.7,
    boltCount: 4,
    boltSize: '5/8"',
    boltLength: 76,
    holeDiameter: 19.1,
    pipeOD: 60.3,
  ),
  '2-1/2"': FlangeDim(
    nominalSize: '2-1/2"',
    outerDiameter: 177.8,
    boltCircleDiameter: 139.7,
    boltCount: 4,
    boltSize: '5/8"',
    boltLength: 82,
    holeDiameter: 19.1,
    pipeOD: 73.0,
  ),
  '3"': FlangeDim(
    nominalSize: '3"',
    outerDiameter: 190.5,
    boltCircleDiameter: 152.4,
    boltCount: 4,
    boltSize: '5/8"',
    boltLength: 82,
    holeDiameter: 19.1,
    pipeOD: 88.9,
  ),
  '4"': FlangeDim(
    nominalSize: '4"',
    outerDiameter: 228.6,
    boltCircleDiameter: 190.5,
    boltCount: 8,
    boltSize: '5/8"',
    boltLength: 89,
    holeDiameter: 19.1,
    pipeOD: 114.3,
  ),
  '5"': FlangeDim(
    nominalSize: '5"',
    outerDiameter: 254.0,
    boltCircleDiameter: 215.9,
    boltCount: 8,
    boltSize: '3/4"',
    boltLength: 95,
    holeDiameter: 22.2,
    pipeOD: 141.3,
  ),
  '6"': FlangeDim(
    nominalSize: '6"',
    outerDiameter: 279.4,
    boltCircleDiameter: 241.3,
    boltCount: 8,
    boltSize: '3/4"',
    boltLength: 102,
    holeDiameter: 22.2,
    pipeOD: 168.3,
  ),
  '8"': FlangeDim(
    nominalSize: '8"',
    outerDiameter: 342.9,
    boltCircleDiameter: 298.5,
    boltCount: 8,
    boltSize: '3/4"',
    boltLength: 114,
    holeDiameter: 22.2,
    pipeOD: 219.1,
  ),
  '10"': FlangeDim(
    nominalSize: '10"',
    outerDiameter: 406.4,
    boltCircleDiameter: 361.9,
    boltCount: 12,
    boltSize: '7/8"',
    boltLength: 127,
    holeDiameter: 25.4,
    pipeOD: 273.1,
  ),
  '12"': FlangeDim(
    nominalSize: '12"',
    outerDiameter: 482.6,
    boltCircleDiameter: 431.8,
    boltCount: 12,
    boltSize: '7/8"',
    boltLength: 140,
    holeDiameter: 25.4,
    pipeOD: 323.9,
  ),
};

// ============================================================================
// ANSI CLASS 300 FLANGE DATA (B16.5)
// ============================================================================

/// ANSI Class 300 flange dimensions for 1/2" to 12".
const Map<String, FlangeDim> ansi300Flanges = {
  '1/2"': FlangeDim(
    nominalSize: '1/2"',
    outerDiameter: 95.3,
    boltCircleDiameter: 66.7,
    boltCount: 4,
    boltSize: '1/2"',
    boltLength: 63,
    holeDiameter: 15.9,
    pipeOD: 21.3,
  ),
  '3/4"': FlangeDim(
    nominalSize: '3/4"',
    outerDiameter: 117.5,
    boltCircleDiameter: 82.6,
    boltCount: 4,
    boltSize: '5/8"',
    boltLength: 70,
    holeDiameter: 19.1,
    pipeOD: 26.7,
  ),
  '1"': FlangeDim(
    nominalSize: '1"',
    outerDiameter: 123.8,
    boltCircleDiameter: 88.9,
    boltCount: 4,
    boltSize: '5/8"',
    boltLength: 76,
    holeDiameter: 19.1,
    pipeOD: 33.4,
  ),
  '1-1/4"': FlangeDim(
    nominalSize: '1-1/4"',
    outerDiameter: 133.4,
    boltCircleDiameter: 98.4,
    boltCount: 4,
    boltSize: '5/8"',
    boltLength: 82,
    holeDiameter: 19.1,
    pipeOD: 42.2,
  ),
  '1-1/2"': FlangeDim(
    nominalSize: '1-1/2"',
    outerDiameter: 155.6,
    boltCircleDiameter: 114.3,
    boltCount: 4,
    boltSize: '3/4"',
    boltLength: 89,
    holeDiameter: 22.2,
    pipeOD: 48.3,
  ),
  '2"': FlangeDim(
    nominalSize: '2"',
    outerDiameter: 165.1,
    boltCircleDiameter: 127.0,
    boltCount: 8,
    boltSize: '5/8"',
    boltLength: 89,
    holeDiameter: 19.1,
    pipeOD: 60.3,
  ),
  '2-1/2"': FlangeDim(
    nominalSize: '2-1/2"',
    outerDiameter: 190.5,
    boltCircleDiameter: 149.2,
    boltCount: 8,
    boltSize: '3/4"',
    boltLength: 102,
    holeDiameter: 22.2,
    pipeOD: 73.0,
  ),
  '3"': FlangeDim(
    nominalSize: '3"',
    outerDiameter: 209.6,
    boltCircleDiameter: 168.3,
    boltCount: 8,
    boltSize: '3/4"',
    boltLength: 108,
    holeDiameter: 22.2,
    pipeOD: 88.9,
  ),
  '4"': FlangeDim(
    nominalSize: '4"',
    outerDiameter: 254.0,
    boltCircleDiameter: 200.0,
    boltCount: 8,
    boltSize: '3/4"',
    boltLength: 114,
    holeDiameter: 22.2,
    pipeOD: 114.3,
  ),
  '5"': FlangeDim(
    nominalSize: '5"',
    outerDiameter: 279.4,
    boltCircleDiameter: 235.0,
    boltCount: 8,
    boltSize: '3/4"',
    boltLength: 127,
    holeDiameter: 22.2,
    pipeOD: 141.3,
  ),
  '6"': FlangeDim(
    nominalSize: '6"',
    outerDiameter: 317.5,
    boltCircleDiameter: 269.9,
    boltCount: 12,
    boltSize: '3/4"',
    boltLength: 133,
    holeDiameter: 22.2,
    pipeOD: 168.3,
  ),
  '8"': FlangeDim(
    nominalSize: '8"',
    outerDiameter: 381.0,
    boltCircleDiameter: 330.2,
    boltCount: 12,
    boltSize: '7/8"',
    boltLength: 152,
    holeDiameter: 25.4,
    pipeOD: 219.1,
  ),
  '10"': FlangeDim(
    nominalSize: '10"',
    outerDiameter: 444.5,
    boltCircleDiameter: 387.4,
    boltCount: 16,
    boltSize: '1"',
    boltLength: 171,
    holeDiameter: 28.6,
    pipeOD: 273.1,
  ),
  '12"': FlangeDim(
    nominalSize: '12"',
    outerDiameter: 520.7,
    boltCircleDiameter: 450.9,
    boltCount: 16,
    boltSize: '1-1/8"',
    boltLength: 190,
    holeDiameter: 31.8,
    pipeOD: 323.9,
  ),
};

// ============================================================================
// SENSOR FITTINGS & PROBE DATA
// ============================================================================

/// Standard sensor lengths for 12mm glass electrodes.
enum SensorLength {
  mm120('120mm', 120),
  mm225('225mm', 225),
  mm325('325mm', 325),
  mm425('425mm', 425);

  const SensorLength(this.name, this.lengthMm);
  final String name;
  final int lengthMm;
}

/// Fitting types for sensor mounting.
enum FittingType {
  ingoldSocket25('Ingold Socket PG13.5 (25mm)', 25),
  ingoldSocket40('Ingold Socket PG13.5 (40mm)', 40),
  retractableArm('Retractable Arm Assembly', 65),
  npt34Thread('NPT 3/4" Thread Adapter', 20),
  triclamp('Tri-Clamp 1.5" Sanitary', 35);

  const FittingType(this.name, this.deadLengthMm);
  final String name;

  /// Dead length = portion of sensor inside the fitting.
  final int deadLengthMm;
}

/// Pipe inner diameters for common DN sizes.
const Map<String, double> pipeInnerDiameters = {
  'DN25': 25.0,
  'DN32': 32.0,
  'DN40': 38.0,
  'DN50': 50.0,
  'DN65': 65.0,
  'DN80': 80.0,
  'DN100': 100.0,
  'DN125': 125.0,
  'DN150': 150.0,
  'DN200': 200.0,
  'DN250': 250.0,
  'DN300': 300.0,
};

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/// Returns the hex spanner size (A/F) for a given metric bolt size.
/// Based on ISO 4014 / DIN 931 standards.
String getSpannerSize(String boltSize) {
  const Map<String, String> metricSpanners = {
    'M10': '17mm',
    'M12': '19mm',
    'M14': '22mm',
    'M16': '24mm',
    'M18': '27mm',
    'M20': '30mm',
    'M22': '32mm',
    'M24': '36mm',
    'M27': '41mm',
    'M30': '46mm',
  };

  const Map<String, String> imperialSpanners = {
    '1/2"': '3/4"',
    '5/8"': '15/16"',
    '3/4"': '1-1/8"',
    '7/8"': '1-5/16"',
    '1"': '1-1/2"',
    '1-1/8"': '1-11/16"',
    '1-1/4"': '1-7/8"',
  };

  return metricSpanners[boltSize] ??
      imperialSpanners[boltSize] ??
      'Unknown';
}

/// Calculates sensor insertion depth from total length and fitting dead length.
double calculateInsertionDepth(SensorLength sensor, FittingType fitting) {
  return sensor.lengthMm - fitting.deadLengthMm.toDouble();
}

/// Checks if sensor insertion depth is safe for a given pipe diameter.
/// Returns a status tuple: (isGoodFit, warningMessage).
({bool isGoodFit, String? warning}) checkFitSafety({
  required double insertionDepthMm,
  required double pipeInnerDiameterMm,
}) {
  final halfPipeId = pipeInnerDiameterMm / 2;

  if (insertionDepthMm > halfPipeId) {
    return (
      isGoodFit: false,
      warning: 'COLLISION RISK: Insertion exceeds pipe centerline!',
    );
  }

  if (insertionDepthMm < 10) {
    return (
      isGoodFit: false,
      warning: 'POOR FLOW CONTACT: Sensor tip too shallow.',
    );
  }

  // Optimal: 20-70% of pipe radius
  final percentOfRadius = (insertionDepthMm / halfPipeId) * 100;
  if (percentOfRadius < 20) {
    return (
      isGoodFit: true,
      warning: 'Tip in boundary layer zone. Consider longer sensor.',
    );
  }

  return (isGoodFit: true, warning: null);
}

/// Gets flange data by standard and size.
FlangeDim? getFlangeDim({
  required FlangeStandard standard,
  required String pressureClass,
  required String size,
}) {
  switch (standard) {
    case FlangeStandard.din:
      switch (pressureClass) {
        case 'PN10':
          return dinPn10Flanges[size];
        case 'PN16':
          return dinPn16Flanges[size];
        case 'PN40':
          return dinPn40Flanges[size];
      }
    case FlangeStandard.ansi:
      switch (pressureClass) {
        case 'Class 150':
          return ansi150Flanges[size];
        case 'Class 300':
          return ansi300Flanges[size];
      }
  }
  return null;
}

/// Returns available sizes for a given standard.
List<String> getAvailableSizes(FlangeStandard standard) {
  switch (standard) {
    case FlangeStandard.din:
      return dinPn16Flanges.keys.toList();
    case FlangeStandard.ansi:
      return ansi150Flanges.keys.toList();
  }
}

/// Returns available pressure classes for a given standard.
List<String> getPressureClasses(FlangeStandard standard) {
  switch (standard) {
    case FlangeStandard.din:
      return ['PN10', 'PN16', 'PN40'];
    case FlangeStandard.ansi:
      return ['Class 150', 'Class 300'];
  }
}

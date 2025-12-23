import 'package:flutter/material.dart';

/// Represents a chemical substance with its material compatibility data.
///
/// This class is used by the ChemGuard module for chemical-material
/// compatibility checking. Each chemical contains:
/// - Basic identification (name, CAS number, formula, category)
/// - Physical properties (boiling point, flash point)
/// - Material compatibility ratings (A = Excellent to D = Severe Effect)
class Chemical {
  /// Creates a [Chemical] instance.
  const Chemical({
    required this.name,
    required this.casNumber,
    required this.formula,
    required this.category,
    required this.properties,
    required this.materials,
  });

  /// Creates a [Chemical] from a JSON map.
  ///
  /// Handles null values gracefully by providing defaults.
  factory Chemical.fromJson(Map<String, dynamic> json) {
    return Chemical(
      name: json['name'] as String? ?? 'Unknown',
      casNumber: json['cas_number'] as String? ?? 'N/A',
      formula: json['formula'] as String? ?? 'N/A',
      category: json['category'] as String? ?? 'Unknown',
      properties: (json['properties'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value?.toString() ?? 'N/A')) ??
          const {},
      materials: (json['materials'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value?.toString() ?? 'N/A')) ??
          const {},
    );
  }

  /// Chemical name (e.g., "Acetone", "Hydrochloric Acid (37%)").
  final String name;

  /// CAS Registry Number for identification.
  final String casNumber;

  /// Chemical formula (e.g., "C3H6O", "HCl").
  final String formula;

  /// Chemical category (e.g., "Ketone", "Inorganic Acid").
  final String category;

  /// Physical properties map (boiling_point, flash_point).
  final Map<String, String> properties;

  /// Material compatibility ratings map (material name -> rating A/B/C/D).
  final Map<String, String> materials;

  /// Returns the compatibility color for a given rating.
  ///
  /// - 'A' = Green (Excellent - No Effect)
  /// - 'B' = Yellow (Good - Minor Effect)
  /// - 'C' = Orange (Fair - Moderate Effect)
  /// - 'D' = Red (Not Recommended - Severe Effect)
  static Color getMaterialColor(String? rating) {
    switch (rating?.toUpperCase()) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.yellow.shade700;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Returns the rating description for UI display.
  static String getRatingDescription(String? rating) {
    switch (rating?.toUpperCase()) {
      case 'A':
        return 'Excellent - No Effect';
      case 'B':
        return 'Good - Minor Effect';
      case 'C':
        return 'Fair - Moderate Effect';
      case 'D':
        return 'Not Recommended - Severe Effect';
      default:
        return 'Unknown';
    }
  }

  /// Returns the boiling point from properties, or 'N/A' if not available.
  String get boilingPoint => properties['boiling_point'] ?? 'N/A';

  /// Returns the flash point from properties, or 'N/A' if not available.
  String get flashPoint => properties['flash_point'] ?? 'N/A';

  /// Returns the compatibility rating for a specific material.
  String? getRating(String material) => materials[material];

  /// Converts this [Chemical] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cas_number': casNumber,
      'formula': formula,
      'category': category,
      'properties': properties,
      'materials': materials,
    };
  }

  @override
  String toString() => 'Chemical($name, CAS: $casNumber)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chemical &&
          runtimeType == other.runtimeType &&
          casNumber == other.casNumber;

  @override
  int get hashCode => casNumber.hashCode;
}

/// List of all available material names for compatibility checking.
const List<String> kAvailableMaterials = [
  'SS316',
  'SS304',
  'Aluminum',
  'Carbon Steel',
  'PVC',
  'PP',
  'PTFE',
  'PVDF',
  'Viton',
  'EPDM',
  'Buna-N',
  'Neoprene',
];

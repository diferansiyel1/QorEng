import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/features/chemical/domain/entities/chemical.dart';

/// Path to the chemical data JSON asset.
const String _kChemicalDataPath = 'assets/images/data/chemical_data.json';

/// Repository for loading and querying chemical data.
///
/// Provides methods to load chemicals from the bundled JSON asset
/// and search through them by name, CAS number, or formula.
class ChemRepository {
  /// Cache of loaded chemicals to avoid repeated file reads.
  List<Chemical>? _cachedChemicals;

  /// Loads all chemicals from the bundled JSON asset.
  ///
  /// Uses caching to avoid repeated file reads. The data is loaded
  /// once and stored in memory for subsequent calls.
  ///
  /// Returns an empty list if loading fails, logging the error.
  Future<List<Chemical>> loadChemicals() async {
    if (_cachedChemicals != null) {
      return _cachedChemicals!;
    }

    try {
      final jsonString = await rootBundle.loadString(_kChemicalDataPath);
      final jsonList = json.decode(jsonString) as List<dynamic>;

      _cachedChemicals = jsonList
          .map((item) => Chemical.fromJson(item as Map<String, dynamic>))
          .toList();

      developer.log(
        'Loaded ${_cachedChemicals!.length} chemicals from asset',
        name: 'ChemRepository',
      );

      return _cachedChemicals!;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load chemical data',
        name: 'ChemRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return [];
    }
  }

  /// Searches chemicals by name, CAS number, or formula.
  ///
  /// The search is case-insensitive and matches partial strings.
  /// An empty query returns all chemicals.
  Future<List<Chemical>> searchChemicals(String query) async {
    final chemicals = await loadChemicals();

    if (query.isEmpty) {
      return chemicals;
    }

    final lowerQuery = query.toLowerCase();

    return chemicals.where((chemical) {
      return chemical.name.toLowerCase().contains(lowerQuery) ||
          chemical.casNumber.toLowerCase().contains(lowerQuery) ||
          chemical.formula.toLowerCase().contains(lowerQuery) ||
          chemical.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Returns a chemical by its exact name.
  ///
  /// Returns null if not found.
  Future<Chemical?> getChemicalByName(String name) async {
    final chemicals = await loadChemicals();
    try {
      return chemicals.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Clears the cached chemicals, forcing a reload on next access.
  void clearCache() {
    _cachedChemicals = null;
  }
}

/// Provider for the [ChemRepository] instance.
///
/// This is a singleton that can be used throughout the app.
final chemRepositoryProvider = Provider<ChemRepository>((ref) {
  return ChemRepository();
});

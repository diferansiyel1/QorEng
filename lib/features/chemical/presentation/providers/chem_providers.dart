import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/features/chemical/data/chem_repository.dart';
import 'package:engicore/features/chemical/domain/entities/chemical.dart';

/// Provider for loading all chemicals from the data source.
///
/// This is a [FutureProvider] that loads chemicals asynchronously
/// from the bundled JSON asset via [ChemRepository].
final allChemicalsProvider = FutureProvider<List<Chemical>>((ref) async {
  final repository = ref.watch(chemRepositoryProvider);
  return repository.loadChemicals();
});

/// Notifier for the currently selected chemical in the compatibility checker.
class SelectedChemicalNotifier extends Notifier<Chemical?> {
  @override
  Chemical? build() => null;

  void select(Chemical? chemical) {
    state = chemical;
  }

  void clear() {
    state = null;
  }
}

/// Provider for the currently selected chemical in the compatibility checker.
///
/// Used by [CompatibilityCheckScreen] and [MaterialFinderScreen].
final selectedChemicalProvider =
    NotifierProvider<SelectedChemicalNotifier, Chemical?>(
  SelectedChemicalNotifier.new,
);

/// Notifier for the currently selected material in the compatibility checker.
class SelectedMaterialNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? material) {
    state = material;
  }

  void clear() {
    state = null;
  }
}

/// Provider for the currently selected material in the compatibility checker.
///
/// Used by [CompatibilityCheckScreen] to determine compatibility rating.
final selectedMaterialProvider =
    NotifierProvider<SelectedMaterialNotifier, String?>(
  SelectedMaterialNotifier.new,
);

/// Notifier for chemical search query.
class ChemicalSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Provider for chemical search query.
///
/// Used by UI components to filter the chemical list.
final chemicalSearchQueryProvider =
    NotifierProvider<ChemicalSearchQueryNotifier, String>(
  ChemicalSearchQueryNotifier.new,
);

/// Provider for filtered chemicals based on search query.
///
/// Filters [allChemicalsProvider] results based on [chemicalSearchQueryProvider].
final filteredChemicalsProvider = FutureProvider<List<Chemical>>((ref) async {
  final allChemicals = await ref.watch(allChemicalsProvider.future);
  final String query = ref.watch(chemicalSearchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return allChemicals;
  }

  return allChemicals.where((Chemical chemical) {
    return chemical.name.toLowerCase().contains(query) ||
        chemical.casNumber.toLowerCase().contains(query) ||
        chemical.formula.toLowerCase().contains(query);
  }).toList();
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/chemical/domain/entities/chemical.dart';
import 'package:engicore/features/chemical/presentation/providers/chem_providers.dart';

/// Screen for finding compatible materials for a specific chemical.
///
/// This is the "reverse lookup" feature - select a chemical and see
/// all materials grouped by compatibility rating.
class MaterialFinderScreen extends ConsumerWidget {
  const MaterialFinderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chemicalsAsync = ref.watch(allChemicalsProvider);
    final selectedChemical = ref.watch(selectedChemicalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Finder'),
        centerTitle: true,
      ),
      body: chemicalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Failed to load chemicals: $error'),
        ),
        data: (chemicals) => Column(
          children: [
            // Chemical Selection
            Padding(
              padding: const EdgeInsets.all(Dimens.spacingMd),
              child: Card(
                elevation: Dimens.elevationMd,
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.science, color: AppColors.chemicalAccent),
                          const SizedBox(width: Dimens.spacingSm),
                          Text(
                            'Select Chemical',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimens.spacingMd),
                      DropdownButtonFormField<Chemical>(
                        value: selectedChemical,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          hintText: 'Choose a chemical...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: Dimens.spacingMd,
                            vertical: Dimens.spacingSm,
                          ),
                        ),
                        items: chemicals.map((chemical) {
                          return DropdownMenuItem<Chemical>(
                            value: chemical,
                            child: Text(
                              chemical.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (chemical) {
                          ref.read(selectedChemicalProvider.notifier).select(chemical);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Material Groups
            if (selectedChemical != null)
              Expanded(
                child: _MaterialGroupsList(chemical: selectedChemical),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.science,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: Dimens.spacingMd),
                      Text(
                        'Select a chemical to see compatible materials',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Displays materials grouped by compatibility rating.
class _MaterialGroupsList extends StatelessWidget {
  const _MaterialGroupsList({required this.chemical});

  final Chemical chemical;

  @override
  Widget build(BuildContext context) {
    // Group materials by rating
    final groupedMaterials = <String, List<String>>{
      'A': [],
      'B': [],
      'C': [],
      'D': [],
    };

    for (final material in kAvailableMaterials) {
      final rating = chemical.getRating(material)?.toUpperCase() ?? 'Unknown';
      if (groupedMaterials.containsKey(rating)) {
        groupedMaterials[rating]!.add(material);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingMd),
      children: [
        // Recommended (A)
        if (groupedMaterials['A']!.isNotEmpty)
          _RatingGroup(
            title: 'Recommended',
            subtitle: 'Excellent - No Effect',
            rating: 'A',
            color: Colors.green,
            icon: Icons.check_circle,
            materials: groupedMaterials['A']!,
          ),

        // Use with Caution (B/C)
        if (groupedMaterials['B']!.isNotEmpty || groupedMaterials['C']!.isNotEmpty)
          _RatingGroup(
            title: 'Use with Caution',
            subtitle: 'Minor to Moderate Effect',
            rating: 'B/C',
            color: Colors.orange,
            icon: Icons.warning_amber,
            materials: [...groupedMaterials['B']!, ...groupedMaterials['C']!],
            showRatingBadges: true,
            ratingMap: {
              for (final m in groupedMaterials['B']!) m: 'B',
              for (final m in groupedMaterials['C']!) m: 'C',
            },
          ),

        // Avoid (D)
        if (groupedMaterials['D']!.isNotEmpty)
          _RatingGroup(
            title: 'Avoid',
            subtitle: 'Not Recommended - Severe Effect',
            rating: 'D',
            color: Colors.red,
            icon: Icons.dangerous,
            materials: groupedMaterials['D']!,
          ),

        const SizedBox(height: Dimens.spacingMd),
      ],
    );
  }
}

/// A group of materials with the same rating category.
class _RatingGroup extends StatelessWidget {
  const _RatingGroup({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.color,
    required this.icon,
    required this.materials,
    this.showRatingBadges = false,
    this.ratingMap,
  });

  final String title;
  final String subtitle;
  final String rating;
  final Color color;
  final IconData icon;
  final List<String> materials;
  final bool showRatingBadges;
  final Map<String, String>? ratingMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimens.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Dimens.radiusMd),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: Dimens.iconLg),
                const SizedBox(width: Dimens.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.spacingMd,
                    vertical: Dimens.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(Dimens.radiusSm),
                  ),
                  child: Text(
                    '${materials.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Materials List
          Padding(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            child: Wrap(
              spacing: Dimens.spacingSm,
              runSpacing: Dimens.spacingSm,
              children: materials.map((material) {
                final materialRating = ratingMap?[material];
                return Chip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(material),
                      if (showRatingBadges && materialRating != null) ...[
                        const SizedBox(width: Dimens.spacingXs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Chemical.getMaterialColor(materialRating),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            materialRating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  backgroundColor: isDark
                      ? Colors.grey.shade800
                      : Colors.white,
                  side: BorderSide(
                    color: color.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

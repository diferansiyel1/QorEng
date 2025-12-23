import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/chemical/domain/entities/chemical.dart';
import 'package:engicore/features/chemical/presentation/providers/chem_providers.dart';

/// Screen for checking chemical-material compatibility.
///
/// Users select a chemical and a material, then see a color-coded
/// compatibility rating (A/B/C/D) with safety information.
class CompatibilityCheckScreen extends ConsumerStatefulWidget {
  const CompatibilityCheckScreen({super.key});

  @override
  ConsumerState<CompatibilityCheckScreen> createState() =>
      _CompatibilityCheckScreenState();
}

class _CompatibilityCheckScreenState
    extends ConsumerState<CompatibilityCheckScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chemicalsAsync = ref.watch(allChemicalsProvider);
    final selectedChemical = ref.watch(selectedChemicalProvider);
    final selectedMaterial = ref.watch(selectedMaterialProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChemGuard'),
        centerTitle: true,
      ),
      body: chemicalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Failed to load chemicals: $error'),
        ),
        data: (chemicals) => SingleChildScrollView(
          padding: const EdgeInsets.all(Dimens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chemical Selection Card
              _SelectionCard(
                title: 'Select Chemical',
                icon: Icons.science,
                child: _ChemicalDropdown(
                  chemicals: chemicals,
                  selectedChemical: selectedChemical,
                  onChanged: (chemical) {
                    ref.read(selectedChemicalProvider.notifier).select(chemical);
                  },
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Material Selection Card
              _SelectionCard(
                title: 'Select Material',
                icon: Icons.construction,
                child: _MaterialDropdown(
                  selectedMaterial: selectedMaterial,
                  onChanged: (material) {
                    ref.read(selectedMaterialProvider.notifier).select(material);
                  },
                ),
              ),
              const SizedBox(height: Dimens.spacingLg),

              // Result Card
              if (selectedChemical != null && selectedMaterial != null)
                _buildResultCard(
                  context,
                  selectedChemical,
                  selectedMaterial,
                  isDark,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    Chemical chemical,
    String material,
    bool isDark,
  ) {
    final rating = chemical.getRating(material);
    final color = Chemical.getMaterialColor(rating);
    final description = Chemical.getRatingDescription(rating);

    // Trigger shake animation for 'D' rating
    if (rating?.toUpperCase() == 'D') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerShake();
      });
    }

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset = math.sin(_shakeAnimation.value * math.pi * 4) * 8;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: Card(
        elevation: Dimens.elevationLg,
        color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        child: Padding(
          padding: const EdgeInsets.all(Dimens.spacingLg),
          child: Column(
            children: [
              // Rating Badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    rating ?? '?',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Rating Description
              Text(
                description,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Chemical Info
              _InfoRow(
                label: 'Chemical',
                value: chemical.name,
              ),
              _InfoRow(
                label: 'Material',
                value: material,
              ),
              const Divider(height: Dimens.spacingLg),

              // Properties Section
              Text(
                'Physical Properties',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: Dimens.spacingSm),
              _InfoRow(
                label: 'Boiling Point',
                value: chemical.boilingPoint,
                icon: Icons.thermostat,
              ),
              _InfoRow(
                label: 'Flash Point',
                value: chemical.flashPoint,
                icon: Icons.local_fire_department,
              ),
              _InfoRow(
                label: 'Category',
                value: chemical.category,
                icon: Icons.category,
              ),
              _InfoRow(
                label: 'CAS Number',
                value: chemical.casNumber,
                icon: Icons.numbers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selection card with title, icon, and child widget.
class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: Dimens.elevationMd,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.chemicalAccent),
                const SizedBox(width: Dimens.spacingSm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Dimens.spacingMd),
            child,
          ],
        ),
      ),
    );
  }
}

/// Dropdown for selecting a chemical with search functionality.
class _ChemicalDropdown extends StatelessWidget {
  const _ChemicalDropdown({
    required this.chemicals,
    required this.selectedChemical,
    required this.onChanged,
  });

  final List<Chemical> chemicals;
  final Chemical? selectedChemical;
  final ValueChanged<Chemical?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Chemical>(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chemical.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${chemical.formula} • CAS: ${chemical.casNumber}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      selectedItemBuilder: (context) {
        return chemicals.map((chemical) {
          return Text(
            chemical.name,
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
    );
  }
}

/// Dropdown for selecting a material.
class _MaterialDropdown extends StatelessWidget {
  const _MaterialDropdown({
    required this.selectedMaterial,
    required this.onChanged,
  });

  final String? selectedMaterial;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedMaterial,
      isExpanded: true,
      decoration: const InputDecoration(
        hintText: 'Choose a material...',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Dimens.spacingMd,
          vertical: Dimens.spacingSm,
        ),
      ),
      items: kAvailableMaterials.map((material) {
        return DropdownMenuItem<String>(
          value: material,
          child: Text(material),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

/// Information row with optional icon.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.spacingXs),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: Dimens.iconSm,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: Dimens.spacingSm),
          ],
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

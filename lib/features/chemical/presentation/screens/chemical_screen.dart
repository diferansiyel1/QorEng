import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/chemical/domain/entities/chemical_calculation.dart';

/// Main screen for Chemical engineering calculations.
///
/// Uses tabs to separate General, Spectroscopy, and Electrochem calculators.
class ChemicalScreen extends StatelessWidget {
  const ChemicalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chemical'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.chemicalAccent,
            labelColor: AppColors.chemicalAccent,
            tabs: [
              Tab(
                icon: Icon(Icons.science),
                text: 'General',
              ),
              Tab(
                icon: Icon(Icons.lightbulb),
                text: 'Spectroscopy',
              ),
              Tab(
                icon: Icon(Icons.monitor_heart),
                text: 'Electrochem',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GeneralTab(),
            _SpectroscopyTab(),
            _ElectrochemTab(),
          ],
        ),
      ),
    );
  }
}

/// Tab 1: General chemistry calculations.
class _GeneralTab extends StatelessWidget {
  const _GeneralTab();

  @override
  Widget build(BuildContext context) {
    const calculations = GeneralChemistryCalculations.all;

    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      itemCount: calculations.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: Dimens.spacingSm),
      itemBuilder: (context, index) {
        return _CalculationCard(
          calculation: calculations[index],
          accentColor: AppColors.chemicalAccent,
        );
      },
    );
  }
}

/// Tab 2: Spectroscopy calculations.
class _SpectroscopyTab extends StatelessWidget {
  const _SpectroscopyTab();

  @override
  Widget build(BuildContext context) {
    const calculations = SpectroscopyCalculations.all;

    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      itemCount: calculations.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: Dimens.spacingSm),
      itemBuilder: (context, index) {
        return _CalculationCard(
          calculation: calculations[index],
          accentColor: AppColors.warning, // Orange/yellow for light-based
        );
      },
    );
  }
}

/// Tab 3: Electrochemistry & Kinetics calculations.
class _ElectrochemTab extends StatelessWidget {
  const _ElectrochemTab();

  @override
  Widget build(BuildContext context) {
    const calculations = ElectrochemCalculations.all;

    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      itemCount: calculations.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: Dimens.spacingSm),
      itemBuilder: (context, index) {
        return _CalculationCard(
          calculation: calculations[index],
          accentColor: AppColors.info, // Blue for electrochemistry
        );
      },
    );
  }
}

/// Card widget for displaying a calculation entry.
class _CalculationCard extends StatelessWidget {
  const _CalculationCard({
    required this.calculation,
    required this.accentColor,
  });

  final ChemicalCalculation calculation;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: Dimens.elevationMd,
      child: InkWell(
        onTap: () => context.push(calculation.route),
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(Dimens.spacingMd),
          child: Row(
            children: [
              // Icon
              Container(
                width: Dimens.touchTargetMin,
                height: Dimens.touchTargetMin,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: Icon(
                  calculation.icon,
                  color: accentColor,
                  size: Dimens.iconLg,
                ),
              ),
              const SizedBox(width: Dimens.spacingMd),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      calculation.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Dimens.spacingXs),
                    Text(
                      calculation.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    if (calculation.formula != null) ...[
                      const SizedBox(height: Dimens.spacingXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimens.spacingSm,
                          vertical: Dimens.spacingXs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimens.radiusSm),
                        ),
                        child: Text(
                          calculation.formula!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

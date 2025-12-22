import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/localization/localization_service.dart';
import 'package:engicore/features/mechanical/domain/entities/mechanical_calculation.dart';

/// Main screen for Mechanical engineering calculations.
///
/// Uses tabs to separate Solids/Hydraulics and Fluid/Flow calculators.
class MechanicalScreen extends ConsumerWidget {
  const MechanicalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final locale = ref.watch(localeProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.mechanical),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.mechanicalAccent,
            labelColor: AppColors.mechanicalAccent,
            tabs: [
              Tab(
                icon: const Icon(Icons.construction),
                text: strings.solidsHydraulics,
              ),
              Tab(
                icon: const Icon(Icons.water_drop),
                text: strings.fluidFlow,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SolidsHydraulicsTab(),
            _FluidFlowTab(),
          ],
        ),
      ),
    );
  }
}

/// Tab 1: Solids & Hydraulics calculators.
class _SolidsHydraulicsTab extends StatelessWidget {
  const _SolidsHydraulicsTab();

  @override
  Widget build(BuildContext context) {
    const calculations = SolidsHydraulicsCalculations.all;

    if (calculations.isEmpty) {
      return const _EmptyTabView(
        icon: Icons.construction,
        message: 'Solids & Hydraulics calculators coming soon',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      itemCount: calculations.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: Dimens.spacingSm),
      itemBuilder: (context, index) {
        return _CalculationCard(
          calculation: calculations[index],
          accentColor: AppColors.mechanicalAccent,
        );
      },
    );
  }
}

/// Tab 2: Fluid & Flow calculators.
class _FluidFlowTab extends StatelessWidget {
  const _FluidFlowTab();

  @override
  Widget build(BuildContext context) {
    const calculations = FluidFlowCalculations.all;

    if (calculations.isEmpty) {
      return const _EmptyTabView(
        icon: Icons.water_drop,
        message: 'Fluid & Flow calculators coming soon',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      itemCount: calculations.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: Dimens.spacingSm),
      itemBuilder: (context, index) {
        return _CalculationCard(
          calculation: calculations[index],
          accentColor: AppColors.info, // Blue for flow
        );
      },
    );
  }
}

/// Empty tab placeholder.
class _EmptyTabView extends StatelessWidget {
  const _EmptyTabView({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: Dimens.iconXl * 2,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: Dimens.spacingMd),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Card widget for displaying a calculation entry.
class _CalculationCard extends StatelessWidget {
  const _CalculationCard({
    required this.calculation,
    required this.accentColor,
  });

  final MechanicalCalculation calculation;
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

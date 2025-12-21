import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/localization/localization_service.dart';
import 'package:engicore/features/bioprocess/domain/entities/bioprocess_calculation.dart';

/// Main screen for Bioprocess engineering calculations.
///
/// Displays a list of available bioprocess calculators.
class BioprocessScreen extends ConsumerWidget {
  const BioprocessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.bioprocess),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(Dimens.spacingMd),
        itemCount: BioprocessCalculations.all.length,
        separatorBuilder: (context, index) => const SizedBox(height: Dimens.spacingSm),
        itemBuilder: (context, index) {
          final calc = BioprocessCalculations.all[index];
          return _CalculationCard(calculation: calc);
        },
      ),
    );
  }
}

/// Card widget for displaying a bioprocess calculation entry.
class _CalculationCard extends StatelessWidget {
  const _CalculationCard({required this.calculation});

  final BioprocessCalculation calculation;

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
                  color: AppColors.bioprocessAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: Icon(
                  calculation.icon,
                  color: AppColors.bioprocessAccent,
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
                          color: AppColors.bioprocessAccent.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(Dimens.radiusSm),
                        ),
                        child: Text(
                          calculation.formula!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: AppColors.bioprocessAccent,
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

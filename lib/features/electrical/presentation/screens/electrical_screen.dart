import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/electrical/domain/entities/electrical_calculation.dart';

/// Electrical calculations list screen.
///
/// Displays available electrical engineering calculations
/// with navigation to individual calculator screens.
class ElectricalScreen extends StatelessWidget {
  const ElectricalScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Electrical'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(Dimens.spacingMd),
        itemCount: ElectricalCalculations.all.length,
        itemBuilder: (context, index) {
          final calculation = ElectricalCalculations.all[index];
          return _CalculationCard(calculation: calculation);
        },
      ),
    );
  }
}

class _CalculationCard extends StatelessWidget {
  const _CalculationCard({required this.calculation});

  final ElectricalCalculation calculation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.spacingMd),
      child: Material(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        child: InkWell(
          onTap: () => context.push(calculation.route),
          borderRadius: BorderRadius.circular(Dimens.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            child: Row(
              children: [
                Container(
                  width: Dimens.touchTargetLg,
                  height: Dimens.touchTargetLg,
                  decoration: BoxDecoration(
                    color: AppColors.electricalAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Dimens.radiusMd),
                  ),
                  child: Icon(
                    calculation.icon,
                    color: AppColors.electricalAccent,
                    size: Dimens.iconLg,
                  ),
                ),
                const SizedBox(width: Dimens.spacingMd),
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
                      const SizedBox(height: Dimens.spacingXxs),
                      Text(
                        calculation.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (calculation.formula != null) ...[
                        const SizedBox(height: Dimens.spacingSm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimens.spacingSm,
                            vertical: Dimens.spacingXxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.electricalAccent.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimens.radiusSm,
                            ),
                          ),
                          child: Text(
                            calculation.formula!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.electricalAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
      ),
    );
  }
}

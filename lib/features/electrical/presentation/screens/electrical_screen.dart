import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/localization/localization_service.dart';
import 'package:engicore/features/electrical/domain/entities/electrical_calculation.dart';

/// Main screen for Electrical engineering calculations.
///
/// Uses tabs to separate Power/Cables and Automation/Control calculators.
class ElectricalScreen extends ConsumerWidget {
  const ElectricalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final locale = ref.watch(localeProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.electrical),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.electricalAccent,
            labelColor: AppColors.electricalAccent,
            tabs: [
              Tab(
                icon: const Icon(Icons.bolt),
                text: strings.powerCables,
              ),
              Tab(
                icon: const Icon(Icons.memory),
                text: strings.automationTab,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PowerCablesTab(),
            _AutomationControlTab(),
          ],
        ),
      ),
    );
  }
}

/// Tab 1: Power & Cables calculators.
class _PowerCablesTab extends StatelessWidget {
  const _PowerCablesTab();

  @override
  Widget build(BuildContext context) {
    const calculations = PowerCablesCalculations.all;

    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      itemCount: calculations.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: Dimens.spacingSm),
      itemBuilder: (context, index) {
        return _CalculationCard(
          calculation: calculations[index],
          accentColor: AppColors.electricalAccent,
        );
      },
    );
  }
}

/// Tab 2: Automation & Control calculators.
class _AutomationControlTab extends StatelessWidget {
  const _AutomationControlTab();

  @override
  Widget build(BuildContext context) {
    const calculations = AutomationControlCalculations.all;

    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      itemCount: calculations.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: Dimens.spacingSm),
      itemBuilder: (context, index) {
        return _CalculationCard(
          calculation: calculations[index],
          accentColor: AppColors.accent, // Use main accent for automation
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

  final ElectricalCalculation calculation;
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

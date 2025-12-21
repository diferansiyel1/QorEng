import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/bioprocess/domain/usecases/tip_speed_provider.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';

/// Impeller Tip Speed Calculator screen.
///
/// Calculates tip speed and provides visual safety assessment
/// for cell culture applications.
class TipSpeedScreen extends ConsumerStatefulWidget {
  const TipSpeedScreen({super.key});

  @override
  ConsumerState<TipSpeedScreen> createState() => _TipSpeedScreenState();
}

class _TipSpeedScreenState extends ConsumerState<TipSpeedScreen> {
  final _diameterController = TextEditingController();
  final _rpmController = TextEditingController();

  @override
  void dispose() {
    _diameterController.dispose();
    _rpmController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final diameter = double.tryParse(_diameterController.text) ?? 0;
    final rpm = double.tryParse(_rpmController.text) ?? 0;

    final notifier = ref.read(tipSpeedCalculatorProvider.notifier);
    notifier.updateDiameter(diameter);
    notifier.updateRpm(rpm);
  }

  void _clear() {
    _diameterController.clear();
    _rpmController.clear();
    ref.read(tipSpeedCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(tipSpeedResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'Tip Speed: ${result.tipSpeed.toStringAsFixed(2)} m/s',
        resultValue: result.status.label,
        moduleType: ModuleType.bioprocess,
      );
      ref.read(historyRecordsProvider.notifier).addRecord(record);
    }
  }

  void _calculateAndSave() {
    _updateCalculation();
    Future.microtask(_saveToHistory);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final input = ref.watch(tipSpeedCalculatorProvider);
    final result = ref.watch(tipSpeedResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impeller Tip Speed'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Description
              Container(
                padding: const EdgeInsets.all(Dimens.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.bioprocessAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.bioprocessAccent,
                      size: Dimens.iconMd,
                    ),
                    const SizedBox(width: Dimens.spacingSm),
                    Expanded(
                      child: Text(
                        'Calculate impeller tip speed to assess shear stress on cells.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Inputs Section
              Text(
                'Inputs',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Diameter Input with Unit Selector
              _DiameterInput(
                controller: _diameterController,
                selectedUnit: input.diameterUnit,
                onUnitChanged: (unit) {
                  ref
                      .read(tipSpeedCalculatorProvider.notifier)
                      .updateDiameterUnit(unit);
                },
                onChanged: (_) => _updateCalculation(),
              ),

              const SizedBox(height: Dimens.spacingMd),

              // RPM Input
              EngineeringInputField<String>(
                label: 'Agitation Speed (N)',
                controller: _rpmController,
                hint: 'Enter RPM',
                suffixText: 'RPM',
                onChanged: (_) => _updateCalculation(),
              ),

              const SizedBox(height: Dimens.spacingMd),

              // Action Buttons
              AppButton(
                label: 'Calculate',
                icon: Icons.calculate,
                onPressed: _calculateAndSave,
              ),
              const SizedBox(height: Dimens.spacingSm),
              AppButton(
                label: 'Clear',
                icon: Icons.refresh,
                onPressed: _clear,
                variant: AppButtonVariant.secondary,
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Results Section
              Text(
                'Results',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Animated Result Card
              if (result != null)
                _AnimatedResultCard(result: result)
              else
                const _EmptyResultCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diameter input with unit selector dropdown.
class _DiameterInput extends StatelessWidget {
  const _DiameterInput({
    required this.controller,
    required this.selectedUnit,
    required this.onUnitChanged,
    required this.onChanged,
  });

  final TextEditingController controller;
  final DiameterUnit selectedUnit;
  final ValueChanged<DiameterUnit> onUnitChanged;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impeller Diameter (D)',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Dimens.spacingXs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: onChanged,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter diameter',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Dimens.spacingMd,
                    vertical: Dimens.spacingMd,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimens.spacingSm),
            Expanded(
              flex: 2,
              child: Container(
                height: Dimens.inputHeightSm,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                  border: Border.all(
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                        : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: Dimens.spacingMd),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DiameterUnit>(
                    value: selectedUnit,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                    dropdownColor:
                        isDark ? AppColors.cardDark : AppColors.cardLight,
                    items: DiameterUnit.values.map((unit) {
                      return DropdownMenuItem<DiameterUnit>(
                        value: unit,
                        child: Text(unit.symbol),
                      );
                    }).toList(),
                    onChanged: (unit) {
                      if (unit != null) onUnitChanged(unit);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated result card with color transition based on status.
class _AnimatedResultCard extends StatelessWidget {
  const _AnimatedResultCard({required this.result});

  final TipSpeedResult result;

  Color get _statusColor {
    return switch (result.status) {
      TipSpeedStatus.safe => AppColors.success,
      TipSpeedStatus.caution => AppColors.warning,
      TipSpeedStatus.highShear => AppColors.error,
    };
  }

  IconData get _statusIcon {
    return switch (result.status) {
      TipSpeedStatus.safe => Icons.check_circle,
      TipSpeedStatus.caution => Icons.warning_amber,
      TipSpeedStatus.highShear => Icons.dangerous,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(Dimens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _statusColor.withValues(alpha: 0.3),
            _statusColor.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        border: Border.all(
          color: _statusColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Icon with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon,
              size: 40,
              color: _statusColor,
            ),
          ),
          const SizedBox(height: Dimens.spacingMd),

          // Tip Speed Value
          Text(
            '${result.tipSpeed.toStringAsFixed(2)} m/s',
            style: theme.textTheme.displaySmall?.copyWith(
              color: _statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Dimens.spacingSm),

          // Status Label
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacingMd,
              vertical: Dimens.spacingXs,
            ),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimens.radiusFull),
            ),
            child: Text(
              result.status.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: _statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: Dimens.spacingMd),

          // Status Message
          Text(
            result.status.message,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimens.spacingMd),

          // Formula
          Container(
            padding: const EdgeInsets.all(Dimens.spacingSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(Dimens.radiusSm),
            ),
            child: Text(
              result.formula,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty result placeholder card.
class _EmptyResultCard extends StatelessWidget {
  const _EmptyResultCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingXl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
              : AppColors.textSecondaryLight.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.settings_suggest,
            size: 48,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: Dimens.spacingMd),
          Text(
            'Enter diameter and RPM to calculate tip speed',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
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

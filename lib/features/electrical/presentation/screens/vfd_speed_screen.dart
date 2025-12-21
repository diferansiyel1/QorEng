import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/electrical/domain/usecases/vfd_speed_logic.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// VFD Motor Speed Calculator screen.
class VfdSpeedScreen extends ConsumerStatefulWidget {
  const VfdSpeedScreen({super.key});

  @override
  ConsumerState<VfdSpeedScreen> createState() => _VfdSpeedScreenState();
}

class _VfdSpeedScreenState extends ConsumerState<VfdSpeedScreen> {
  final _frequencyController = TextEditingController(text: '50');
  final _slipController = TextEditingController(text: '3');

  @override
  void dispose() {
    _frequencyController.dispose();
    _slipController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final frequency = double.tryParse(_frequencyController.text) ?? 0;
    final slip = double.tryParse(_slipController.text) ?? 0;

    final notifier = ref.read(vfdSpeedCalculatorProvider.notifier);
    notifier.updateFrequency(frequency);
    notifier.updateSlipPercent(slip);
  }

  void _clear() {
    _frequencyController.text = '50';
    _slipController.text = '3';
    ref.read(vfdSpeedCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(vfdSpeedResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'VFD Speed: ${result.actualSpeed.toStringAsFixed(0)} RPM',
        resultValue: 'Sync: ${result.synchronousSpeed.toStringAsFixed(0)} RPM',
        moduleType: ModuleType.electrical,
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
    final input = ref.watch(vfdSpeedCalculatorProvider);
    final result = ref.watch(vfdSpeedResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VFD Motor Speed'),
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
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.accent,
                      size: Dimens.iconMd,
                    ),
                    const SizedBox(width: Dimens.spacingSm),
                    Expanded(
                      child: Text(
                        'Calculate motor speed from VFD frequency and pole configuration.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Inputs
              Text(
                'Inputs',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Drive Frequency',
                controller: _frequencyController,
                hint: 'Enter frequency',
                suffixText: 'Hz',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Pole Configuration Dropdown
              _PolesSelector(
                selectedPoles: input.poles,
                onChanged: (poles) {
                  ref.read(vfdSpeedCalculatorProvider.notifier).updatePoles(poles);
                  _updateCalculation();
                },
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Slip',
                controller: _slipController,
                hint: 'Typical: 2-5%',
                suffixText: '%',
                onChanged: (_) => _updateCalculation(),
              ),

              const SizedBox(height: Dimens.spacingMd),

              // Actions
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

              // Results
              Text(
                'Results',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              if (result != null) ...[
                ResultCard(
                  label: 'Synchronous Speed',
                  value: result.synchronousSpeed,
                  unit: 'RPM',
                  formula: result.formula,
                  accentColor: AppColors.info,
                ),
                const SizedBox(height: Dimens.spacingMd),
                ResultCard(
                  label: 'Actual Motor Speed',
                  value: result.actualSpeed,
                  unit: 'RPM',
                  accentColor: AppColors.accent,
                ),
                const SizedBox(height: Dimens.spacingMd),
                ResultCard(
                  label: 'Speed Loss (Slip)',
                  value: result.slipSpeed,
                  unit: 'RPM',
                  accentColor: AppColors.warning,
                ),
              ] else
                Center(
                  child: Text(
                    'Enter frequency and poles to calculate speed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Motor poles dropdown selector.
class _PolesSelector extends StatelessWidget {
  const _PolesSelector({
    required this.selectedPoles,
    required this.onChanged,
  });

  final MotorPoles selectedPoles;
  final ValueChanged<MotorPoles> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motor Poles',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Dimens.spacingXs),
        Container(
          height: Dimens.inputHeightMd,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
            border: Border.all(
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                  : AppColors.textSecondaryLight.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingMd),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MotorPoles>(
              value: selectedPoles,
              isExpanded: true,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              items: MotorPoles.values.map((poles) {
                return DropdownMenuItem<MotorPoles>(
                  value: poles,
                  child: Text(poles.label),
                );
              }).toList(),
              onChanged: (poles) {
                if (poles != null) onChanged(poles);
              },
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/features/mechanical/domain/usecases/hydraulic_force_logic.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// Hydraulic Cylinder Force Calculator screen.
class HydraulicForceScreen extends ConsumerStatefulWidget {
  const HydraulicForceScreen({super.key});

  @override
  ConsumerState<HydraulicForceScreen> createState() =>
      _HydraulicForceScreenState();
}

class _HydraulicForceScreenState extends ConsumerState<HydraulicForceScreen> {
  final _boreController = TextEditingController();
  final _rodController = TextEditingController();
  final _pressureController = TextEditingController();

  @override
  void dispose() {
    _boreController.dispose();
    _rodController.dispose();
    _pressureController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final bore = double.tryParse(_boreController.text) ?? 0;
    final rod = double.tryParse(_rodController.text) ?? 0;
    final pressure = double.tryParse(_pressureController.text) ?? 0;

    final notifier = ref.read(hydraulicForceCalculatorProvider.notifier);
    notifier.updateBoreDiameter(bore);
    notifier.updateRodDiameter(rod);
    notifier.updatePressure(pressure);
  }

  void _clear() {
    _boreController.clear();
    _rodController.clear();
    _pressureController.clear();
    ref.read(hydraulicForceCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(hydraulicForceResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'Hydraulic: ${result.pushForce.toStringAsFixed(1)} kN',
        resultValue: 'Push/Pull',
        moduleType: ModuleType.mechanical,
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
    final result = ref.watch(hydraulicForceResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydraulic Cylinder Force'),
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
                  color: AppColors.mechanicalAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.mechanicalAccent,
                      size: Dimens.iconMd,
                    ),
                    const SizedBox(width: Dimens.spacingSm),
                    Expanded(
                      child: Text(
                        'Calculate push and pull forces for hydraulic cylinders.',
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
                label: 'Bore Diameter',
                controller: _boreController,
                hint: 'Enter bore diameter',
                suffixText: 'mm',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Rod Diameter',
                controller: _rodController,
                hint: 'Enter rod diameter',
                suffixText: 'mm',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'System Pressure',
                controller: _pressureController,
                hint: 'Enter pressure',
                suffixText: 'bar',
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
                  label: 'Push Force (Extend)',
                  value: result.pushForce,
                  unit: 'kN',
                  formula: result.pushFormula,
                  accentColor: AppColors.success,
                ),
                const SizedBox(height: Dimens.spacingMd),
                ResultCard(
                  label: 'Pull Force (Retract)',
                  value: result.pullForce,
                  unit: 'kN',
                  formula: result.pullFormula,
                  accentColor: AppColors.warning,
                ),
              ] else
                Center(
                  child: Text(
                    'Enter bore, rod, and pressure to calculate',
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

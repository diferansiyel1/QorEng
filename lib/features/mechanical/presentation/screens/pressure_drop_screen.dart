import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/features/mechanical/domain/usecases/pressure_drop_logic.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/export_pdf_button.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// Pipe Pressure Drop Calculator screen (Darcy-Weisbach).
class PressureDropScreen extends ConsumerStatefulWidget {
  const PressureDropScreen({super.key});

  @override
  ConsumerState<PressureDropScreen> createState() => _PressureDropScreenState();
}

class _PressureDropScreenState extends ConsumerState<PressureDropScreen> {
  final _lengthController = TextEditingController();
  final _diameterController = TextEditingController();
  final _velocityController = TextEditingController();
  final _densityController = TextEditingController(text: '1000');
  final _frictionController = TextEditingController(text: '0.02');

  @override
  void dispose() {
    _lengthController.dispose();
    _diameterController.dispose();
    _velocityController.dispose();
    _densityController.dispose();
    _frictionController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final length = double.tryParse(_lengthController.text) ?? 0;
    final diameter = double.tryParse(_diameterController.text) ?? 0;
    final velocity = double.tryParse(_velocityController.text) ?? 0;
    final density = double.tryParse(_densityController.text) ?? 0;
    final friction = double.tryParse(_frictionController.text) ?? 0;

    final notifier = ref.read(pressureDropCalculatorProvider.notifier);
    notifier.updateLength(length);
    notifier.updateDiameter(diameter);
    notifier.updateVelocity(velocity);
    notifier.updateDensity(density);
    notifier.updateFrictionFactor(friction);
  }

  void _clear() {
    _lengthController.clear();
    _diameterController.clear();
    _velocityController.clear();
    _densityController.text = '1000';
    _frictionController.text = '0.02';
    ref.read(pressureDropCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(pressureDropResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'Pressure Drop: ${result.pressureDropBar.toStringAsFixed(3)} bar',
        resultValue: '${result.pressureDropPsi.toStringAsFixed(2)} PSI',
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
    final result = ref.watch(pressureDropResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pipe Pressure Drop'),
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
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: Dimens.iconMd,
                    ),
                    const SizedBox(width: Dimens.spacingSm),
                    Expanded(
                      child: Text(
                        'Calculate pressure loss using Darcy-Weisbach equation.',
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
                label: 'Pipe Length (L)',
                controller: _lengthController,
                hint: 'Enter length',
                suffixText: 'm',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Pipe Diameter (D)',
                controller: _diameterController,
                hint: 'Enter internal diameter',
                suffixText: 'mm',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Flow Velocity (V)',
                controller: _velocityController,
                hint: 'Enter velocity',
                suffixText: 'm/s',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Fluid Density (rho)',
                controller: _densityController,
                hint: 'Default: 1000 (Water)',
                suffixText: 'kg/m3',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Friction Factor (f)',
                controller: _frictionController,
                hint: 'Typical: 0.02',
                suffixText: '',
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
                  label: 'Pressure Drop',
                  value: result.pressureDropBar,
                  unit: 'Bar',
                  accentColor: AppColors.info,
                ),
                const SizedBox(height: Dimens.spacingMd),
                ResultCard(
                  label: 'Pressure Drop',
                  value: result.pressureDropPsi,
                  unit: 'PSI',
                  accentColor: AppColors.info,
                ),
                const SizedBox(height: Dimens.spacingMd),
                ExportPdfButton(
                  title: 'Pipe Pressure Drop Calculation',
                  inputs: {
                    'Pipe Length': '${_lengthController.text} m',
                    'Pipe Diameter': '${_diameterController.text} mm',
                    'Flow Velocity': '${_velocityController.text} m/s',
                    'Fluid Density': '${_densityController.text} kg/m3',
                    'Friction Factor': _frictionController.text,
                  },
                  results: {
                    'Pressure Drop': '${result.pressureDropBar.toStringAsFixed(4)} Bar',
                    'Pressure Drop (PSI)': '${result.pressureDropPsi.toStringAsFixed(2)} PSI',
                  },
                  color: AppColors.mechanicalAccent,
                ),
              ] else
                Center(
                  child: Text(
                    'Enter pipe parameters to calculate pressure drop',
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

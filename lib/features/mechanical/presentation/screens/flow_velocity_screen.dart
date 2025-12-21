import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/features/mechanical/domain/usecases/flow_velocity_logic.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/export_pdf_button.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// Flow Velocity Calculator screen.
class FlowVelocityScreen extends ConsumerStatefulWidget {
  const FlowVelocityScreen({super.key});

  @override
  ConsumerState<FlowVelocityScreen> createState() => _FlowVelocityScreenState();
}

class _FlowVelocityScreenState extends ConsumerState<FlowVelocityScreen> {
  final _flowRateController = TextEditingController();
  final _diameterController = TextEditingController();

  @override
  void dispose() {
    _flowRateController.dispose();
    _diameterController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final flowRate = double.tryParse(_flowRateController.text) ?? 0;
    final diameter = double.tryParse(_diameterController.text) ?? 0;

    final notifier = ref.read(flowVelocityCalculatorProvider.notifier);
    notifier.updateFlowRate(flowRate);
    notifier.updateDiameter(diameter);
  }

  void _clear() {
    _flowRateController.clear();
    _diameterController.clear();
    ref.read(flowVelocityCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(flowVelocityResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'Flow Velocity: ${result.velocity.toStringAsFixed(2)} m/s',
        resultValue: result.warning == VelocityWarning.high ? '⚠️ High' : 'OK',
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
    final result = ref.watch(flowVelocityResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Velocity'),
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
                        'Calculate flow velocity from volumetric flow rate and pipe diameter.',
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
                label: 'Volumetric Flow Rate (Q)',
                controller: _flowRateController,
                hint: 'Enter flow rate',
                suffixText: 'm³/h',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Pipe Diameter (DN)',
                controller: _diameterController,
                hint: 'Enter internal diameter',
                suffixText: 'mm',
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
                _VelocityResultCard(
                  result: result,
                  flowRateText: _flowRateController.text,
                  diameterText: _diameterController.text,
                ),
              ] else
                Center(
                  child: Text(
                    'Enter flow rate and diameter to calculate velocity',
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

/// Velocity result card with warning indication.
class _VelocityResultCard extends StatelessWidget {
  const _VelocityResultCard({
    required this.result,
    required this.flowRateText,
    required this.diameterText,
  });

  final FlowVelocityResult result;
  final String flowRateText;
  final String diameterText;

  Color get _warningColor {
    return switch (result.warning) {
      VelocityWarning.safe => AppColors.success,
      VelocityWarning.warning => AppColors.warning,
      VelocityWarning.high => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ResultCard(
          label: 'Flow Velocity',
          value: result.velocity,
          unit: 'm/s',
          accentColor: _warningColor,
        ),
        if (result.warning != VelocityWarning.safe) ...[
          const SizedBox(height: Dimens.spacingMd),
          Container(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            decoration: BoxDecoration(
              color: _warningColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
              border: Border.all(color: _warningColor, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  result.warning == VelocityWarning.high
                      ? Icons.warning_amber
                      : Icons.info_outline,
                  color: _warningColor,
                  size: Dimens.iconLg,
                ),
                const SizedBox(width: Dimens.spacingMd),
                Expanded(
                  child: Text(
                    result.warningMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: Dimens.spacingMd),
        ExportPdfButton(
          title: 'Flow Velocity Calculation',
          inputs: {
            'Volumetric Flow Rate': '$flowRateText m³/h',
            'Pipe Diameter': '$diameterText mm',
          },
          results: {
            'Flow Velocity': '${result.velocity.toStringAsFixed(3)} m/s',
            'Status': result.warning.name,
          },
          color: AppColors.mechanicalAccent,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/chemical/domain/usecases/dilution_logic.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/export_pdf_button.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// Dilution Calculator screen (C1V1 = C2V2).
class DilutionScreen extends ConsumerStatefulWidget {
  const DilutionScreen({super.key});

  @override
  ConsumerState<DilutionScreen> createState() => _DilutionScreenState();
}

class _DilutionScreenState extends ConsumerState<DilutionScreen> {
  final _stockConcController = TextEditingController();
  final _targetConcController = TextEditingController();
  final _targetVolController = TextEditingController();

  @override
  void dispose() {
    _stockConcController.dispose();
    _targetConcController.dispose();
    _targetVolController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final stockConc = double.tryParse(_stockConcController.text) ?? 0;
    final targetConc = double.tryParse(_targetConcController.text) ?? 0;
    final targetVol = double.tryParse(_targetVolController.text) ?? 0;

    final notifier = ref.read(dilutionCalculatorProvider.notifier);
    notifier.updateStockConcentration(stockConc);
    notifier.updateTargetConcentration(targetConc);
    notifier.updateTargetVolume(targetVol);
  }

  void _clear() {
    _stockConcController.clear();
    _targetConcController.clear();
    _targetVolController.clear();
    ref.read(dilutionCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(dilutionResultProvider);
    if (result != null && !result.hasError) {
      final record = CalculationRecord(
        title: 'Dilution: ${result.stockVolume.toStringAsFixed(1)} mL stock',
        resultValue: '+ ${result.waterVolume.toStringAsFixed(1)} mL water',
        moduleType: ModuleType.chemical,
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
    final result = ref.watch(dilutionResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dilution Calculator'),
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
                  color: AppColors.chemicalAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.chemicalAccent,
                      size: Dimens.iconMd,
                    ),
                    const SizedBox(width: Dimens.spacingSm),
                    Expanded(
                      child: Text(
                        'Calculate stock solution and water volumes using C₁V₁ = C₂V₂.',
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
                label: 'Stock Concentration (C₁)',
                controller: _stockConcController,
                hint: 'Enter concentration',
                suffixText: '%',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Target Concentration (C₂)',
                controller: _targetConcController,
                hint: 'Enter desired concentration',
                suffixText: '%',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Target Volume (V₂)',
                controller: _targetVolController,
                hint: 'Enter final volume',
                suffixText: 'mL',
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
                if (result.hasError)
                  _ErrorCard(message: result.error!)
                else ...[
                  ResultCard(
                    label: 'Stock Solution Volume (V₁)',
                    value: result.stockVolume,
                    unit: 'mL',
                    accentColor: AppColors.chemicalAccent,
                  ),
                  const SizedBox(height: Dimens.spacingMd),
                  ResultCard(
                    label: 'Water/Diluent Volume',
                    value: result.waterVolume,
                    unit: 'mL',
                    accentColor: AppColors.info,
                  ),
                  const SizedBox(height: Dimens.spacingMd),
                  ExportPdfButton(
                    title: 'Dilution Calculation (C₁V₁ = C₂V₂)',
                    inputs: {
                      'Stock Concentration (C₁)': '${_stockConcController.text} %',
                      'Target Concentration (C₂)': '${_targetConcController.text} %',
                      'Target Volume (V₂)': '${_targetVolController.text} mL',
                    },
                    results: {
                      'Stock Volume (V₁)': '${result.stockVolume.toStringAsFixed(2)} mL',
                      'Water/Diluent Volume': '${result.waterVolume.toStringAsFixed(2)} mL',
                    },
                    color: AppColors.chemicalAccent,
                  ),
                ],
              ] else
                Center(
                  child: Text(
                    'Enter concentrations and volume to calculate',
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

/// Error card for invalid input.
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: Dimens.iconLg,
          ),
          const SizedBox(width: Dimens.spacingMd),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

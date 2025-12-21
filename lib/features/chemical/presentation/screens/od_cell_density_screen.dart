import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/chemical/domain/usecases/beer_lambert_logic.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// OD / Cell Density Calculator screen.
class OdCellDensityScreen extends ConsumerStatefulWidget {
  const OdCellDensityScreen({super.key});

  @override
  ConsumerState<OdCellDensityScreen> createState() =>
      _OdCellDensityScreenState();
}

class _OdCellDensityScreenState extends ConsumerState<OdCellDensityScreen> {
  final _measuredOdController = TextEditingController();
  final _dilutionController = TextEditingController(text: '1');
  final _factorController = TextEditingController(text: '8e8');

  @override
  void dispose() {
    _measuredOdController.dispose();
    _dilutionController.dispose();
    _factorController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final notifier = ref.read(odCellDensityCalculatorProvider.notifier);
    notifier.updateMeasuredOd(
      double.tryParse(_measuredOdController.text) ?? 0,
    );
    notifier.updateDilutionFactor(
      double.tryParse(_dilutionController.text) ?? 1,
    );
    notifier.updateCellsPerOdUnit(
      double.tryParse(_factorController.text) ?? 8e8,
    );
  }

  void _clear() {
    _measuredOdController.clear();
    _dilutionController.text = '1';
    _factorController.text = '8e8';
    ref.read(odCellDensityCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(odCellDensityResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'OD600: ${result.realOd.toStringAsFixed(2)}',
        resultValue: '${_formatScientific(result.totalCells)} cells/mL',
        moduleType: ModuleType.chemical,
      );
      ref.read(historyRecordsProvider.notifier).addRecord(record);
    }
  }

  void _calculateAndSave() {
    _updateCalculation();
    Future.microtask(_saveToHistory);
  }

  String _formatScientific(double value) {
    if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(2)}×10⁹';
    } else if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(2)}×10⁶';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = ref.watch(odCellDensityResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OD / Cell Density'),
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
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.biotech,
                      color: AppColors.warning,
                      size: Dimens.iconMd,
                    ),
                    const SizedBox(width: Dimens.spacingSm),
                    Expanded(
                      child: Text(
                        'Estimate cell count from OD600 spectrophotometer readings.',
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
                label: 'Measured OD600',
                controller: _measuredOdController,
                hint: 'Enter OD reading',
                suffixText: '',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Dilution Factor',
                controller: _dilutionController,
                hint: 'e.g., 10 for 1:10 dilution',
                suffixText: '×',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Cells per OD unit',
                controller: _factorController,
                hint: 'Default: 8×10⁸ (E. coli)',
                suffixText: 'cells/mL',
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
                // Non-linear warning
                if (result.isNonLinear)
                  Container(
                    padding: const EdgeInsets.all(Dimens.spacingMd),
                    margin: const EdgeInsets.only(bottom: Dimens.spacingMd),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(Dimens.radiusMd),
                      border: Border.all(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: AppColors.error,
                          size: Dimens.iconLg,
                        ),
                        const SizedBox(width: Dimens.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Non-Linear Range!',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'OD > 1.0 violates Beer\'s Law linearity. Please dilute sample for accurate readings.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                ResultCard(
                  label: 'Real OD (Corrected)',
                  value: result.realOd,
                  unit: '',
                  accentColor: AppColors.warning,
                ),
                const SizedBox(height: Dimens.spacingMd),
                ResultCard(
                  label: 'Total Cell Density',
                  value: result.totalCells,
                  unit: 'cells/mL',
                  accentColor: AppColors.success,
                ),
              ] else
                Center(
                  child: Text(
                    'Enter OD reading to calculate cell density',
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/chemical/domain/usecases/molarity_logic.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// Molarity Converter screen (g/L to M).
class MolarityScreen extends ConsumerStatefulWidget {
  const MolarityScreen({super.key});

  @override
  ConsumerState<MolarityScreen> createState() => _MolarityScreenState();
}

class _MolarityScreenState extends ConsumerState<MolarityScreen> {
  final _concentrationController = TextEditingController();
  final _mwController = TextEditingController();

  @override
  void dispose() {
    _concentrationController.dispose();
    _mwController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final concentration = double.tryParse(_concentrationController.text) ?? 0;
    final mw = double.tryParse(_mwController.text) ?? 0;

    final notifier = ref.read(molarityCalculatorProvider.notifier);
    notifier.updateConcentration(concentration);
    notifier.updateMolecularWeight(mw);
  }

  void _clear() {
    _concentrationController.clear();
    _mwController.clear();
    ref.read(molarityCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(molarityResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'Molarity: ${result.molarity.toStringAsFixed(4)} M',
        resultValue: '${result.molarityMM.toStringAsFixed(2)} mM',
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
    final result = ref.watch(molarityResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Molarity Converter'),
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
                        'Convert g/L concentration to Molarity (M) given molecular weight.',
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
                label: 'Concentration',
                controller: _concentrationController,
                hint: 'Enter concentration',
                suffixText: 'g/L',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Molecular Weight (MW)',
                controller: _mwController,
                hint: 'Enter MW',
                suffixText: 'g/mol',
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
                  label: 'Molarity',
                  value: result.molarity,
                  unit: 'M',
                  formula: result.formula,
                  accentColor: AppColors.chemicalAccent,
                ),
                const SizedBox(height: Dimens.spacingMd),
                ResultCard(
                  label: 'Molarity (Millimolar)',
                  value: result.molarityMM,
                  unit: 'mM',
                  accentColor: AppColors.info,
                ),
              ] else
                Center(
                  child: Text(
                    'Enter concentration and MW to calculate molarity',
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

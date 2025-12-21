import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/chemical/domain/usecases/beer_lambert_logic.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/export_pdf_button.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// Beer-Lambert Law Solver screen.
class BeerLambertScreen extends ConsumerStatefulWidget {
  const BeerLambertScreen({super.key});

  @override
  ConsumerState<BeerLambertScreen> createState() => _BeerLambertScreenState();
}

class _BeerLambertScreenState extends ConsumerState<BeerLambertScreen> {
  final _absorbanceController = TextEditingController();
  final _molarAbsorptivityController = TextEditingController();
  final _pathLengthController = TextEditingController(text: '1.0');
  final _concentrationController = TextEditingController();

  @override
  void dispose() {
    _absorbanceController.dispose();
    _molarAbsorptivityController.dispose();
    _pathLengthController.dispose();
    _concentrationController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final notifier = ref.read(beerLambertCalculatorProvider.notifier);
    notifier.updateAbsorbance(
      double.tryParse(_absorbanceController.text) ?? 0,
    );
    notifier.updateMolarAbsorptivity(
      double.tryParse(_molarAbsorptivityController.text) ?? 0,
    );
    notifier.updatePathLength(
      double.tryParse(_pathLengthController.text) ?? 0,
    );
    notifier.updateConcentration(
      double.tryParse(_concentrationController.text) ?? 0,
    );
  }

  void _clear() {
    _absorbanceController.clear();
    _molarAbsorptivityController.clear();
    _pathLengthController.text = '1.0';
    _concentrationController.clear();
    ref.read(beerLambertCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(beerLambertResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: '${result.resultLabel}: ${result.result.toStringAsFixed(4)}',
        resultValue: result.unit,
        moduleType: ModuleType.chemical,
      );
      ref.read(historyRecordsProvider.notifier).addRecord(record);
    }
  }

  void _calculateAndSave() {
    _updateCalculation();
    Future.microtask(_saveToHistory);
  }

  void _showQuickReference(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beer-Lambert Quick Reference'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A = ε × l × c'),
            SizedBox(height: 16),
            Text('• A: Absorbance (dimensionless)'),
            Text('• ε: Molar absorptivity (L/(mol·cm))'),
            Text('• l: Path length (cm) - typically 1 cm'),
            Text('• c: Concentration (mol/L or M)'),
            SizedBox(height: 16),
            Text(
              'Higher ε values indicate stronger light absorption at a given wavelength.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final input = ref.watch(beerLambertCalculatorProvider);
    final result = ref.watch(beerLambertResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beer-Lambert Solver'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showQuickReference(context),
            tooltip: 'Quick Reference',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Solve For Selector
              Text(
                'Solve For',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),
              _SolveForSelector(
                selected: input.solveFor,
                onChanged: (value) {
                  ref
                      .read(beerLambertCalculatorProvider.notifier)
                      .updateSolveFor(value);
                },
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Inputs
              Text(
                'Known Values',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Absorbance
              if (input.solveFor != BeerLambertSolveFor.absorbance)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimens.spacingMd),
                  child: EngineeringInputField<String>(
                    label: 'Absorbance (A)',
                    controller: _absorbanceController,
                    hint: 'Enter absorbance',
                    suffixText: 'AU',
                    onChanged: (_) => _updateCalculation(),
                  ),
                ),

              // Molar Absorptivity
              if (input.solveFor != BeerLambertSolveFor.molarAbsorptivity)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimens.spacingMd),
                  child: EngineeringInputField<String>(
                    label: 'Molar Absorptivity (ε)',
                    controller: _molarAbsorptivityController,
                    hint: 'Enter ε value',
                    suffixText: 'L/(mol·cm)',
                    onChanged: (_) => _updateCalculation(),
                  ),
                ),

              // Path Length
              if (input.solveFor != BeerLambertSolveFor.pathLength)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimens.spacingMd),
                  child: EngineeringInputField<String>(
                    label: 'Path Length (l)',
                    controller: _pathLengthController,
                    hint: 'Default: 1.0 cm cuvette',
                    suffixText: 'cm',
                    onChanged: (_) => _updateCalculation(),
                  ),
                ),

              // Concentration
              if (input.solveFor != BeerLambertSolveFor.concentration)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimens.spacingMd),
                  child: EngineeringInputField<String>(
                    label: 'Concentration (c)',
                    controller: _concentrationController,
                    hint: 'Enter concentration',
                    suffixText: 'mol/L',
                    onChanged: (_) => _updateCalculation(),
                  ),
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

              // Result
              if (result != null) ...[
                ResultCard(
                  label: result.resultLabel,
                  value: result.result,
                  unit: result.unit,
                  formula: result.formula,
                  accentColor: AppColors.warning,
                ),
                const SizedBox(height: Dimens.spacingMd),
                ExportPdfButton(
                  title: 'Beer-Lambert Law Calculation',
                  inputs: _buildBeerLambertInputs(input),
                  results: {
                    result.resultLabel: '${result.result.toStringAsFixed(6)} ${result.unit}',
                  },
                  color: AppColors.chemicalAccent,
                ),
              ] else
                Center(
                  child: Text(
                    'Enter known values to solve',
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

  Map<String, String> _buildBeerLambertInputs(BeerLambertInput input) {
    final inputs = <String, String>{};
    if (input.solveFor != BeerLambertSolveFor.absorbance) {
      inputs['Absorbance'] = '${_absorbanceController.text} AU';
    }
    if (input.solveFor != BeerLambertSolveFor.molarAbsorptivity) {
      inputs['Molar Absorptivity'] = '${_molarAbsorptivityController.text} L/(mol·cm)';
    }
    if (input.solveFor != BeerLambertSolveFor.pathLength) {
      inputs['Path Length'] = '${_pathLengthController.text} cm';
    }
    if (input.solveFor != BeerLambertSolveFor.concentration) {
      inputs['Concentration'] = '${_concentrationController.text} mol/L';
    }
    return inputs;
  }
}

/// Solve-for variable selector.
class _SolveForSelector extends StatelessWidget {
  const _SolveForSelector({
    required this.selected,
    required this.onChanged,
  });

  final BeerLambertSolveFor selected;
  final ValueChanged<BeerLambertSolveFor> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Dimens.spacingSm,
      runSpacing: Dimens.spacingSm,
      children: BeerLambertSolveFor.values.map((solveFor) {
        final isSelected = selected == solveFor;
        return ChoiceChip(
          label: Text(solveFor.label),
          selected: isSelected,
          onSelected: (_) => onChanged(solveFor),
          selectedColor: AppColors.warning.withValues(alpha: 0.3),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.warning : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        );
      }).toList(),
    );
  }
}

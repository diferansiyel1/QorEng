import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/chemical/domain/usecases/electrochemistry_logic.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';

/// Arrhenius Rate Calculator screen.
class ArrheniusScreen extends ConsumerStatefulWidget {
  const ArrheniusScreen({super.key});

  @override
  ConsumerState<ArrheniusScreen> createState() => _ArrheniusScreenState();
}

class _ArrheniusScreenState extends ConsumerState<ArrheniusScreen> {
  final _t1Controller = TextEditingController(text: '25');
  final _t2Controller = TextEditingController(text: '35');
  final _eaController = TextEditingController(text: '50');

  @override
  void dispose() {
    _t1Controller.dispose();
    _t2Controller.dispose();
    _eaController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final notifier = ref.read(arrheniusCalculatorProvider.notifier);
    notifier.updateTemperature1C(double.tryParse(_t1Controller.text) ?? 25);
    notifier.updateTemperature2C(double.tryParse(_t2Controller.text) ?? 35);
    notifier.updateActivationEnergy(double.tryParse(_eaController.text) ?? 50);
  }

  void _clear() {
    _t1Controller.text = '25';
    _t2Controller.text = '35';
    _eaController.text = '50';
    ref.read(arrheniusCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(arrheniusResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'Arrhenius: ${result.rateRatio.toStringAsFixed(2)}× rate',
        resultValue: result.isFaster ? 'Faster' : 'Slower',
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
    final result = ref.watch(arrheniusResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arrhenius Rate Calculator'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.speed,
                          color: AppColors.info,
                          size: Dimens.iconMd,
                        ),
                        const SizedBox(width: Dimens.spacingSm),
                        Text(
                          'Reaction Kinetics',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimens.spacingSm),
                    Text(
                      'Calculate how reaction rate changes with temperature using the Arrhenius equation.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Inputs
              Text(
                'Temperature Comparison',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              Row(
                children: [
                  Expanded(
                    child: EngineeringInputField<String>(
                      label: 'T₁ (Initial)',
                      controller: _t1Controller,
                      hint: 'Start temp',
                      suffixText: '°C',
                      onChanged: (_) => _updateCalculation(),
                    ),
                  ),
                  const SizedBox(width: Dimens.spacingMd),
                  const Icon(Icons.arrow_forward, color: AppColors.info),
                  const SizedBox(width: Dimens.spacingMd),
                  Expanded(
                    child: EngineeringInputField<String>(
                      label: 'T₂ (Final)',
                      controller: _t2Controller,
                      hint: 'End temp',
                      suffixText: '°C',
                      onChanged: (_) => _updateCalculation(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Activation Energy (Ea)',
                controller: _eaController,
                hint: 'Typical: 40-80 kJ/mol',
                suffixText: 'kJ/mol',
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

              if (result != null)
                _ArrheniusResultCard(result: result)
              else
                Center(
                  child: Text(
                    'Enter temperatures and Ea to calculate rate change',
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

/// Arrhenius result card with rate ratio display.
class _ArrheniusResultCard extends StatelessWidget {
  const _ArrheniusResultCard({required this.result});

  final ArrheniusResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = result.isFaster ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          // Rate ratio
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                result.isFaster ? Icons.trending_up : Icons.trending_down,
                color: color,
                size: 40,
              ),
              const SizedBox(width: Dimens.spacingMd),
              Text(
                'k₂/k₁',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.spacingMd),

          // Result value
          Text(
            result.rateRatio.toStringAsFixed(2),
            style: theme.textTheme.displayMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Dimens.spacingSm),

          // Description
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacingMd,
              vertical: Dimens.spacingSm,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
            ),
            child: Text(
              result.isFaster
                  ? 'Reaction runs ${result.rateRatio.toStringAsFixed(1)}× faster at T₂'
                  : 'Reaction runs ${(1 / result.rateRatio).toStringAsFixed(1)}× slower at T₂',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: Dimens.spacingLg),

          // Rule of thumb
          Container(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.info,
                  size: Dimens.iconMd,
                ),
                const SizedBox(width: Dimens.spacingSm),
                Expanded(
                  child: Text(
                    'Rule of thumb: Many biological reactions roughly double for every 10°C increase.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

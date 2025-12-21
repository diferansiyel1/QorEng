import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/chemical/domain/usecases/beer_lambert_logic.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';

/// Transmittance <-> Absorbance Converter screen.
class TransmittanceScreen extends ConsumerStatefulWidget {
  const TransmittanceScreen({super.key});

  @override
  ConsumerState<TransmittanceScreen> createState() =>
      _TransmittanceScreenState();
}

class _TransmittanceScreenState extends ConsumerState<TransmittanceScreen> {
  final _transmittanceController = TextEditingController(text: '100');
  final _absorbanceController = TextEditingController(text: '0');
  bool _isUpdatingFromCode = false;

  @override
  void dispose() {
    _transmittanceController.dispose();
    _absorbanceController.dispose();
    super.dispose();
  }

  void _updateFromTransmittance(String value) {
    if (_isUpdatingFromCode) return;
    final t = double.tryParse(value) ?? 0;
    ref.read(transmittanceConverterProvider.notifier).updateFromTransmittance(t);

    final state = ref.read(transmittanceConverterProvider);
    _isUpdatingFromCode = true;
    _absorbanceController.text = state.absorbance.toStringAsFixed(4);
    _isUpdatingFromCode = false;
  }

  void _updateFromAbsorbance(String value) {
    if (_isUpdatingFromCode) return;
    final a = double.tryParse(value) ?? 0;
    ref.read(transmittanceConverterProvider.notifier).updateFromAbsorbance(a);

    final state = ref.read(transmittanceConverterProvider);
    _isUpdatingFromCode = true;
    _transmittanceController.text = state.transmittance.toStringAsFixed(2);
    _isUpdatingFromCode = false;
  }

  void _clear() {
    ref.read(transmittanceConverterProvider.notifier).reset();
    _transmittanceController.text = '100';
    _absorbanceController.text = '0';
  }

  void _saveToHistory() {
    final state = ref.read(transmittanceConverterProvider);
    final record = CalculationRecord(
      title: 'T/A: ${state.transmittance.toStringAsFixed(1)}%T',
      resultValue: 'A = ${state.absorbance.toStringAsFixed(3)}',
      moduleType: ModuleType.chemical,
    );
    ref.read(historyRecordsProvider.notifier).addRecord(record);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(transmittanceConverterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transmittance ↔ Absorbance'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.swap_horiz,
                          color: AppColors.warning,
                          size: Dimens.iconMd,
                        ),
                        const SizedBox(width: Dimens.spacingSm),
                        Text(
                          'Bi-directional Converter',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimens.spacingSm),
                    Text(
                      'Changing either value updates the other instantly.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Transmittance Input
              EngineeringInputField<String>(
                label: 'Transmittance (%T)',
                controller: _transmittanceController,
                hint: 'Enter %T (0-100)',
                suffixText: '%',
                onChanged: _updateFromTransmittance,
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Swap indicator
              Center(
                child: Container(
                  padding: const EdgeInsets.all(Dimens.spacingMd),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_vert,
                    color: AppColors.warning,
                    size: Dimens.iconLg,
                  ),
                ),
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Absorbance Input
              EngineeringInputField<String>(
                label: 'Absorbance (A)',
                controller: _absorbanceController,
                hint: 'Enter absorbance',
                suffixText: 'AU',
                onChanged: _updateFromAbsorbance,
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Formula cards
              _FormulaCard(
                title: '%T → A',
                formula: 'A = 2 - log₁₀(%T)',
                result: 'A = ${state.absorbance.toStringAsFixed(4)}',
              ),
              const SizedBox(height: Dimens.spacingMd),
              _FormulaCard(
                title: 'A → %T',
                formula: '%T = 10^(2 - A)',
                result: '%T = ${state.transmittance.toStringAsFixed(2)}',
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Actions
              AppButton(
                label: 'Save to History',
                icon: Icons.save,
                onPressed: _saveToHistory,
              ),
              const SizedBox(height: Dimens.spacingSm),
              AppButton(
                label: 'Clear',
                icon: Icons.refresh,
                onPressed: _clear,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formula display card.
class _FormulaCard extends StatelessWidget {
  const _FormulaCard({
    required this.title,
    required this.formula,
    required this.result,
  });

  final String title;
  final String formula;
  final String result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Dimens.spacingXs),
          Text(
            formula,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: Dimens.spacingSm),
          Text(
            result,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

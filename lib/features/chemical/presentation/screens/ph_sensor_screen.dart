import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/chemical/domain/usecases/electrochemistry_logic.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/export_pdf_button.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// pH Sensor Diagnostics screen (Nernst Equation).
class PhSensorScreen extends ConsumerStatefulWidget {
  const PhSensorScreen({super.key});

  @override
  ConsumerState<PhSensorScreen> createState() => _PhSensorScreenState();
}

class _PhSensorScreenState extends ConsumerState<PhSensorScreen> {
  final _mvController = TextEditingController();
  final _tempController = TextEditingController(text: '25');
  final _e0Controller = TextEditingController(text: '0');

  @override
  void dispose() {
    _mvController.dispose();
    _tempController.dispose();
    _e0Controller.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final notifier = ref.read(phSensorCalculatorProvider.notifier);
    notifier.updateMeasuredMv(double.tryParse(_mvController.text) ?? 0);
    notifier.updateTemperatureC(double.tryParse(_tempController.text) ?? 25);
    notifier.updateE0(double.tryParse(_e0Controller.text) ?? 0);
  }

  void _clear() {
    _mvController.clear();
    _tempController.text = '25';
    _e0Controller.text = '0';
    ref.read(phSensorCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(phSensorResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'pH: ${result.calculatedPh.toStringAsFixed(2)}',
        resultValue: 'Slope: ${result.slopeEfficiency.toStringAsFixed(1)}%',
        moduleType: ModuleType.chemical,
      );
      ref.read(historyRecordsProvider.notifier).addRecord(record);
    }
  }

  void _calculateAndSave() {
    _updateCalculation();
    Future.microtask(_saveToHistory);
  }

  Color _getSlopeColor(double efficiency) {
    if (efficiency >= 95) return AppColors.success;
    if (efficiency >= 90) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = ref.watch(phSensorResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('pH Sensor Diagnostics'),
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
                          Icons.monitor_heart,
                          color: AppColors.info,
                          size: Dimens.iconMd,
                        ),
                        const SizedBox(width: Dimens.spacingSm),
                        Text(
                          'Nernst Equation',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimens.spacingSm),
                    Text(
                      'Calculate pH from mV readings. Use for sensor calibration and diagnostics.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Inputs
              Text(
                'Sensor Readings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Measured Voltage',
                controller: _mvController,
                hint: 'Enter mV reading',
                suffixText: 'mV',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Temperature',
                controller: _tempController,
                hint: 'Lab temperature',
                suffixText: '°C',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'E₀ (Isopotential)',
                controller: _e0Controller,
                hint: 'Usually 0 mV at pH 7',
                suffixText: 'mV',
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
                // pH Result
                _PhResultCard(result: result),
                const SizedBox(height: Dimens.spacingMd),

                // Slope Info
                ResultCard(
                  label: 'Theoretical Slope',
                  value: result.theoreticalSlope.abs(),
                  unit: 'mV/pH',
                  accentColor: AppColors.info,
                ),
                const SizedBox(height: Dimens.spacingMd),

                // Slope Efficiency
                Container(
                  padding: const EdgeInsets.all(Dimens.spacingMd),
                  decoration: BoxDecoration(
                    color: _getSlopeColor(result.slopeEfficiency)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Dimens.radiusMd),
                    border: Border.all(
                      color: _getSlopeColor(result.slopeEfficiency),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        result.slopeEfficiency >= 90
                            ? Icons.check_circle
                            : Icons.warning_amber,
                        color: _getSlopeColor(result.slopeEfficiency),
                        size: Dimens.iconLg,
                      ),
                      const SizedBox(width: Dimens.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Slope Efficiency: ${result.slopeEfficiency.toStringAsFixed(1)}%',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: _getSlopeColor(result.slopeEfficiency),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              result.slopeEfficiency >= 95
                                  ? 'Excellent sensor condition'
                                  : result.slopeEfficiency >= 90
                                      ? 'Acceptable - consider recalibration'
                                      : 'Poor - replace or recondition sensor',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimens.spacingMd),
                ExportPdfButton(
                  title: 'pH Sensor Diagnostics (Nernst)',
                  inputs: {
                    'Measured Voltage': '${_mvController.text} mV',
                    'Temperature': '${_tempController.text} °C',
                    'E₀ (Isopotential)': '${_e0Controller.text} mV',
                  },
                  results: {
                    'Calculated pH': result.calculatedPh.toStringAsFixed(2),
                    'Theoretical Slope': '${result.theoreticalSlope.abs().toStringAsFixed(2)} mV/pH',
                    'Slope Efficiency': '${result.slopeEfficiency.toStringAsFixed(1)} %',
                  },
                  color: AppColors.chemicalAccent,
                ),
              ] else
                Center(
                  child: Text(
                    'Enter mV reading to calculate pH',
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

/// pH result card with large display.
class _PhResultCard extends StatelessWidget {
  const _PhResultCard({required this.result});

  final PhSensorResult result;

  Color get _phColor {
    final ph = result.calculatedPh;
    if (ph < 4) return Colors.red;
    if (ph < 6) return Colors.orange;
    if (ph < 8) return AppColors.success;
    if (ph < 10) return Colors.blue;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _phColor.withValues(alpha: 0.3),
            _phColor.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        border: Border.all(color: _phColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Calculated pH',
            style: theme.textTheme.labelLarge?.copyWith(
              color: _phColor,
            ),
          ),
          const SizedBox(height: Dimens.spacingSm),
          Text(
            result.calculatedPh.toStringAsFixed(2),
            style: theme.textTheme.displayMedium?.copyWith(
              color: _phColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Dimens.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacingMd,
              vertical: Dimens.spacingXs,
            ),
            decoration: BoxDecoration(
              color: _phColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimens.radiusFull),
            ),
            child: Text(
              _getPhDescription(result.calculatedPh),
              style: theme.textTheme.labelMedium?.copyWith(
                color: _phColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPhDescription(double ph) {
    if (ph < 3) return 'Strongly Acidic';
    if (ph < 6) return 'Acidic';
    if (ph < 8) return 'Neutral';
    if (ph < 11) return 'Alkaline';
    return 'Strongly Alkaline';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/electrical/domain/usecases/signal_scaler_logic.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/export_pdf_button.dart';

/// Signal Scaler (4-20mA to PV) screen.
class SignalScalerScreen extends ConsumerStatefulWidget {
  const SignalScalerScreen({super.key});

  @override
  ConsumerState<SignalScalerScreen> createState() => _SignalScalerScreenState();
}

class _SignalScalerScreenState extends ConsumerState<SignalScalerScreen> {
  final _rawLowController = TextEditingController(text: '4');
  final _rawHighController = TextEditingController(text: '20');
  final _engLowController = TextEditingController(text: '0');
  final _engHighController = TextEditingController(text: '100');
  final _measuredController = TextEditingController();
  final _unitController = TextEditingController(text: 'Bar');

  @override
  void dispose() {
    _rawLowController.dispose();
    _rawHighController.dispose();
    _engLowController.dispose();
    _engHighController.dispose();
    _measuredController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final rawLow = double.tryParse(_rawLowController.text) ?? 0;
    final rawHigh = double.tryParse(_rawHighController.text) ?? 0;
    final engLow = double.tryParse(_engLowController.text) ?? 0;
    final engHigh = double.tryParse(_engHighController.text) ?? 0;
    final measured = double.tryParse(_measuredController.text) ?? 0;

    final notifier = ref.read(signalScalerCalculatorProvider.notifier);
    notifier.updateRawLow(rawLow);
    notifier.updateRawHigh(rawHigh);
    notifier.updateEngLow(engLow);
    notifier.updateEngHigh(engHigh);
    notifier.updateMeasuredValue(measured);
    notifier.updateEngUnit(_unitController.text);
  }

  void _onSignalTypeChanged(SignalType type) {
    ref.read(signalScalerCalculatorProvider.notifier).updateSignalType(type);
    _rawLowController.text = type.defaultLow.toString();
    _rawHighController.text = type.defaultHigh.toString();
    _updateCalculation();
  }

  void _clear() {
    _rawLowController.text = '4';
    _rawHighController.text = '20';
    _engLowController.text = '0';
    _engHighController.text = '100';
    _measuredController.clear();
    _unitController.text = 'Bar';
    ref.read(signalScalerCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(signalScalerResultProvider);
    final input = ref.read(signalScalerCalculatorProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: input.isReverse
            ? 'Signal: ${result.outputValue.toStringAsFixed(2)} mA'
            : 'Signal: ${result.outputValue.toStringAsFixed(2)} ${input.engUnit}',
        resultValue: '${result.percentageOfRange.toStringAsFixed(1)}%',
        moduleType: ModuleType.electrical,
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
    final input = ref.watch(signalScalerCalculatorProvider);
    final result = ref.watch(signalScalerResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signal Scaler'),
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
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.accent,
                      size: Dimens.iconMd,
                    ),
                    const SizedBox(width: Dimens.spacingSm),
                    Expanded(
                      child: Text(
                        'Convert raw signals (4-20mA) to engineering units or vice versa.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Reverse Mode Toggle
              _ReverseModeToggle(
                isReverse: input.isReverse,
                onToggle: () {
                  ref
                      .read(signalScalerCalculatorProvider.notifier)
                      .toggleReverse();
                },
              ),

              const SizedBox(height: Dimens.spacingMd),

              // Signal Type Dropdown
              _SignalTypeSelector(
                selectedType: input.signalType,
                onChanged: _onSignalTypeChanged,
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Raw Signal Range
              Text(
                'Raw Signal Range',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: EngineeringInputField<String>(
                      label: 'Low',
                      controller: _rawLowController,
                      hint: 'Min',
                      suffixText: input.signalType == SignalType.v0to10
                          ? 'V'
                          : 'mA',
                      onChanged: (_) => _updateCalculation(),
                    ),
                  ),
                  const SizedBox(width: Dimens.spacingMd),
                  Expanded(
                    child: EngineeringInputField<String>(
                      label: 'High',
                      controller: _rawHighController,
                      hint: 'Max',
                      suffixText: input.signalType == SignalType.v0to10
                          ? 'V'
                          : 'mA',
                      onChanged: (_) => _updateCalculation(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Engineering Range
              Text(
                'Engineering Range',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: EngineeringInputField<String>(
                      label: 'Low',
                      controller: _engLowController,
                      hint: 'Min',
                      suffixText: _unitController.text,
                      onChanged: (_) => _updateCalculation(),
                    ),
                  ),
                  const SizedBox(width: Dimens.spacingMd),
                  Expanded(
                    child: EngineeringInputField<String>(
                      label: 'High',
                      controller: _engHighController,
                      hint: 'Max',
                      suffixText: _unitController.text,
                      onChanged: (_) => _updateCalculation(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimens.spacingMd),
              EngineeringInputField<String>(
                label: 'Engineering Unit',
                controller: _unitController,
                hint: 'e.g., Bar, °C, %',
                onChanged: (_) => _updateCalculation(),
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Measured Value
              Text(
                input.isReverse ? 'Input Value (PV)' : 'Measured Signal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),
              EngineeringInputField<String>(
                label: input.isReverse
                    ? 'Physical Value'
                    : 'Raw Signal',
                controller: _measuredController,
                hint: input.isReverse ? 'Enter PV' : 'Enter mA/V',
                suffixText: input.isReverse
                    ? _unitController.text
                    : (input.signalType == SignalType.v0to10 ? 'V' : 'mA'),
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

              // Result
              if (result != null) ...[
                _SignalResultCard(result: result, input: input),
                const SizedBox(height: Dimens.spacingMd),
                ExportPdfButton(
                  title: 'Signal Scaler Calculation',
                  inputs: {
                    'Mode': input.isReverse ? 'PV → mA' : 'mA → PV',
                    'Signal Type': input.signalType.label,
                    'Raw Range': '${_rawLowController.text} - ${_rawHighController.text}',
                    'Eng Range': '${_engLowController.text} - ${_engHighController.text} ${_unitController.text}',
                    'Measured': input.isReverse ? '${_measuredController.text} ${_unitController.text}' : '${_measuredController.text} mA',
                  },
                  results: {
                    'Output': '${result.outputValue.toStringAsFixed(2)} ${input.isReverse ? "mA" : _unitController.text}',
                    'Range %': '${result.percentageOfRange.toStringAsFixed(1)} %',
                  },
                  color: AppColors.electricalAccent,
                ),
              ] else
                Center(
                  child: Text(
                    'Enter values to calculate',
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

/// Reverse mode toggle.
class _ReverseModeToggle extends StatelessWidget {
  const _ReverseModeToggle({
    required this.isReverse,
    required this.onToggle,
  });

  final bool isReverse;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      decoration: BoxDecoration(
        color: isReverse
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        border: Border.all(
          color: isReverse ? AppColors.warning : AppColors.accent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isReverse ? Icons.swap_horiz : Icons.trending_up,
            color: isReverse ? AppColors.warning : AppColors.accent,
          ),
          const SizedBox(width: Dimens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReverse ? 'Reverse Mode (PV → mA)' : 'Normal Mode (mA → PV)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isReverse ? AppColors.warning : AppColors.accent,
                  ),
                ),
                Text(
                  isReverse
                      ? 'Input physical value, output signal'
                      : 'Input raw signal, output physical value',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: isReverse,
            onChanged: (_) => onToggle(),
            activeThumbColor: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

/// Signal type dropdown selector.
class _SignalTypeSelector extends StatelessWidget {
  const _SignalTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  final SignalType selectedType;
  final ValueChanged<SignalType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signal Type',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Dimens.spacingXs),
        Container(
          height: Dimens.inputHeightMd,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
            border: Border.all(
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                  : AppColors.textSecondaryLight.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingMd),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<SignalType>(
              value: selectedType,
              isExpanded: true,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              items: SignalType.values.map((type) {
                return DropdownMenuItem<SignalType>(
                  value: type,
                  child: Text(type.label),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) onChanged(type);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Result card with percentage indicator.
class _SignalResultCard extends StatelessWidget {
  const _SignalResultCard({
    required this.result,
    required this.input,
  });

  final SignalScalerResult result;
  final SignalScalerInput input;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final outputLabel = input.isReverse ? 'Output Signal' : 'Physical Value';
    final outputUnit = input.isReverse
        ? (input.signalType == SignalType.v0to10 ? 'V' : 'mA')
        : input.engUnit;

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.3),
            AppColors.accent.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Column(
        children: [
          // Output Value
          Text(
            outputLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: Dimens.spacingSm),
          Text(
            '${result.outputValue.toStringAsFixed(2)} $outputUnit',
            style: theme.textTheme.displaySmall?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: Dimens.spacingLg),

          // Percentage Indicator
          Text(
            '${result.percentageOfRange.toStringAsFixed(1)}% of Range',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Dimens.spacingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.radiusFull),
            child: LinearProgressIndicator(
              value: result.percentageOfRange / 100,
              minHeight: 12,
              backgroundColor: AppColors.accent.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/electrical/domain/usecases/voltage_drop_logic.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/calculation_page.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/export_pdf_button.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// Standard cable cross-section sizes in mm².
const List<double> standardCableSizes = [
  0.5,
  0.75,
  1.0,
  1.5,
  2.5,
  4.0,
  6.0,
  10.0,
  16.0,
  25.0,
  35.0,
  50.0,
  70.0,
  95.0,
  120.0,
  150.0,
  185.0,
  240.0,
  300.0,
];

/// Voltage Drop Calculator screen.
///
/// Calculates voltage drop in cables using the formula:
/// V_drop = (k × I × L × ρ) / S
class VoltageDropScreen extends ConsumerStatefulWidget {
  const VoltageDropScreen({super.key});

  @override
  ConsumerState<VoltageDropScreen> createState() => _VoltageDropScreenState();
}

class _VoltageDropScreenState extends ConsumerState<VoltageDropScreen> {
  final _currentController = TextEditingController();
  final _lengthController = TextEditingController();
  final _voltageController = TextEditingController(text: '230');

  double _selectedCrossSection = 2.5;

  @override
  void dispose() {
    _currentController.dispose();
    _lengthController.dispose();
    _voltageController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final current = double.tryParse(_currentController.text) ?? 0;
    final length = double.tryParse(_lengthController.text) ?? 0;
    final voltage = double.tryParse(_voltageController.text) ?? 230;

    final notifier = ref.read(voltageDropCalculatorProvider.notifier);
    notifier.updateCurrent(current);
    notifier.updateLength(length);
    notifier.updateCrossSection(_selectedCrossSection);
    notifier.updateSystemVoltage(voltage);
  }

  void _clear() {
    _currentController.clear();
    _lengthController.clear();
    _voltageController.text = '230';
    setState(() => _selectedCrossSection = 2.5);
    ref.read(voltageDropCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(voltageDropResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'Voltage Drop: ${result.voltageDrop.toStringAsFixed(2)}V',
        resultValue: '${result.voltageDropPercentage.toStringAsFixed(1)}%',
        moduleType: ModuleType.electrical,
      );
      ref.read(historyRecordsProvider.notifier).addRecord(record);
    }
  }

  void _calculateAndSave() {
    _updateCalculation();
    // Defer save to after state update
    Future.microtask(_saveToHistory);
  }

  @override
  Widget build(BuildContext context) {
    final input = ref.watch(voltageDropCalculatorProvider);
    final result = ref.watch(voltageDropResultProvider);

    return CalculationPage(
      title: 'Voltage Drop',
      description:
          'Calculate voltage drop in cables. Formula: V = (k × I × L × ρ) / S',
      inputs: [
        // Phase System Selection
        _PhaseSystemSelector(
          selectedPhase: input.phaseSystem,
          onChanged: (phase) {
            ref
                .read(voltageDropCalculatorProvider.notifier)
                .updatePhaseSystem(phase);
          },
        ),

        // Material Selection
        _MaterialSelector(
          selectedMaterial: input.material,
          onChanged: (material) {
            ref
                .read(voltageDropCalculatorProvider.notifier)
                .updateMaterial(material);
          },
        ),

        // Current Input
        EngineeringInputField<String>(
          label: 'Current (I)',
          controller: _currentController,
          hint: 'Enter current',
          suffixText: 'A',
          onChanged: (_) => _updateCalculation(),
        ),

        // Cable Length Input
        EngineeringInputField<String>(
          label: 'Cable Length (L)',
          controller: _lengthController,
          hint: 'Enter length',
          suffixText: 'm',
          onChanged: (_) => _updateCalculation(),
        ),

        // Cross-section Dropdown
        _CrossSectionSelector(
          selectedSize: _selectedCrossSection,
          onChanged: (size) {
            setState(() => _selectedCrossSection = size);
            ref
                .read(voltageDropCalculatorProvider.notifier)
                .updateCrossSection(size);
          },
        ),

        // System Voltage Input
        EngineeringInputField<String>(
          label: 'System Voltage',
          controller: _voltageController,
          hint: 'Enter voltage',
          suffixText: 'V',
          onChanged: (_) => _updateCalculation(),
        ),
      ],
      actions: [
        AppButton(
          label: 'Calculate',
          icon: Icons.calculate,
          onPressed: _calculateAndSave,
        ),
        AppButton(
          label: 'Clear',
          icon: Icons.refresh,
          onPressed: _clear,
          variant: AppButtonVariant.secondary,
        ),
      ],
      results: [
        if (result != null) ...[
          ResultCard(
            label: 'Voltage Drop',
            value: result.voltageDrop,
            unit: 'V',
            formula: result.formula,
            accentColor: AppColors.electricalAccent,
          ),
          _PercentageResultCard(
            percentage: result.voltageDropPercentage,
            warning: result.warning,
          ),
          if (result.warning != VoltageDropWarning.none)
            _WarningCard(warning: result.warning),
          const SizedBox(height: 16),
          ExportPdfButton(
            title: 'Voltage Drop Calculation',
            inputs: {
              'Phase System': input.phaseSystem.label,
              'Material': input.material.label,
              'Current': '${_currentController.text} A',
              'Cable Length': '${_lengthController.text} m',
              'Cross-Section': '$_selectedCrossSection mm²',
              'System Voltage': '${_voltageController.text} V',
            },
            results: {
              'Voltage Drop': '${result.voltageDrop.toStringAsFixed(3)} V',
              'Percentage': '${result.voltageDropPercentage.toStringAsFixed(2)} %',
            },
            color: AppColors.electricalAccent,
          ),
        ] else
          const Center(
            child: Text(
              'Enter values to calculate voltage drop',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}

/// Phase system selector widget.
class _PhaseSystemSelector extends StatelessWidget {
  const _PhaseSystemSelector({
    required this.selectedPhase,
    required this.onChanged,
  });

  final PhaseSystem selectedPhase;
  final ValueChanged<PhaseSystem> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phase System',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Dimens.spacingXs),
        SegmentedButton<PhaseSystem>(
          segments: PhaseSystem.values.map((phase) {
            return ButtonSegment(
              value: phase,
              label: Text(phase.label),
            );
          }).toList(),
          selected: {selectedPhase},
          onSelectionChanged: (phases) => onChanged(phases.first),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.electricalAccent.withValues(alpha: 0.2);
              }
              return null;
            }),
          ),
        ),
      ],
    );
  }
}

/// Material selector widget.
class _MaterialSelector extends StatelessWidget {
  const _MaterialSelector({
    required this.selectedMaterial,
    required this.onChanged,
  });

  final ConductorMaterial selectedMaterial;
  final ValueChanged<ConductorMaterial> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conductor Material',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Dimens.spacingXs),
        SegmentedButton<ConductorMaterial>(
          segments: ConductorMaterial.values.map((material) {
            return ButtonSegment(
              value: material,
              label: Text(material.label),
            );
          }).toList(),
          selected: {selectedMaterial},
          onSelectionChanged: (materials) => onChanged(materials.first),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.electricalAccent.withValues(alpha: 0.2);
              }
              return null;
            }),
          ),
        ),
      ],
    );
  }
}

/// Cross-section dropdown selector.
class _CrossSectionSelector extends StatelessWidget {
  const _CrossSectionSelector({
    required this.selectedSize,
    required this.onChanged,
  });

  final double selectedSize;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cable Cross-Section (S)',
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
            child: DropdownButton<double>(
              value: selectedSize,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              items: standardCableSizes.map((size) {
                return DropdownMenuItem<double>(
                  value: size,
                  child: Text('$size mm²'),
                );
              }).toList(),
              onChanged: (size) {
                if (size != null) onChanged(size);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Percentage result card with color coding.
class _PercentageResultCard extends StatelessWidget {
  const _PercentageResultCard({
    required this.percentage,
    required this.warning,
  });

  final double percentage;
  final VoltageDropWarning warning;

  Color get _color {
    return switch (warning) {
      VoltageDropWarning.none => AppColors.success,
      VoltageDropWarning.lighting => AppColors.warning,
      VoltageDropWarning.power => AppColors.error,
    };
  }

  String get _status {
    return switch (warning) {
      VoltageDropWarning.none => 'OK',
      VoltageDropWarning.lighting => 'Warning',
      VoltageDropWarning.power => 'Critical',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      label: 'Voltage Drop Percentage ($_status)',
      value: percentage,
      unit: '%',
      accentColor: _color,
    );
  }
}

/// Warning card for voltage drop limits.
class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.warning});

  final VoltageDropWarning warning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, color, message) = switch (warning) {
      VoltageDropWarning.lighting => (
          Icons.lightbulb_outline,
          AppColors.warning,
          'Voltage drop exceeds 3% limit for lighting circuits!',
        ),
      VoltageDropWarning.power => (
          Icons.warning_amber,
          AppColors.error,
          'Voltage drop exceeds 5% limit for power circuits!',
        ),
      VoltageDropWarning.none => (Icons.check, AppColors.success, ''),
    };

    if (warning == VoltageDropWarning.none) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: Dimens.iconLg),
          const SizedBox(width: Dimens.spacingMd),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

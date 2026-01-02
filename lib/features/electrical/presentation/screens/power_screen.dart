import 'package:flutter/material.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/utils/units.dart';
import 'package:engicore/features/electrical/domain/usecases/power_calculator.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/calculation_page.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/export_pdf_button.dart';
import 'package:engicore/shared/widgets/invalid_input_card.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// Power calculator screen.
///
/// Allows users to calculate electrical power using different
/// combinations of voltage, current, and resistance.
class PowerScreen extends StatefulWidget {
  const PowerScreen({super.key});

  @override
  State<PowerScreen> createState() => _PowerScreenState();
}

class _PowerScreenState extends State<PowerScreen> {
  final _voltageController = TextEditingController();
  final _currentController = TextEditingController();
  final _resistanceController = TextEditingController();

  VoltageUnit _voltageUnit = VoltageUnit.volt;
  CurrentUnit _currentUnit = CurrentUnit.amp;
  ResistanceUnit _resistanceUnit = ResistanceUnit.ohm;

  PowerResult? _result;
  PowerMode _mode = PowerMode.fromVoltageAndCurrent;
  bool _hasInvalidInput = false;

  @override
  void dispose() {
    _voltageController.dispose();
    _currentController.dispose();
    _resistanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    final voltage = double.tryParse(_voltageController.text);
    final current = double.tryParse(_currentController.text);
    final resistance = double.tryParse(_resistanceController.text);

    PowerResult? result;

    switch (_mode) {
      case PowerMode.fromVoltageAndCurrent:
        if (voltage != null && current != null) {
          result = PowerCalculator.fromVoltageAndCurrent(
            voltage: voltage,
            voltageUnit: _voltageUnit,
            current: current,
            currentUnit: _currentUnit,
          );
        }
      case PowerMode.fromCurrentAndResistance:
        if (current != null && resistance != null) {
          result = PowerCalculator.fromCurrentAndResistance(
            current: current,
            currentUnit: _currentUnit,
            resistance: resistance,
            resistanceUnit: _resistanceUnit,
          );
        }
      case PowerMode.fromVoltageAndResistance:
        if (voltage != null && resistance != null) {
          result = PowerCalculator.fromVoltageAndResistance(
            voltage: voltage,
            voltageUnit: _voltageUnit,
            resistance: resistance,
            resistanceUnit: _resistanceUnit,
          );
        }
    }

    setState(() {
      _result = result;
      _hasInvalidInput = result == null &&
          _hasValidInputsForMode(voltage, current, resistance);
    });

    // Show SnackBar for invalid input (division by zero, negative values)
    if (_hasInvalidInput && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Invalid Input: Resistance cannot be zero or negative'),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Check if user has entered all required inputs for the current mode.
  bool _hasValidInputsForMode(double? voltage, double? current, double? resistance) {
    switch (_mode) {
      case PowerMode.fromVoltageAndCurrent:
        return voltage != null && current != null;
      case PowerMode.fromCurrentAndResistance:
        return current != null && resistance != null;
      case PowerMode.fromVoltageAndResistance:
        return voltage != null && resistance != null;
    }
  }

  void _clear() {
    setState(() {
      _voltageController.clear();
      _currentController.clear();
      _resistanceController.clear();
      _result = null;
      _hasInvalidInput = false;
    });
  }

  String get _modeFormula {
    return switch (_mode) {
      PowerMode.fromVoltageAndCurrent => 'P = V × I',
      PowerMode.fromCurrentAndResistance => 'P = I² × R',
      PowerMode.fromVoltageAndResistance => 'P = V² / R',
    };
  }

  @override
  Widget build(BuildContext context) {
    return CalculationPage(
      title: 'Power Calculator',
      description:
          'Calculate electrical power using voltage, current, or resistance.',
      inputs: [
        _ModeSelector(
          selectedMode: _mode,
          onModeChanged: (mode) => setState(() => _mode = mode),
        ),
        if (_mode == PowerMode.fromVoltageAndCurrent ||
            _mode == PowerMode.fromVoltageAndResistance)
          EngineeringInputField<VoltageUnit>(
            label: 'Voltage (V)',
            controller: _voltageController,
            units: VoltageUnit.values,
            selectedUnit: _voltageUnit,
            onUnitChanged: (unit) {
              if (unit != null) setState(() => _voltageUnit = unit);
            },
          ),
        if (_mode == PowerMode.fromVoltageAndCurrent ||
            _mode == PowerMode.fromCurrentAndResistance)
          EngineeringInputField<CurrentUnit>(
            label: 'Current (I)',
            controller: _currentController,
            units: CurrentUnit.values,
            selectedUnit: _currentUnit,
            onUnitChanged: (unit) {
              if (unit != null) setState(() => _currentUnit = unit);
            },
          ),
        if (_mode == PowerMode.fromCurrentAndResistance ||
            _mode == PowerMode.fromVoltageAndResistance)
          EngineeringInputField<ResistanceUnit>(
            label: 'Resistance (R)',
            controller: _resistanceController,
            units: ResistanceUnit.values,
            selectedUnit: _resistanceUnit,
            onUnitChanged: (unit) {
              if (unit != null) setState(() => _resistanceUnit = unit);
            },
          ),
      ],
      actions: [
        AppButton(
          label: 'Calculate',
          icon: Icons.calculate,
          onPressed: _calculate,
        ),
        AppButton(
          label: 'Clear',
          icon: Icons.refresh,
          onPressed: _clear,
          variant: AppButtonVariant.secondary,
        ),
      ],
      results: [
        if (_result != null) ...[
          ResultCard(
            label: 'Power',
            value: _result!.power,
            unit: 'W',
            formula: _modeFormula,
            accentColor: AppColors.electricalAccent,
          ),
          // Show power in other units
          ResultCard(
            label: 'Power (kilowatts)',
            value: _result!.power / 1000,
            unit: 'kW',
          ),
          if (_result!.power >= 1000000)
            ResultCard(
              label: 'Power (megawatts)',
              value: _result!.power / 1000000,
              unit: 'MW',
            ),
          const SizedBox(height: 16),
          ExportPdfButton(
            title: 'Power Calculation',
            inputs: _buildInputsMap(),
            results: _buildResultsMap(),
            color: AppColors.electricalAccent,
          ),
        ] else if (_hasInvalidInput)
          const InvalidInputCard(
            message: 'Cannot divide by zero. Please enter a non-zero resistance.',
          )
        else
          const Center(
            child: Text(
              'Enter values and tap Calculate',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Map<String, String> _buildInputsMap() {
    final inputs = <String, String>{};
    if (_mode == PowerMode.fromVoltageAndCurrent || _mode == PowerMode.fromVoltageAndResistance) {
      inputs['Voltage'] = '${_voltageController.text} ${_voltageUnit.symbol}';
    }
    if (_mode == PowerMode.fromVoltageAndCurrent || _mode == PowerMode.fromCurrentAndResistance) {
      inputs['Current'] = '${_currentController.text} ${_currentUnit.symbol}';
    }
    if (_mode == PowerMode.fromCurrentAndResistance || _mode == PowerMode.fromVoltageAndResistance) {
      inputs['Resistance'] = '${_resistanceController.text} ${_resistanceUnit.symbol}';
    }
    return inputs;
  }

  Map<String, String> _buildResultsMap() {
    if (_result == null) return {};
    return {
      'Power': '${_result!.power.toStringAsFixed(2)} W',
      'Power (kW)': '${(_result!.power / 1000).toStringAsFixed(4)} kW',
    };
  }
}

/// Mode selector for choosing the calculation formula.
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selectedMode,
    required this.onModeChanged,
  });

  final PowerMode selectedMode;
  final ValueChanged<PowerMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formula:',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<PowerMode>(
          segments: const [
            ButtonSegment(
              value: PowerMode.fromVoltageAndCurrent,
              label: Text('V × I'),
            ),
            ButtonSegment(
              value: PowerMode.fromCurrentAndResistance,
              label: Text('I² × R'),
            ),
            ButtonSegment(
              value: PowerMode.fromVoltageAndResistance,
              label: Text('V² / R'),
            ),
          ],
          selected: {selectedMode},
          onSelectionChanged: (modes) => onModeChanged(modes.first),
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

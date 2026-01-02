import 'package:flutter/material.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/utils/units.dart';
import 'package:engicore/features/electrical/domain/usecases/ohms_law_calculator.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/calculation_page.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/export_pdf_button.dart';
import 'package:engicore/shared/widgets/invalid_input_card.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// Ohm's Law calculator screen.
///
/// Allows users to calculate voltage, current, or resistance
/// by providing the other two values.
class OhmsLawScreen extends StatefulWidget {
  const OhmsLawScreen({super.key});

  @override
  State<OhmsLawScreen> createState() => _OhmsLawScreenState();
}

class _OhmsLawScreenState extends State<OhmsLawScreen> {
  final _voltageController = TextEditingController();
  final _currentController = TextEditingController();
  final _resistanceController = TextEditingController();

  VoltageUnit _voltageUnit = VoltageUnit.volt;
  CurrentUnit _currentUnit = CurrentUnit.amp;
  ResistanceUnit _resistanceUnit = ResistanceUnit.ohm;

  OhmsLawResult? _result;
  OhmsLawMode _mode = OhmsLawMode.voltage;
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

    OhmsLawResult? result;

    switch (_mode) {
      case OhmsLawMode.voltage:
        if (current != null && resistance != null) {
          result = OhmsLawCalculator.calculateVoltage(
            current: current,
            currentUnit: _currentUnit,
            resistance: resistance,
            resistanceUnit: _resistanceUnit,
          );
        }
      case OhmsLawMode.current:
        if (voltage != null && resistance != null) {
          result = OhmsLawCalculator.calculateCurrent(
            voltage: voltage,
            voltageUnit: _voltageUnit,
            resistance: resistance,
            resistanceUnit: _resistanceUnit,
          );
        }
      case OhmsLawMode.resistance:
        if (voltage != null && current != null) {
          result = OhmsLawCalculator.calculateResistance(
            voltage: voltage,
            voltageUnit: _voltageUnit,
            current: current,
            currentUnit: _currentUnit,
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
                child: Text('Invalid Input: Check parameters (e.g., avoid zero denominator)'),
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
      case OhmsLawMode.voltage:
        return current != null && resistance != null;
      case OhmsLawMode.current:
        return voltage != null && resistance != null;
      case OhmsLawMode.resistance:
        return voltage != null && current != null;
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

  @override
  Widget build(BuildContext context) {
    return CalculationPage(
      title: "Ohm's Law",
      description:
          "Ohm's Law describes the relationship between voltage, current, and resistance in an electrical circuit.",
      inputs: [
        _ModeSelector(
          selectedMode: _mode,
          onModeChanged: (mode) => setState(() => _mode = mode),
        ),
        if (_mode != OhmsLawMode.voltage)
          EngineeringInputField<VoltageUnit>(
            label: 'Voltage (V)',
            controller: _voltageController,
            units: VoltageUnit.values,
            selectedUnit: _voltageUnit,
            onUnitChanged: (unit) {
              if (unit != null) setState(() => _voltageUnit = unit);
            },
          ),
        if (_mode != OhmsLawMode.current)
          EngineeringInputField<CurrentUnit>(
            label: 'Current (I)',
            controller: _currentController,
            units: CurrentUnit.values,
            selectedUnit: _currentUnit,
            onUnitChanged: (unit) {
              if (unit != null) setState(() => _currentUnit = unit);
            },
          ),
        if (_mode != OhmsLawMode.resistance)
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
          if (_mode == OhmsLawMode.voltage)
            ResultCard(
              label: 'Voltage',
              value: _result!.voltage,
              unit: 'V',
              formula: 'V = I × R',
              accentColor: AppColors.electricalAccent,
            ),
          if (_mode == OhmsLawMode.current)
            ResultCard(
              label: 'Current',
              value: _result!.current,
              unit: 'A',
              formula: 'I = V / R',
              accentColor: AppColors.electricalAccent,
            ),
          if (_mode == OhmsLawMode.resistance)
            ResultCard(
              label: 'Resistance',
              value: _result!.resistance,
              unit: 'Ω',
              formula: 'R = V / I',
              accentColor: AppColors.electricalAccent,
            ),
          // Show derived values
          if (_mode == OhmsLawMode.voltage) ...[
            ResultCard(
              label: 'Power',
              value: _result!.voltage * _result!.current,
              unit: 'W',
              formula: 'P = V × I',
            ),
          ],
          if (_mode == OhmsLawMode.current) ...[
            ResultCard(
              label: 'Power',
              value: _result!.voltage * _result!.current,
              unit: 'W',
              formula: 'P = V × I',
            ),
          ],
          if (_mode == OhmsLawMode.resistance) ...[
            ResultCard(
              label: 'Power',
              value: _result!.voltage * _result!.current,
              unit: 'W',
              formula: 'P = V × I',
            ),
          ],
          // Export PDF button
          const SizedBox(height: 16),
          ExportPdfButton(
            title: "Ohm's Law Calculation",
            inputs: _buildInputsMap(),
            results: _buildResultsMap(),
            color: AppColors.electricalAccent,
          ),
        ] else if (_hasInvalidInput)
          const InvalidInputCard(
            message: 'Cannot divide by zero. Please enter a non-zero value.',
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
    if (_mode != OhmsLawMode.voltage && _voltageController.text.isNotEmpty) {
      inputs['Voltage'] = '${_voltageController.text} ${_voltageUnit.symbol}';
    }
    if (_mode != OhmsLawMode.current && _currentController.text.isNotEmpty) {
      inputs['Current'] = '${_currentController.text} ${_currentUnit.symbol}';
    }
    if (_mode != OhmsLawMode.resistance && _resistanceController.text.isNotEmpty) {
      inputs['Resistance'] = '${_resistanceController.text} ${_resistanceUnit.symbol}';
    }
    return inputs;
  }

  Map<String, String> _buildResultsMap() {
    if (_result == null) return {};
    final results = <String, String>{};
    switch (_mode) {
      case OhmsLawMode.voltage:
        results['Voltage'] = '${_result!.voltage.toStringAsFixed(4)} V';
      case OhmsLawMode.current:
        results['Current'] = '${_result!.current.toStringAsFixed(4)} A';
      case OhmsLawMode.resistance:
        results['Resistance'] = '${_result!.resistance.toStringAsFixed(4)} Ohm';
    }
    results['Power'] = '${(_result!.voltage * _result!.current).toStringAsFixed(4)} W';
    return results;
  }
}

/// Mode selector for choosing what to calculate.
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selectedMode,
    required this.onModeChanged,
  });

  final OhmsLawMode selectedMode;
  final ValueChanged<OhmsLawMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calculate:',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<OhmsLawMode>(
          segments: const [
            ButtonSegment(
              value: OhmsLawMode.voltage,
              label: Text('Voltage'),
              icon: Icon(Icons.electric_bolt, size: 18),
            ),
            ButtonSegment(
              value: OhmsLawMode.current,
              label: Text('Current'),
              icon: Icon(Icons.bolt, size: 18),
            ),
            ButtonSegment(
              value: OhmsLawMode.resistance,
              label: Text('Resistance'),
              icon: Icon(Icons.memory, size: 18),
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

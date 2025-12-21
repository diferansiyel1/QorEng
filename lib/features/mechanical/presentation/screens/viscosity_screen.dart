import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/features/mechanical/domain/usecases/viscosity_logic.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';
import 'package:engicore/shared/widgets/result_card.dart';

/// Viscosity Lab screen with converter and efflux cup calculator.
class ViscosityScreen extends StatelessWidget {
  const ViscosityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Viscosity Lab'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.mechanicalAccent,
            labelColor: AppColors.mechanicalAccent,
            tabs: [
              Tab(
                icon: Icon(Icons.swap_horiz),
                text: 'Converter',
              ),
              Tab(
                icon: Icon(Icons.timer),
                text: 'Efflux Cup',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ConverterTab(),
            _EffluxCupTab(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: VISCOSITY CONVERTER
// ============================================================================

class _ConverterTab extends ConsumerStatefulWidget {
  const _ConverterTab();

  @override
  ConsumerState<_ConverterTab> createState() => _ConverterTabState();
}

class _ConverterTabState extends ConsumerState<_ConverterTab> {
  final _dynamicController = TextEditingController();
  final _kinematicController = TextEditingController();
  final _densityController = TextEditingController(text: '1.0');

  @override
  void dispose() {
    _dynamicController.dispose();
    _kinematicController.dispose();
    _densityController.dispose();
    super.dispose();
  }

  void _onDynamicChanged(String value) {
    final v = double.tryParse(value) ?? 0;
    ref.read(viscosityConverterProvider.notifier).updateDynamicValue(v);
  }

  void _onKinematicChanged(String value) {
    final v = double.tryParse(value) ?? 0;
    ref.read(viscosityConverterProvider.notifier).updateKinematicValue(v);
  }

  void _onDensityChanged(String value) {
    final v = double.tryParse(value) ?? 1.0;
    ref.read(viscosityConverterProvider.notifier).updateDensity(v);
  }

  void _clear() {
    _dynamicController.clear();
    _kinematicController.clear();
    _densityController.text = '1.0';
    ref.read(viscosityConverterProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(viscosityConverterResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'Viscosity: ${result.dynamicCp.toStringAsFixed(2)} cP',
        resultValue: '${result.kinematicCst.toStringAsFixed(2)} cSt',
        moduleType: ModuleType.mechanical,
      );
      ref.read(historyRecordsProvider.notifier).addRecord(record);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final input = ref.watch(viscosityConverterProvider);
    final result = ref.watch(viscosityConverterResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description
          Container(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.mechanicalAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.mechanicalAccent,
                      size: Dimens.iconMd,
                    ),
                    const SizedBox(width: Dimens.spacingSm),
                    Text(
                      'ν = μ / ρ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.mechanicalAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimens.spacingSm),
                Text(
                  'Kinematic = Dynamic / Density. Enter either value to convert.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: Dimens.spacingLg),

          // Density Input (shared)
          Text(
            'Density',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Dimens.spacingMd),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: EngineeringInputField<String>(
                  label: 'Value',
                  controller: _densityController,
                  hint: 'Default: 1.0 (Water)',
                  onChanged: _onDensityChanged,
                ),
              ),
              const SizedBox(width: Dimens.spacingMd),
              Expanded(
                child: _UnitDropdown<DensityUnit>(
                  label: 'Unit',
                  value: input.densityUnit,
                  items: DensityUnit.values,
                  onChanged: (u) => ref
                      .read(viscosityConverterProvider.notifier)
                      .updateDensityUnit(u),
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimens.spacingLg),

          // Dynamic Viscosity
          _ViscosityInputSection(
            title: 'Dynamic Viscosity (μ)',
            controller: _dynamicController,
            unit: input.dynamicUnit,
            units: DynamicViscosityUnit.values,
            onValueChanged: _onDynamicChanged,
            onUnitChanged: (u) => ref
                .read(viscosityConverterProvider.notifier)
                .updateDynamicUnit(u),
            isActive: input.isDynamicMode,
            result:
                result != null && !input.isDynamicMode ? result.dynamicCp : null,
            resultUnit: 'cP',
          ),

          const SizedBox(height: Dimens.spacingMd),

          // Swap indicator
          Center(
            child: Container(
              padding: const EdgeInsets.all(Dimens.spacingSm),
              decoration: BoxDecoration(
                color: AppColors.mechanicalAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.swap_vert,
                color: AppColors.mechanicalAccent,
              ),
            ),
          ),

          const SizedBox(height: Dimens.spacingMd),

          // Kinematic Viscosity
          _ViscosityInputSection(
            title: 'Kinematic Viscosity (ν)',
            controller: _kinematicController,
            unit: input.kinematicUnit,
            units: KinematicViscosityUnit.values,
            onValueChanged: _onKinematicChanged,
            onUnitChanged: (u) => ref
                .read(viscosityConverterProvider.notifier)
                .updateKinematicUnit(u),
            isActive: !input.isDynamicMode,
            result:
                result != null && input.isDynamicMode ? result.kinematicCst : null,
            resultUnit: 'cSt',
          ),

          const SizedBox(height: Dimens.spacingLg),

          // Actions
          AppButton(
            label: 'Save to History',
            icon: Icons.save,
            onPressed: result != null ? _saveToHistory : null,
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
    );
  }
}

class _ViscosityInputSection<T extends Enum> extends StatelessWidget {
  const _ViscosityInputSection({
    required this.title,
    required this.controller,
    required this.unit,
    required this.units,
    required this.onValueChanged,
    required this.onUnitChanged,
    required this.isActive,
    this.result,
    this.resultUnit,
  });

  final String title;
  final TextEditingController controller;
  final T unit;
  final List<T> units;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<T> onUnitChanged;
  final bool isActive;
  final double? result;
  final String? resultUnit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.mechanicalAccent.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        border: Border.all(
          color: isActive
              ? AppColors.mechanicalAccent
              : AppColors.mechanicalAccent.withValues(alpha: 0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      isActive ? AppColors.mechanicalAccent : null,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: Dimens.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.spacingSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mechanicalAccent,
                    borderRadius: BorderRadius.circular(Dimens.radiusSm),
                  ),
                  child: Text(
                    'INPUT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Dimens.spacingMd),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: EngineeringInputField<String>(
                  label: 'Value',
                  controller: controller,
                  hint: isActive ? 'Enter value' : 'Calculated',
                  onChanged: onValueChanged,
                ),
              ),
              const SizedBox(width: Dimens.spacingMd),
              Expanded(
                child: _UnitDropdown<T>(
                  label: 'Unit',
                  value: unit,
                  items: units,
                  onChanged: onUnitChanged,
                ),
              ),
            ],
          ),
          if (result != null) ...[
            const SizedBox(height: Dimens.spacingMd),
            Container(
              padding: const EdgeInsets.all(Dimens.spacingSm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(Dimens.radiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: Dimens.iconSm,
                  ),
                  const SizedBox(width: Dimens.spacingXs),
                  Text(
                    '= ${result!.toStringAsFixed(4)} $resultUnit',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnitDropdown<T extends Enum> extends StatelessWidget {
  const _UnitDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;

  String _getLabel(T item) {
    if (item is DynamicViscosityUnit) return item.label;
    if (item is KinematicViscosityUnit) return item.label;
    if (item is DensityUnit) return item.label;
    return item.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingSm),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              style: theme.textTheme.bodyMedium,
              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    _getLabel(item),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TAB 2: EFFLUX CUP CALCULATOR
// ============================================================================

class _EffluxCupTab extends ConsumerStatefulWidget {
  const _EffluxCupTab();

  @override
  ConsumerState<_EffluxCupTab> createState() => _EffluxCupTabState();
}

class _EffluxCupTabState extends ConsumerState<_EffluxCupTab> {
  final _timeController = TextEditingController();
  final _densityController = TextEditingController(text: '1.0');

  @override
  void dispose() {
    _timeController.dispose();
    _densityController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final time = double.tryParse(_timeController.text) ?? 0;
    final density = double.tryParse(_densityController.text) ?? 1.0;
    final notifier = ref.read(effluxCupCalculatorProvider.notifier);
    notifier.updateFlowTime(time);
    notifier.updateDensity(density);
  }

  void _clear() {
    _timeController.clear();
    _densityController.text = '1.0';
    ref.read(effluxCupCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(effluxCupResultProvider);
    final input = ref.read(effluxCupCalculatorProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: '${input.cupType.label}: ${result.kinematicCst.toStringAsFixed(1)} cSt',
        resultValue: '${result.dynamicCp.toStringAsFixed(1)} cP',
        moduleType: ModuleType.mechanical,
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
    final input = ref.watch(effluxCupCalculatorProvider);
    final result = ref.watch(effluxCupResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description
          Container(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.mechanicalAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timer,
                  color: AppColors.mechanicalAccent,
                  size: Dimens.iconMd,
                ),
                const SizedBox(width: Dimens.spacingSm),
                Expanded(
                  child: Text(
                    'Convert efflux time (seconds) to viscosity using ASTM D1200 / ISO 2431 formulas.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Dimens.spacingLg),

          // Cup Type Selector
          Text(
            'Cup Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Dimens.spacingMd),
          _CupTypeSelector(
            selected: input.cupType,
            onChanged: (cup) => ref
                .read(effluxCupCalculatorProvider.notifier)
                .updateCupType(cup),
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
            label: 'Flow Time',
            controller: _timeController,
            hint: 'Time in seconds',
            suffixText: 's',
            onChanged: (_) => _updateCalculation(),
          ),
          const SizedBox(height: Dimens.spacingMd),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: EngineeringInputField<String>(
                  label: 'Density',
                  controller: _densityController,
                  hint: 'Default: 1.0',
                  onChanged: (_) => _updateCalculation(),
                ),
              ),
              const SizedBox(width: Dimens.spacingMd),
              Expanded(
                child: _UnitDropdown<DensityUnit>(
                  label: 'Unit',
                  value: input.densityUnit,
                  items: DensityUnit.values,
                  onChanged: (u) => ref
                      .read(effluxCupCalculatorProvider.notifier)
                      .updateDensityUnit(u),
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimens.spacingMd),

          // Actions
          AppButton(
            label: 'Calculate & Save',
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
            // Warning if out of range
            if (!result.isValidRange)
              Container(
                padding: const EdgeInsets.all(Dimens.spacingMd),
                margin: const EdgeInsets.only(bottom: Dimens.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                  border: Border.all(
                    color: AppColors.warning,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: AppColors.warning,
                      size: Dimens.iconMd,
                    ),
                    const SizedBox(width: Dimens.spacingMd),
                    Expanded(
                      child: Text(
                        result.warningMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Formula used
            Container(
              padding: const EdgeInsets.all(Dimens.spacingSm),
              margin: const EdgeInsets.only(bottom: Dimens.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimens.radiusSm),
              ),
              child: Text(
                'Formula: ${result.formula}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.info,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            ResultCard(
              label: 'Kinematic Viscosity',
              value: result.kinematicCst,
              unit: 'cSt',
              accentColor: AppColors.mechanicalAccent,
            ),
            const SizedBox(height: Dimens.spacingMd),
            ResultCard(
              label: 'Dynamic Viscosity',
              value: result.dynamicCp,
              unit: 'cP',
              accentColor: AppColors.success,
            ),
          ] else
            Center(
              child: Text(
                'Enter flow time to calculate viscosity',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Cup type selector with visual cards.
class _CupTypeSelector extends StatelessWidget {
  const _CupTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final EffluxCupType selected;
  final ValueChanged<EffluxCupType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: Dimens.spacingSm,
      runSpacing: Dimens.spacingSm,
      children: EffluxCupType.values.map((cup) {
        final isSelected = selected == cup;
        return GestureDetector(
          onTap: () => onChanged(cup),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacingMd,
              vertical: Dimens.spacingSm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.mechanicalAccent.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
              border: Border.all(
                color: isSelected
                    ? AppColors.mechanicalAccent
                    : AppColors.mechanicalAccent.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cup.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected ? AppColors.mechanicalAccent : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cup.minSeconds}-${cup.maxSeconds}s',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

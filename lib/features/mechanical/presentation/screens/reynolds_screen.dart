import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/features/mechanical/domain/usecases/reynolds_logic.dart';
import 'package:engicore/shared/widgets/app_button.dart';
import 'package:engicore/shared/widgets/engineering_input_field.dart';

/// Reynolds Number Calculator screen.
class ReynoldsScreen extends ConsumerStatefulWidget {
  const ReynoldsScreen({super.key});

  @override
  ConsumerState<ReynoldsScreen> createState() => _ReynoldsScreenState();
}

class _ReynoldsScreenState extends ConsumerState<ReynoldsScreen> {
  final _densityController = TextEditingController(text: '1000');
  final _velocityController = TextEditingController();
  final _diameterController = TextEditingController();
  final _viscosityController = TextEditingController(text: '0.001');

  @override
  void dispose() {
    _densityController.dispose();
    _velocityController.dispose();
    _diameterController.dispose();
    _viscosityController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final density = double.tryParse(_densityController.text) ?? 0;
    final velocity = double.tryParse(_velocityController.text) ?? 0;
    final diameter = double.tryParse(_diameterController.text) ?? 0;
    final viscosity = double.tryParse(_viscosityController.text) ?? 0;

    final notifier = ref.read(reynoldsCalculatorProvider.notifier);
    notifier.updateDensity(density);
    notifier.updateVelocity(velocity);
    notifier.updateDiameter(diameter);
    notifier.updateViscosity(viscosity);
  }

  void _clear() {
    _densityController.text = '1000';
    _velocityController.clear();
    _diameterController.clear();
    _viscosityController.text = '0.001';
    ref.read(reynoldsCalculatorProvider.notifier).reset();
  }

  void _saveToHistory() {
    final result = ref.read(reynoldsResultProvider);
    if (result != null) {
      final record = CalculationRecord(
        title: 'Reynolds: ${result.reynoldsNumber.toStringAsFixed(0)}',
        resultValue: result.regime.label,
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
    final result = ref.watch(reynoldsResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reynolds Number'),
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
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: Dimens.iconMd,
                    ),
                    const SizedBox(width: Dimens.spacingSm),
                    Expanded(
                      child: Text(
                        'Determine if flow is Laminar, Transient, or Turbulent.',
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
                label: 'Fluid Density (ρ)',
                controller: _densityController,
                hint: 'Default: 1000 (Water)',
                suffixText: 'kg/m³',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Flow Velocity (V)',
                controller: _velocityController,
                hint: 'Enter velocity',
                suffixText: 'm/s',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Pipe Diameter (D)',
                controller: _diameterController,
                hint: 'Enter internal diameter',
                suffixText: 'mm',
                onChanged: (_) => _updateCalculation(),
              ),
              const SizedBox(height: Dimens.spacingMd),

              EngineeringInputField<String>(
                label: 'Dynamic Viscosity (μ)',
                controller: _viscosityController,
                hint: 'Default: 0.001 (Water 20°C)',
                suffixText: 'Pa·s',
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
                _ReynoldsResultCard(result: result)
              else
                Center(
                  child: Text(
                    'Enter flow parameters to calculate Reynolds number',
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

/// Animated result card for Reynolds number.
class _ReynoldsResultCard extends StatelessWidget {
  const _ReynoldsResultCard({required this.result});

  final ReynoldsResult result;

  Color get _regimeColor {
    return switch (result.regime) {
      FlowRegime.laminar => AppColors.success,
      FlowRegime.transient => AppColors.warning,
      FlowRegime.turbulent => AppColors.error,
    };
  }

  IconData get _regimeIcon {
    return switch (result.regime) {
      FlowRegime.laminar => Icons.water,
      FlowRegime.transient => Icons.waves,
      FlowRegime.turbulent => Icons.tornado,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(Dimens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _regimeColor.withValues(alpha: 0.3),
            _regimeColor.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        border: Border.all(color: _regimeColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: _regimeColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _regimeColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _regimeIcon,
              size: 40,
              color: _regimeColor,
            ),
          ),
          const SizedBox(height: Dimens.spacingMd),

          // Reynolds Number
          Text(
            'Re = ${result.reynoldsNumber.toStringAsFixed(0)}',
            style: theme.textTheme.displaySmall?.copyWith(
              color: _regimeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Dimens.spacingSm),

          // Flow Regime
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacingMd,
              vertical: Dimens.spacingXs,
            ),
            decoration: BoxDecoration(
              color: _regimeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimens.radiusFull),
            ),
            child: Text(
              result.regime.label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: _regimeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: Dimens.spacingMd),

          // Description
          Text(
            result.regime.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

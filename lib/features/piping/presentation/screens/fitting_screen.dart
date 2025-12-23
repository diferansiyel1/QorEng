/// Probe Fitting Calculator Screen - "The Sensor Saver"
///
/// Calculates sensor insertion depth and warns about potential
/// collision with pipe walls or poor flow contact.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/localization_service.dart';
import '../../data/piping_standards.dart';
import '../theme/piping_theme.dart';
import '../widgets/pipe_section_painter.dart';

/// Probe Fitting Calculator screen.
class FittingScreen extends ConsumerStatefulWidget {
  const FittingScreen({super.key});

  @override
  ConsumerState<FittingScreen> createState() => _FittingScreenState();
}

class _FittingScreenState extends ConsumerState<FittingScreen> {
  SensorLength _selectedSensorLength = SensorLength.mm120;
  FittingType _selectedFitting = FittingType.ingoldSocket25;
  String _selectedPipeSize = 'DN100';

  double get _insertionDepth =>
      calculateInsertionDepth(_selectedSensorLength, _selectedFitting);

  double get _pipeInnerDiameter =>
      pipeInnerDiameters[_selectedPipeSize] ?? 100.0;

  ({bool isGoodFit, String? warning}) get _fitStatus => checkFitSafety(
        insertionDepthMm: _insertionDepth,
        pipeInnerDiameterMm: _pipeInnerDiameter,
      );

  FitStatus get _fitStatusEnum {
    final result = _fitStatus;
    if (!result.isGoodFit) {
      if (result.warning?.contains('COLLISION') ?? false) {
        return FitStatus.collision;
      }
      return FitStatus.tooShallow;
    }
    if (result.warning != null) {
      return FitStatus.warning;
    }
    return FitStatus.good;
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;

    return Scaffold(
      backgroundColor: PipingColors.background,
      appBar: AppBar(
        backgroundColor: PipingColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PipingColors.line),
          onPressed: () => context.pop(),
        ),
        title: Text(
          strings.probeFitting,
          style: PipingTypography.sectionTitle(fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input selectors
              _buildInputCard(strings),
              const SizedBox(height: 24),

              // Pipe section visualization
              _buildVisualizationCard(),
              const SizedBox(height: 24),

              // Calculation results
              _buildResultsCard(strings),

              // Warning message if applicable
              if (_fitStatus.warning != null) ...[
                const SizedBox(height: 16),
                _buildWarningCard(_fitStatus.warning!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PipingDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.sensorConfiguration,
            style: PipingTypography.sectionTitle(),
          ),
          const SizedBox(height: 16),

          // Sensor length dropdown
          _buildDropdown(
            label: strings.sensorLength,
            value: _selectedSensorLength.name,
            items: SensorLength.values
                .map((s) => DropdownMenuItem(
                      value: s.name,
                      child: Text(
                        s.name,
                        style: PipingTypography.dimension(),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSensorLength = SensorLength.values
                    .firstWhere((s) => s.name == value);
              });
            },
          ),
          const SizedBox(height: 12),

          // Fitting type dropdown
          _buildDropdown(
            label: strings.fittingType,
            value: _selectedFitting.name,
            items: FittingType.values
                .map((f) => DropdownMenuItem(
                      value: f.name,
                      child: Text(
                        f.name,
                        style: PipingTypography.dimension(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFitting = FittingType.values
                    .firstWhere((f) => f.name == value);
              });
            },
          ),
          const SizedBox(height: 12),

          // Pipe size dropdown
          _buildDropdown(
            label: strings.pipeDiameter,
            value: _selectedPipeSize,
            items: pipeInnerDiameters.keys
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        '$s (ID: ${pipeInnerDiameters[s]!.toInt()} mm)',
                        style: PipingTypography.dimension(),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedPipeSize = value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: PipingDecorations.dropdownDecoration(label),
      dropdownColor: PipingColors.surface,
      style: PipingTypography.dimension(),
      icon: const Icon(Icons.expand_more, color: PipingColors.accent),
      isExpanded: true,
    );
  }

  Widget _buildVisualizationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PipingDecorations.card(),
      child: Column(
        children: [
          Text(
            'PIPE CROSS-SECTION',
            style: PipingTypography.label(fontSize: 10),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: PipeSectionPainter(
                pipeInnerDiameter: _pipeInnerDiameter,
                insertionDepth: _insertionDepth,
                fitStatus: _fitStatusEnum,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard(AppStrings strings) {
    final halfPipeId = _pipeInnerDiameter / 2;
    final percentOfRadius = (_insertionDepth / halfPipeId) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PipingDecorations.card(
        isHighlighted: _fitStatus.isGoodFit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _fitStatus.isGoodFit
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                color: _fitStatus.isGoodFit
                    ? PipingColors.success
                    : PipingColors.danger,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                strings.calculationResults,
                style: PipingTypography.sectionTitle(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sensor length
          _buildResultRow(
            label: strings.sensorLength,
            value: '${_selectedSensorLength.lengthMm} mm',
          ),
          const SizedBox(height: 8),

          // Dead length
          _buildResultRow(
            label: strings.deadLength,
            value: '${_selectedFitting.deadLengthMm} mm',
            isSubtraction: true,
          ),
          const SizedBox(height: 8),

          const Divider(color: PipingColors.grid),
          const SizedBox(height: 8),

          // Insertion depth (main result)
          _buildResultRow(
            label: strings.insertionDepth,
            value: '${_insertionDepth.toInt()} mm',
            isResult: true,
          ),
          const SizedBox(height: 16),

          // Comparison to pipe
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompareChip(
                strings.pipeRadius,
                '${halfPipeId.toInt()} mm',
              ),
              _buildCompareChip(
                strings.penetration,
                '${percentOfRadius.toStringAsFixed(0)}%',
                color: _getPercentColor(percentOfRadius),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPercentColor(double percent) {
    if (percent > 100) return PipingColors.danger;
    if (percent < 10) return PipingColors.warning;
    if (percent >= 20 && percent <= 70) return PipingColors.success;
    return PipingColors.accent;
  }

  Widget _buildResultRow({
    required String label,
    required String value,
    bool isResult = false,
    bool isSubtraction = false,
  }) {
    return Row(
      children: [
        if (isSubtraction)
          Text(
            '−  ',
            style: PipingTypography.dimension(
              fontSize: 16,
              color: PipingColors.warning,
            ),
          ),
        Expanded(
          child: Text(
            label,
            style: PipingTypography.label(
              fontSize: isResult ? 14 : 12,
            ),
          ),
        ),
        Text(
          value,
          style: isResult
              ? PipingTypography.measurement(fontSize: 24)
              : PipingTypography.dimension(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCompareChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: PipingColors.grid.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: PipingTypography.label(fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: PipingTypography.measurement(
              fontSize: 18,
              color: color ?? PipingColors.dimension,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(String message) {
    final isCollision = message.contains('COLLISION');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isCollision ? PipingColors.danger : PipingColors.warning)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCollision ? PipingColors.danger : PipingColors.warning,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCollision ? Icons.dangerous : Icons.warning_amber,
            color: isCollision ? PipingColors.danger : PipingColors.warning,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: PipingTypography.dimension(
                fontSize: 13,
                color: isCollision ? PipingColors.danger : PipingColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

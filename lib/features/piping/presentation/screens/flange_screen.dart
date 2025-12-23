/// Flange Selector Screen - "The Bolt Matcher"
///
/// Technical tool for selecting process flanges by standard, pressure class,
/// and size. Displays a blueprint-style visualization and assembly kit details.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/localization_service.dart';
import '../../data/piping_standards.dart';
import '../theme/piping_theme.dart';
import '../widgets/flange_painter.dart';

/// Flange Selector screen for DIN/ANSI flange lookups.
class FlangeScreen extends ConsumerStatefulWidget {
  const FlangeScreen({super.key});

  @override
  ConsumerState<FlangeScreen> createState() => _FlangeScreenState();
}

class _FlangeScreenState extends ConsumerState<FlangeScreen> {
  FlangeStandard _selectedStandard = FlangeStandard.din;
  String _selectedPressureClass = 'PN16';
  String _selectedSize = 'DN100';

  List<String> get _pressureClasses =>
      getPressureClasses(_selectedStandard);

  List<String> get _availableSizes => getAvailableSizes(_selectedStandard);

  FlangeDim? get _currentFlange => getFlangeDim(
        standard: _selectedStandard,
        pressureClass: _selectedPressureClass,
        size: _selectedSize,
      );

  @override
  void initState() {
    super.initState();
    _updateSelectionsForStandard();
  }

  void _updateSelectionsForStandard() {
    final classes = _pressureClasses;
    final sizes = _availableSizes;

    if (!classes.contains(_selectedPressureClass)) {
      _selectedPressureClass = classes.first;
    }
    if (!sizes.contains(_selectedSize)) {
      _selectedSize = sizes[sizes.length ~/ 2];
    }
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
          strings.flangeSelector,
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
              // Selector row
              _buildSelectors(strings),
              const SizedBox(height: 24),

              // Blueprint visualization
              if (_currentFlange != null) ...[
                _buildBlueprintCard(),
                const SizedBox(height: 24),

                // Assembly kit result
                _buildAssemblyKitCard(strings),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectors(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PipingDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.selectParameters,
            style: PipingTypography.sectionTitle(),
          ),
          const SizedBox(height: 16),

          // Standard selector
          _buildDropdown(
            label: strings.standard,
            value: _selectedStandard.name,
            items: FlangeStandard.values
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
                _selectedStandard = FlangeStandard.values
                    .firstWhere((s) => s.name == value);
                _updateSelectionsForStandard();
              });
            },
          ),
          const SizedBox(height: 12),

          // Pressure class and size in row
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: strings.pressureClass,
                  value: _selectedPressureClass,
                  items: _pressureClasses
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: PipingTypography.dimension(),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedPressureClass = value!);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: strings.nominalSize,
                  value: _selectedSize,
                  items: _availableSizes
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: PipingTypography.dimension(),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedSize = value!);
                  },
                ),
              ),
            ],
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
    );
  }

  Widget _buildBlueprintCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PipingDecorations.card(),
      child: Column(
        children: [
          Text(
            'TECHNICAL DRAWING',
            style: PipingTypography.label(fontSize: 10),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: FlangePainter(
                flangeDim: _currentFlange!,
                showDimensions: true,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssemblyKitCard(AppStrings strings) {
    final flange = _currentFlange!;
    final spannerSize = getSpannerSize(flange.boltSize);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PipingDecorations.card(isHighlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.build_circle_outlined,
                color: PipingColors.accent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                strings.assemblyKit,
                style: PipingTypography.sectionTitle(
                  color: PipingColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bolt kit
          _buildResultRow(
            icon: Icons.settings,
            label: strings.boltKit,
            value: '${flange.boltCount}× ${flange.boltSize} × '
                '${flange.boltLength.toInt()} mm',
          ),
          const SizedBox(height: 12),

          // Spanner size
          _buildResultRow(
            icon: Icons.pan_tool,
            label: strings.spannerSize,
            value: spannerSize,
            highlight: true,
          ),
          const SizedBox(height: 12),

          // Hole diameter
          _buildResultRow(
            icon: Icons.radio_button_unchecked,
            label: strings.holeDiameter,
            value: 'Ø ${flange.holeDiameter.toInt()} mm',
          ),

          const SizedBox(height: 16),
          const Divider(color: PipingColors.grid),
          const SizedBox(height: 12),

          // Additional dimensions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDimChip('OD', '${flange.outerDiameter.toInt()} mm'),
              _buildDimChip('BCD', '${flange.boltCircleDiameter.toInt()} mm'),
              if (flange.pipeOD != null)
                _buildDimChip('Pipe', '${flange.pipeOD!.toStringAsFixed(1)} mm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: PipingColors.line,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: PipingTypography.label(fontSize: 13),
          ),
        ),
        Text(
          value,
          style: PipingTypography.measurement(
            fontSize: highlight ? 20 : 16,
            color: highlight ? PipingColors.accent : PipingColors.dimension,
          ),
        ),
      ],
    );
  }

  Widget _buildDimChip(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: PipingTypography.label(fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: PipingTypography.dimension(fontSize: 13),
        ),
      ],
    );
  }
}

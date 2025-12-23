import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/localization/localization_service.dart';
import 'package:engicore/features/field_logger/domain/entities/log_session.dart';
import 'package:engicore/features/field_logger/domain/repositories/field_logger_repository.dart';
import 'package:engicore/features/field_logger/presentation/widgets/numeric_keypad_widget.dart';

/// Active logging screen optimized for one-handed usage.
class ActiveLoggingScreen extends ConsumerStatefulWidget {
  const ActiveLoggingScreen({super.key});

  @override
  ConsumerState<ActiveLoggingScreen> createState() =>
      _ActiveLoggingScreenState();
}

class _ActiveLoggingScreenState extends ConsumerState<ActiveLoggingScreen> {
  final Map<String, TextEditingController> _inputControllers = {};
  final Map<String, String> _inputValues = {};
  String? _activeInputField;
  final _timeFormat = DateFormat('HH:mm:ss');

  // Colors for chart lines
  static const _chartColors = [
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF6D00), // Orange
    Color(0xFF7C4DFF), // Purple
    Color(0xFF00C853), // Green
    Color(0xFFFF5252), // Red
    Color(0xFFFFD54F), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers after first frame when session is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(activeSessionProvider);
      if (session != null) {
        for (final param in session.parameters) {
          _inputControllers[param.name] = TextEditingController();
          _inputValues[param.name] = '';
        }
        if (session.parameters.isNotEmpty) {
          _activeInputField = session.parameters.first.name;
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _inputControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_activeInputField == null) return;
    final current = _inputValues[_activeInputField!] ?? '';
    setState(() {
      _inputValues[_activeInputField!] = current + digit;
      _inputControllers[_activeInputField!]?.text =
          _inputValues[_activeInputField!]!;
    });
  }

  void _onDecimal() {
    if (_activeInputField == null) return;
    final current = _inputValues[_activeInputField!] ?? '';
    if (current.contains('.')) return; // Only one decimal point
    setState(() {
      _inputValues[_activeInputField!] = current.isEmpty ? '0.' : '$current.';
      _inputControllers[_activeInputField!]?.text =
          _inputValues[_activeInputField!]!;
    });
  }

  void _onBackspace() {
    if (_activeInputField == null) return;
    final current = _inputValues[_activeInputField!] ?? '';
    if (current.isEmpty) return;
    setState(() {
      _inputValues[_activeInputField!] =
          current.substring(0, current.length - 1);
      _inputControllers[_activeInputField!]?.text =
          _inputValues[_activeInputField!]!;
    });
  }

  void _onClear() {
    if (_activeInputField == null) return;
    setState(() {
      _inputValues[_activeInputField!] = '';
      _inputControllers[_activeInputField!]?.text = '';
    });
  }

  void _selectInputField(String paramName) {
    setState(() {
      _activeInputField = paramName;
    });
    HapticFeedback.selectionClick();
  }

  bool _validateInputs(LogSession session) {
    for (final param in session.parameters) {
      final value = _inputValues[param.name] ?? '';
      if (value.isEmpty) return false;
      if (double.tryParse(value) == null) return false;
    }
    return true;
  }

  void _recordPoint() {
    final session = ref.read(activeSessionProvider);
    if (session == null) return;

    if (!_validateInputs(session)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all values')),
      );
      return;
    }

    // Heavy haptic feedback for recording
    HapticFeedback.heavyImpact();

    // Create entry values map
    final values = <String, double>{};
    for (final param in session.parameters) {
      values[param.name] = double.parse(_inputValues[param.name]!);
    }

    // Add entry
    final entry = LogEntry(
      timestamp: DateTime.now(),
      values: values,
    );
    ref.read(activeSessionProvider.notifier).addEntry(entry);

    // Clear inputs for next reading
    setState(() {
      for (final param in session.parameters) {
        _inputValues[param.name] = '';
        _inputControllers[param.name]?.text = '';
      }
      // Select first field
      if (session.parameters.isNotEmpty) {
        _activeInputField = session.parameters.first.name;
      }
    });
  }

  Future<void> _endSession() async {
    final session = ref.read(activeSessionProvider);
    if (session == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: Text(
          'This will save the session with ${session.entries.length} recorded points.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(activeSessionProvider.notifier).endSession();
      if (mounted) {
        context.go('/field-logger/summary');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeSessionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.strings;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.fieldLogger)),
        body: const Center(child: Text('No active session')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(session.title),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: _endSession,
            icon: const Icon(Icons.stop_circle_outlined),
            label: Text(strings.endSession),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chart area
          Expanded(
            flex: 3,
            child: _LiveChart(
              session: session,
              chartColors: _chartColors,
              timeFormat: _timeFormat,
            ),
          ),

          // Entry count, undo and timer
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacingLg,
              vertical: Dimens.spacingSm,
            ),
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            child: Row(
              children: [
                Text(
                  '${strings.entries}: ${session.entries.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Undo last entry button
                if (session.entries.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(activeSessionProvider.notifier).removeLastEntry();
                    },
                    icon: const Icon(Icons.undo_rounded),
                    tooltip: 'Son kaydı sil',
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                const SizedBox(width: Dimens.spacingSm),
                Text(
                  _timeFormat.format(DateTime.now()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Input fields
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.spacingMd,
                vertical: Dimens.spacingSm,
              ),
              itemCount: session.parameters.length,
              itemBuilder: (context, index) {
                final param = session.parameters[index];
                final isActive = _activeInputField == param.name;
                final color = _chartColors[index % _chartColors.length];

                return _InputField(
                  parameter: param,
                  controller: _inputControllers[param.name],
                  isActive: isActive,
                  color: color,
                  onTap: () => _selectInputField(param.name),
                );
              },
            ),
          ),

          // Record button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacingLg,
              vertical: Dimens.spacingMd,
            ),
            child: ElevatedButton(
              onPressed: _recordPoint,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                elevation: 8,
                shadowColor: AppColors.accent.withValues(alpha: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fiber_manual_record, size: 24),
                  const SizedBox(width: Dimens.spacingSm),
                  Text(
                    strings.recordPoint.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Numeric keypad
          NumericKeypad(
            onDigit: _onDigit,
            onDecimal: _onDecimal,
            onBackspace: _onBackspace,
            onClear: _onClear,
          ),
        ],
      ),
    );
  }
}

/// Live chart widget showing parameter trends.
class _LiveChart extends StatelessWidget {
  const _LiveChart({
    required this.session,
    required this.chartColors,
    required this.timeFormat,
  });

  final LogSession session;
  final List<Color> chartColors;
  final DateFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (session.entries.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(Dimens.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 48,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(height: Dimens.spacingSm),
              Text(
                'Chart will appear after first recording',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Build line data for each parameter (normalized)
    final lineBars = <LineChartBarData>[];
    final legends = <Widget>[];

    for (int i = 0; i < session.parameters.length; i++) {
      final param = session.parameters[i];
      final color = chartColors[i % chartColors.length];

      // Get min/max for normalization
      double minVal = double.infinity;
      double maxVal = double.negativeInfinity;
      for (final entry in session.entries) {
        final val = entry.values[param.name] ?? 0;
        if (val < minVal) minVal = val;
        if (val > maxVal) maxVal = val;
      }
      final range = maxVal - minVal;

      // Build spots (normalized to 0-100)
      final spots = <FlSpot>[];
      for (int j = 0; j < session.entries.length; j++) {
        final entry = session.entries[j];
        final rawValue = entry.values[param.name] ?? 0;
        final normalizedValue =
            range > 0 ? ((rawValue - minVal) / range) * 100 : 50.0;
        spots.add(FlSpot(j.toDouble(), normalizedValue));
      }

      lineBars.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 3,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.1),
        ),
      ));

      // Legend item
      legends.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${param.name} (${param.unit})',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(Dimens.spacingMd),
      padding: const EdgeInsets.all(Dimens.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
      ),
      child: Column(
        children: [
          // Legend
          Wrap(
            spacing: Dimens.spacingMd,
            runSpacing: Dimens.spacingSm,
            children: legends,
          ),
          const SizedBox(height: Dimens.spacingSm),
          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: lineBars,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                        : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                        : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < session.entries.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              timeFormat.format(session.entries[idx].timestamp),
                              style: const TextStyle(fontSize: 8),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      interval: 25,
                    ),
                  ),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large input field for parameter value.
class _InputField extends StatelessWidget {
  const _InputField({
    required this.parameter,
    required this.controller,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  final LogParameter parameter;
  final TextEditingController? controller;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimens.spacingSm),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.spacingMd,
          vertical: Dimens.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.15)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
          border: Border.all(
            color: isActive ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: Dimens.spacingMd),
            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parameter.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    controller?.text.isNotEmpty == true
                        ? controller!.text
                        : '—',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: controller?.text.isNotEmpty == true
                          ? (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ),
            // Unit
            Text(
              parameter.unit,
              style: theme.textTheme.titleMedium?.copyWith(
                color:
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

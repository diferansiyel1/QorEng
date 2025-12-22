import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/localization/localization_service.dart';
import 'package:engicore/core/services/pdf_service.dart';
import 'package:engicore/features/field_logger/domain/entities/log_session.dart';
import 'package:engicore/features/field_logger/domain/repositories/field_logger_repository.dart';

/// Session summary screen displaying final chart and export options.
class SessionSummaryScreen extends ConsumerStatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  ConsumerState<SessionSummaryScreen> createState() =>
      _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends ConsumerState<SessionSummaryScreen> {
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _timeFormat = DateFormat('HH:mm:ss');
  final _fullTimeFormat = DateFormat('HH:mm:ss.SSS');

  // Colors for chart lines
  static const _chartColors = [
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF6D00), // Orange
    Color(0xFF7C4DFF), // Purple
    Color(0xFF00C853), // Green
    Color(0xFFFF5252), // Red
    Color(0xFFFFD54F), // Yellow
  ];

  Future<void> _exportCsv() async {
    final session = ref.read(activeSessionProvider);
    if (session == null || session.entries.isEmpty) return;

    // Build CSV content
    final buffer = StringBuffer();

    // Header row
    buffer.write('Timestamp');
    for (final param in session.parameters) {
      buffer.write(',${param.name} (${param.unit})');
    }
    buffer.writeln();

    // Data rows
    for (final entry in session.entries) {
      buffer.write(_fullTimeFormat.format(entry.timestamp));
      for (final param in session.parameters) {
        final value = entry.values[param.name] ?? '';
        buffer.write(',$value');
      }
      buffer.writeln();
    }

    // Share the CSV
    await Share.share(
      buffer.toString(),
      subject: '${session.title} - Field Log Data',
    );
  }

  Future<void> _exportPdf() async {
    final session = ref.read(activeSessionProvider);
    if (session == null) return;

    try {
      final pdfService = ref.read(pdfServiceProvider);
      final pdfData = await pdfService.generateLoggerReport(session);
      await pdfService.sharePdf(pdfData, '${session.title}_log');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  void _finish() {
    // Clear active session and go home
    ref.read(activeSessionProvider.notifier).clear();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeSessionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.strings;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.sessionSummary)),
        body: const Center(child: Text('No session data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.sessionSummary),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _finish,
            child: Text(strings.close),
          ),
        ],
      ),
      body: Column(
        children: [
          // Session info header
          Container(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_dateFormat.format(session.startTime)} • ${_timeFormat.format(session.startTime)} - ${session.endTime != null ? _timeFormat.format(session.endTime!) : 'Active'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.spacingMd,
                    vertical: Dimens.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Dimens.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.data_array, size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        '${session.entries.length} ${strings.entries}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chart
          Expanded(
            flex: 2,
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 3.0,
              child: _FinalChart(
                session: session,
                chartColors: _chartColors,
                timeFormat: _timeFormat,
              ),
            ),
          ),

          // Data table
          Expanded(
            flex: 3,
            child: _DataTable(
              session: session,
              timeFormat: _timeFormat,
              chartColors: _chartColors,
            ),
          ),

          // Export buttons
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(Dimens.spacingMd),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _exportCsv,
                      icon: const Icon(Icons.table_chart_outlined),
                      label: Text(strings.exportCsv),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimens.spacingMd),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _exportPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(strings.exportPdf),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Final chart widget with zoom support.
class _FinalChart extends StatelessWidget {
  const _FinalChart({
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
      return const Center(child: Text('No data recorded'));
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

      // Build spots
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
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: color,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.1),
        ),
      ));

      // Legend with min/max values
      legends.add(
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingSm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
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
                '${param.name}: ${minVal.toStringAsFixed(1)}-${maxVal.toStringAsFixed(1)} ${param.unit}',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
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
          Wrap(
            spacing: Dimens.spacingSm,
            runSpacing: Dimens.spacingSm,
            children: legends,
          ),
          const SizedBox(height: Dimens.spacingSm),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: lineBars,
                gridData: FlGridData(
                  show: true,
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
                          // Show every nth label based on count
                          final showInterval =
                              (session.entries.length / 5).ceil();
                          if (idx % showInterval != 0 &&
                              idx != session.entries.length - 1) {
                            return const SizedBox();
                          }
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
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final paramIndex = lineBars.indexOf(spot.bar);
                        if (paramIndex >= 0 &&
                            paramIndex < session.parameters.length) {
                          final param = session.parameters[paramIndex];
                          final entryIndex = spot.x.toInt();
                          if (entryIndex >= 0 &&
                              entryIndex < session.entries.length) {
                            final actualValue = session
                                    .entries[entryIndex].values[param.name] ??
                                0;
                            return LineTooltipItem(
                              '${param.name}: ${actualValue.toStringAsFixed(2)} ${param.unit}',
                              TextStyle(color: spot.bar.color),
                            );
                          }
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data table showing all recorded entries.
class _DataTable extends StatelessWidget {
  const _DataTable({
    required this.session,
    required this.timeFormat,
    required this.chartColors,
  });

  final LogSession session;
  final DateFormat timeFormat;
  final List<Color> chartColors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacingMd,
              vertical: Dimens.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Dimens.radiusMd),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    'Time',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...session.parameters.asMap().entries.map((entry) {
                  final param = entry.value;
                  final color = chartColors[entry.key % chartColors.length];
                  return Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            param.unit,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          // Data rows
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: session.entries.length,
              itemBuilder: (context, index) {
                final entry = session.entries[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.spacingMd,
                    vertical: Dimens.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.1)
                            : AppColors.textSecondaryLight
                                .withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          timeFormat.format(entry.timestamp),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      ...session.parameters.map((param) {
                        final value = entry.values[param.name];
                        return Expanded(
                          child: Text(
                            value?.toStringAsFixed(2) ?? '—',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

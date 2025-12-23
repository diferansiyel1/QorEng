/// Pipe Section CustomPainter for sensor fitting visualization.
///
/// Draws a cross-section view of a pipe with the sensor tip position,
/// showing collision zones and optimal insertion depth.
library;

import 'package:flutter/material.dart';
import '../theme/piping_theme.dart';

/// Status of sensor fit in pipe.
enum FitStatus {
  good,
  collision,
  tooShallow,
  warning,
}

/// CustomPainter for pipe cross-section with sensor visualization.
class PipeSectionPainter extends CustomPainter {
  PipeSectionPainter({
    required this.pipeInnerDiameter,
    required this.insertionDepth,
    required this.fitStatus,
  });

  final double pipeInnerDiameter;
  final double insertionDepth;
  final FitStatus fitStatus;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Calculate scale
    final maxDim = pipeInnerDiameter * 1.4;
    final scale = (size.shortestSide * 0.8) / maxDim;

    final pipeRadius = (pipeInnerDiameter / 2) * scale;
    final insertionScaled = insertionDepth * scale;

    // Paint styles
    final pipePaint = Paint()
      ..color = PipingColors.surface
      ..style = PaintingStyle.fill;

    final pipeOutline = Paint()
      ..color = PipingColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final pipeWallPaint = Paint()
      ..color = PipingColors.grid
      ..style = PaintingStyle.fill;

    // Sensor color based on status
    final sensorColor = switch (fitStatus) {
      FitStatus.good => PipingColors.success,
      FitStatus.collision => PipingColors.danger,
      FitStatus.tooShallow => PipingColors.warning,
      FitStatus.warning => PipingColors.warning,
    };

    final sensorPaint = Paint()
      ..color = sensorColor
      ..style = PaintingStyle.fill;

    // Draw pipe wall (outer ring)
    final wallThickness = pipeRadius * 0.15;
    canvas.drawCircle(center, pipeRadius + wallThickness, pipeWallPaint);

    // Draw pipe inner bore
    canvas.drawCircle(center, pipeRadius, pipePaint);
    canvas.drawCircle(center, pipeRadius, pipeOutline);

    // Draw flow direction arrows
    _drawFlowArrows(canvas, center, pipeRadius);

    // Draw center line
    final centerLinePaint = Paint()
      ..color = PipingColors.accent.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx - pipeRadius - 20, center.dy),
      Offset(center.dx + pipeRadius + 20, center.dy),
      centerLinePaint,
    );

    // Draw sensor from top
    final sensorWidth = 12 * scale; // 12mm sensor diameter
    final sensorTop = center.dy - pipeRadius - wallThickness - 10;
    final sensorTipY = center.dy - pipeRadius + insertionScaled;

    // Sensor housing (rectangle at top)
    final housingRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx - sensorWidth * 1.5,
        sensorTop - 30,
        sensorWidth * 3,
        35,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      housingRect,
      Paint()..color = PipingColors.grid,
    );
    canvas.drawRRect(
      housingRect,
      Paint()
        ..color = PipingColors.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Sensor shaft
    final sensorPath = Path()
      ..moveTo(center.dx - sensorWidth / 2, sensorTop)
      ..lineTo(center.dx - sensorWidth / 2, sensorTipY - 8)
      ..lineTo(center.dx, sensorTipY)
      ..lineTo(center.dx + sensorWidth / 2, sensorTipY - 8)
      ..lineTo(center.dx + sensorWidth / 2, sensorTop)
      ..close();

    canvas.drawPath(sensorPath, sensorPaint);
    canvas.drawPath(
      sensorPath,
      Paint()
        ..color = sensorColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Draw collision zone marker if applicable
    if (fitStatus == FitStatus.collision) {
      final collisionPaint = Paint()
        ..color = PipingColors.danger.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      // Highlight bottom half of pipe
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: pipeRadius),
        0,
        3.14159,
        true,
        collisionPaint,
      );
    }

    // Draw dimension indicators
    _drawDimensions(canvas, size, center, pipeRadius, insertionScaled);

    // Draw status label
    _drawStatusLabel(canvas, size, fitStatus, sensorColor);
  }

  void _drawFlowArrows(Canvas canvas, Offset center, double pipeRadius) {
    final arrowPaint = Paint()
      ..color = PipingColors.line.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Left arrow
    canvas.drawLine(
      Offset(center.dx - pipeRadius * 0.6, center.dy),
      Offset(center.dx - pipeRadius * 0.3, center.dy),
      arrowPaint,
    );

    // Right arrow
    canvas.drawLine(
      Offset(center.dx + pipeRadius * 0.3, center.dy),
      Offset(center.dx + pipeRadius * 0.6, center.dy),
      arrowPaint,
    );

    // Arrow heads
    final arrowPath = Path()
      ..moveTo(center.dx + pipeRadius * 0.6, center.dy)
      ..lineTo(center.dx + pipeRadius * 0.5, center.dy - 5)
      ..lineTo(center.dx + pipeRadius * 0.5, center.dy + 5)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint..style = PaintingStyle.fill);
  }

  void _drawDimensions(
    Canvas canvas,
    Size size,
    Offset center,
    double pipeRadius,
    double insertionScaled,
  ) {
    final dimPaint = Paint()
      ..color = PipingColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Pipe ID dimension (horizontal at bottom)
    final idY = center.dy + pipeRadius + 30;
    canvas.drawLine(
      Offset(center.dx - pipeRadius, idY),
      Offset(center.dx + pipeRadius, idY),
      dimPaint,
    );

    // Extension lines
    canvas.drawLine(
      Offset(center.dx - pipeRadius, center.dy + pipeRadius + 5),
      Offset(center.dx - pipeRadius, idY + 5),
      dimPaint..strokeWidth = 0.5,
    );
    canvas.drawLine(
      Offset(center.dx + pipeRadius, center.dy + pipeRadius + 5),
      Offset(center.dx + pipeRadius, idY + 5),
      dimPaint..strokeWidth = 0.5,
    );

    // ID label
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: 'ID ${pipeInnerDiameter.toInt()} mm',
      style: PipingTypography.dimension(fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, idY + 6),
    );

    // Insertion depth dimension (vertical, right side)
    final sensorTop = center.dy - pipeRadius;
    final sensorTipY = center.dy - pipeRadius + insertionScaled;

    if (insertionScaled > 0) {
      final depthX = center.dx + 50;
      canvas.drawLine(
        Offset(depthX, sensorTop),
        Offset(depthX, sensorTipY),
        dimPaint..strokeWidth = 1,
      );

      // Depth label
      textPainter.text = TextSpan(
        text: '${insertionDepth.toInt()} mm',
        style: PipingTypography.dimension(
          fontSize: 10,
          color: PipingColors.accent,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(depthX + 5, (sensorTop + sensorTipY) / 2 - 6),
      );
    }
  }

  void _drawStatusLabel(
    Canvas canvas,
    Size size,
    FitStatus status,
    Color color,
  ) {
    final label = switch (status) {
      FitStatus.good => '✓ GOOD FIT',
      FitStatus.collision => '⚠ COLLISION RISK',
      FitStatus.tooShallow => '⚠ TOO SHALLOW',
      FitStatus.warning => '△ CHECK DEPTH',
    };

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: label,
      style: PipingTypography.sectionTitle(fontSize: 12, color: color),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, size.height - 25),
    );
  }

  @override
  bool shouldRepaint(PipeSectionPainter oldDelegate) {
    return oldDelegate.pipeInnerDiameter != pipeInnerDiameter ||
        oldDelegate.insertionDepth != insertionDepth ||
        oldDelegate.fitStatus != fitStatus;
  }
}

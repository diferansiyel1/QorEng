/// Flange CustomPainter for blueprint-style visualization.
///
/// Draws a technical representation of a flange with bolt holes,
/// dimension lines, and labels in CAD drawing style.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/piping_theme.dart';
import '../../data/piping_standards.dart';

/// CustomPainter for flange visualization.
class FlangePainter extends CustomPainter {
  FlangePainter({
    required this.flangeDim,
    this.showDimensions = true,
  });

  final FlangeDim flangeDim;
  final bool showDimensions;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Calculate scale to fit flange in canvas with padding
    final maxDim = flangeDim.outerDiameter;
    final scale = (size.shortestSide * 0.75) / maxDim;

    // Scaled dimensions
    final outerRadius = (flangeDim.outerDiameter / 2) * scale;
    final bcdRadius = (flangeDim.boltCircleDiameter / 2) * scale;
    final holeRadius = (flangeDim.holeDiameter / 2) * scale;
    final pipeRadius = ((flangeDim.pipeOD ?? 50) / 2) * scale;

    // Paint styles
    final outlinePaint = Paint()
      ..color = PipingColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final holePaint = Paint()
      ..color = PipingColors.boltHole
      ..style = PaintingStyle.fill;

    final holeOutlinePaint = Paint()
      ..color = PipingColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pipePaint = Paint()
      ..color = PipingColors.grid
      ..style = PaintingStyle.fill;

    final centerLinePaint = Paint()
      ..color = PipingColors.grid.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw grid/center lines
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      centerLinePaint,
    );
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      centerLinePaint,
    );

    // Draw pipe bore (center circle)
    canvas.drawCircle(center, pipeRadius, pipePaint);
    canvas.drawCircle(center, pipeRadius, outlinePaint);

    // Draw flange outer diameter
    canvas.drawCircle(center, outerRadius, outlinePaint);

    // Draw bolt circle diameter (dashed)
    _drawDashedCircle(canvas, center, bcdRadius, PipingColors.accent);

    // Draw bolt holes
    final angleStep = (2 * math.pi) / flangeDim.boltCount;
    for (var i = 0; i < flangeDim.boltCount; i++) {
      final angle = (i * angleStep) - (math.pi / 2);
      final holeCenter = Offset(
        center.dx + bcdRadius * math.cos(angle),
        center.dy + bcdRadius * math.sin(angle),
      );
      canvas.drawCircle(holeCenter, holeRadius, holePaint);
      canvas.drawCircle(holeCenter, holeRadius, holeOutlinePaint);
    }

    // Draw dimension annotations if enabled
    if (showDimensions) {
      _drawDimensionLines(canvas, size, center, outerRadius, bcdRadius, scale);
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dashCount = 36;
    const dashAngle = (2 * math.pi) / dashCount;
    const gapRatio = 0.3;

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapRatio);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  void _drawDimensionLines(
    Canvas canvas,
    Size size,
    Offset center,
    double outerRadius,
    double bcdRadius,
    double scale,
  ) {
    final dimPaint = Paint()
      ..color = PipingColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // OD dimension line (horizontal, below)
    final odY = center.dy + outerRadius + 25;
    canvas.drawLine(
      Offset(center.dx - outerRadius, odY),
      Offset(center.dx + outerRadius, odY),
      dimPaint,
    );

    // OD arrows
    _drawArrow(canvas, Offset(center.dx - outerRadius, odY), true, dimPaint);
    _drawArrow(canvas, Offset(center.dx + outerRadius, odY), false, dimPaint);

    // OD extension lines
    canvas.drawLine(
      Offset(center.dx - outerRadius, center.dy + outerRadius + 5),
      Offset(center.dx - outerRadius, odY + 5),
      dimPaint..strokeWidth = 0.5,
    );
    canvas.drawLine(
      Offset(center.dx + outerRadius, center.dy + outerRadius + 5),
      Offset(center.dx + outerRadius, odY + 5),
      dimPaint..strokeWidth = 0.5,
    );

    // BCD dimension line (vertical, right side)
    final bcdX = center.dx + outerRadius + 25;
    canvas.drawLine(
      Offset(bcdX, center.dy - bcdRadius),
      Offset(bcdX, center.dy + bcdRadius),
      dimPaint..strokeWidth = 1,
    );

    // BCD vertical arrows
    _drawVerticalArrow(
      canvas,
      Offset(bcdX, center.dy - bcdRadius),
      true,
      dimPaint,
    );
    _drawVerticalArrow(
      canvas,
      Offset(bcdX, center.dy + bcdRadius),
      false,
      dimPaint,
    );

    // Draw dimension text labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // OD label
    textPainter.text = TextSpan(
      text: 'ØD ${flangeDim.outerDiameter.toInt()}',
      style: PipingTypography.dimension(fontSize: 11),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, odY + 8),
    );

    // BCD label
    textPainter.text = TextSpan(
      text: 'k ${flangeDim.boltCircleDiameter.toInt()}',
      style: PipingTypography.dimension(fontSize: 11, color: PipingColors.accent),
    );
    textPainter.layout();
    canvas.save();
    canvas.translate(bcdX + 12, center.dy + textPainter.width / 2);
    canvas.rotate(-math.pi / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();

    // Bolt count label (top)
    textPainter.text = TextSpan(
      text: '${flangeDim.boltCount}× Ø${flangeDim.holeDiameter.toInt()}',
      style: PipingTypography.dimension(fontSize: 10, color: PipingColors.line),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - outerRadius - 20),
    );
  }

  void _drawArrow(Canvas canvas, Offset point, bool leftFacing, Paint paint) {
    const arrowSize = 6.0;
    final direction = leftFacing ? 1 : -1;

    final path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(point.dx + (arrowSize * direction), point.dy - arrowSize / 2)
      ..lineTo(point.dx + (arrowSize * direction), point.dy + arrowSize / 2)
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  void _drawVerticalArrow(
    Canvas canvas,
    Offset point,
    bool upFacing,
    Paint paint,
  ) {
    const arrowSize = 6.0;
    final direction = upFacing ? 1 : -1;

    final path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(point.dx - arrowSize / 2, point.dy + (arrowSize * direction))
      ..lineTo(point.dx + arrowSize / 2, point.dy + (arrowSize * direction))
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(FlangePainter oldDelegate) {
    return oldDelegate.flangeDim != flangeDim ||
        oldDelegate.showDimensions != showDimensions;
  }
}

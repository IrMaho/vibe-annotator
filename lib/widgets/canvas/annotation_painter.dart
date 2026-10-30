import 'package:flutter/material.dart';
import '../../models/annotation_region.dart';
import '../../utils/color_palette.dart';

class AnnotationPainter extends CustomPainter {
  final List<AnnotationRegion> annotations;
  final String? selectedRegionId;
  final Rect? activeDrawingRect; // normalized 0..1
  final Size imageDisplaySize;
  final bool showTitles;

  AnnotationPainter({
    required this.annotations,
    required this.selectedRegionId,
    required this.activeDrawingRect,
    required this.imageDisplaySize,
    this.showTitles = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageDisplaySize.width <= 0 || imageDisplaySize.height <= 0) return;

    final double baseDimension = (imageDisplaySize.width + imageDisplaySize.height) / 2.0;
    final double scale = (baseDimension / 1200.0).clamp(0.8, 3.5);

    // 1. Draw completed annotations
    for (final ann in annotations) {
      final isSelected = ann.id == selectedRegionId;
      _drawRegion(canvas, ann, isSelected, scale);
    }

    // 2. Draw live drawing rectangle (while user drags mouse)
    if (activeDrawingRect != null) {
      _drawActiveDrawingRect(canvas, activeDrawingRect!, scale);
    }
  }

  void _drawRegion(Canvas canvas, AnnotationRegion ann, bool isSelected, double scale) {
    final pixelRect = ann.toPixelRect(imageDisplaySize);
    final color = ann.color;

    // Fill
    final fillPaint = Paint()
      ..color = isSelected ? color.withOpacity(0.25) : color.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(pixelRect, Radius.circular(5 * scale)), fillPaint);

    // Glow if selected
    if (isSelected) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0 * scale
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 * scale);
      canvas.drawRRect(RRect.fromRectAndRadius(pixelRect, Radius.circular(5 * scale)), glowPaint);
    }

    // Main border
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (isSelected ? 3.0 : 2.0) * scale;
    canvas.drawRRect(RRect.fromRectAndRadius(pixelRect, Radius.circular(5 * scale)), strokePaint);

    // Cyberpunk Corner Brackets
    _drawCorners(canvas, pixelRect, color, isSelected, scale);

    // If selected, draw corner resize handles
    if (isSelected) {
      _drawResizeHandles(canvas, pixelRect, color, scale);
    }

    // Draw Badge
    _drawBadge(
      canvas,
      pixelRect,
      ann.label,
      showTitles && ann.title.isNotEmpty ? ann.title : null,
      color,
      isSelected,
      scale,
    );
  }

  void _drawActiveDrawingRect(Canvas canvas, Rect normRect, double scale) {
    final left = normRect.left * imageDisplaySize.width;
    final top = normRect.top * imageDisplaySize.height;
    final right = normRect.right * imageDisplaySize.width;
    final bottom = normRect.bottom * imageDisplaySize.height;
    final rect = Rect.fromLTRB(left, top, right, bottom);

    // Semi-transparent cyan fill
    final fillPaint = Paint()
      ..color = const Color(0xFF00F0FF).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    // Dashed / solid border
    final borderPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * scale;
    canvas.drawRect(rect, borderPaint);

    // Dimension tooltip indicator
    final dimText = '${rect.width.round()} × ${rect.height.round()} px';
    final textSpan = TextSpan(
      text: dimText,
      style: TextStyle(
        color: Colors.white,
        fontSize: (11.0 * scale).clamp(9.0, 24.0),
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.black87,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas, Offset(rect.left + (4 * scale), rect.bottom + (4 * scale)));
  }

  void _drawCorners(Canvas canvas, Rect rect, Color color, bool isSelected, double scale) {
    final len = (isSelected ? 14.0 : 9.0) * scale;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (isSelected ? 3.5 : 2.5) * scale
      ..strokeCap = StrokeCap.square;

    // Top-left
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + len, rect.top), paint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left, rect.top + len), paint);

    // Top-right
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right - len, rect.top), paint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + len), paint);

    // Bottom-left
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + len, rect.bottom), paint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left, rect.bottom - len), paint);

    // Bottom-right
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right - len, rect.bottom), paint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right, rect.bottom - len), paint);
  }

  void _drawResizeHandles(Canvas canvas, Rect rect, Color color, double scale) {
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final handleBorder = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale;

    final size = 7.0 * scale;
    final points = [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
      Offset(rect.center.dx, rect.top),
      Offset(rect.center.dx, rect.bottom),
      Offset(rect.left, rect.center.dy),
      Offset(rect.right, rect.center.dy),
    ];

    for (final pt in points) {
      final handleRect = Rect.fromCenter(center: pt, width: size, height: size);
      canvas.drawRect(handleRect, handlePaint);
      canvas.drawRect(handleRect, handleBorder);
    }
  }

  void _drawBadge(
    Canvas canvas,
    Rect rect,
    String label,
    String? title,
    Color color,
    bool isSelected,
    double scale,
  ) {
    final textColor = AnnotationColorPalette.getContrastingTextColor(color);
    final fontSize = (13.0 * scale).clamp(10.0, 30.0);

    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: ' $label ',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        if (title != null && title.trim().isNotEmpty)
          TextSpan(
            text: ' ${title.trim()} ',
            style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: fontSize * 0.85,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );

    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    final paddingH = 6.0 * scale;
    final paddingV = 3.0 * scale;
    final badgeWidth = textPainter.width + (paddingH * 2);
    final badgeHeight = textPainter.height + (paddingV * 2);

    // Position badge
    double badgeLeft = rect.left;
    double badgeTop = rect.top - badgeHeight - (2.0 * scale);

    if (badgeTop < 2.0 * scale) {
      badgeTop = rect.top + (2.0 * scale);
      badgeLeft = rect.left + (2.0 * scale);
    }
    if (badgeLeft + badgeWidth > imageDisplaySize.width - (2.0 * scale)) {
      badgeLeft = imageDisplaySize.width - badgeWidth - (2.0 * scale);
    }
    if (badgeLeft < 2.0 * scale) badgeLeft = 2.0 * scale;

    final badgeRect = Rect.fromLTWH(badgeLeft, badgeTop, badgeWidth, badgeHeight);
    final badgeRRect = RRect.fromRectAndRadius(badgeRect, Radius.circular(4 * scale));

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black87
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.5 * scale);
    canvas.drawRRect(badgeRRect.shift(Offset(0, 1.5 * scale)), shadowPaint);

    // Background
    final bgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(badgeRRect, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.black38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale;
    canvas.drawRRect(badgeRRect, borderPaint);

    textPainter.paint(canvas, Offset(badgeLeft + paddingH, badgeTop + paddingV));
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) {
    return oldDelegate.annotations != annotations ||
        oldDelegate.selectedRegionId != selectedRegionId ||
        oldDelegate.activeDrawingRect != activeDrawingRect ||
        oldDelegate.imageDisplaySize != imageDisplaySize ||
        oldDelegate.showTitles != showTitles;
  }
}

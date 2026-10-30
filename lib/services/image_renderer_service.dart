import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/image_item.dart';
import '../models/annotation_region.dart';
import '../utils/color_palette.dart';

class ImageRendererService {
  /// Render high-resolution annotated image with all bounding boxes and badges burned in
  static Future<Uint8List> renderAnnotatedImage({
    required ImageItem imageItem,
    bool showTitlesInBadges = true,
    double strokeWidth = 3.0,
    double badgeScale = 1.0,
  }) async {
    final ui.Image baseImage = imageItem.decodedImage;
    final int imgWidth = baseImage.width;
    final int imgHeight = baseImage.height;
    final Size imgSize = Size(imgWidth.toDouble(), imgHeight.toDouble());

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, imgWidth.toDouble(), imgHeight.toDouble()));

    // 1. Draw base image
    canvas.drawImage(baseImage, Offset.zero, Paint());

    // Scale factors relative to typical 1080p resolution so badges don't look tiny on 4K or huge on 720p
    final double baseDimension = (imgWidth + imgHeight) / 2.0;
    final double scale = (baseDimension / 1200.0).clamp(0.8, 3.5) * badgeScale;

    // 2. Draw annotations
    for (final ann in imageItem.annotations) {
      final pixelRect = ann.toPixelRect(imgSize);
      final Color color = ann.color;

      // Fill area with subtle tint
      final fillPaint = Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(pixelRect, Radius.circular(6 * scale)), fillPaint);

      // Outer Glow / Shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (strokeWidth + 2.0) * scale;
      canvas.drawRRect(RRect.fromRectAndRadius(pixelRect, Radius.circular(6 * scale)), shadowPaint);

      // Main Bounding Box Border
      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * scale;
      canvas.drawRRect(RRect.fromRectAndRadius(pixelRect, Radius.circular(6 * scale)), borderPaint);

      // Corner Accents (cyberpunk/pro visual cue)
      _drawCornerBrackets(canvas, pixelRect, color, scale);

      // Draw Badge Tag (e.g. "[ L43 ]" + Optional Title)
      _drawBadgeTag(
        canvas: canvas,
        pixelRect: pixelRect,
        imageSize: imgSize,
        label: ann.label,
        title: showTitlesInBadges && ann.title.isNotEmpty ? ann.title : null,
        badgeColor: color,
        scale: scale,
      );
    }

    final picture = recorder.endRecording();
    final renderedImage = await picture.toImage(imgWidth, imgHeight);
    final byteData = await renderedImage.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static void _drawCornerBrackets(Canvas canvas, Rect rect, Color color, double scale) {
    final bracketLen = (14.0 * scale).clamp(8.0, 30.0);
    final bracketPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale
      ..strokeCap = StrokeCap.round;

    // Top-Left
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + bracketLen, rect.top), bracketPaint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left, rect.top + bracketLen), bracketPaint);

    // Top-Right
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right - bracketLen, rect.top), bracketPaint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + bracketLen), bracketPaint);

    // Bottom-Left
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + bracketLen, rect.bottom), bracketPaint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left, rect.bottom - bracketLen), bracketPaint);

    // Bottom-Right
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right - bracketLen, rect.bottom), bracketPaint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right - bracketLen, rect.bottom), bracketPaint);
  }

  static void _drawBadgeTag({
    required Canvas canvas,
    required Rect pixelRect,
    required Size imageSize,
    required String label,
    required String? title,
    required Color badgeColor,
    required double scale,
  }) {
    final textColor = AnnotationColorPalette.getContrastingTextColor(badgeColor);
    final fontSize = (14.0 * scale).clamp(11.0, 32.0);

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

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final paddingH = 6.0 * scale;
    final paddingV = 4.0 * scale;
    final badgeWidth = textPainter.width + (paddingH * 2);
    final badgeHeight = textPainter.height + (paddingV * 2);

    // Position badge: slightly above top-left of the box, or inside if too close to edge
    double badgeLeft = pixelRect.left;
    double badgeTop = pixelRect.top - badgeHeight - (2.0 * scale);

    if (badgeTop < 4.0) {
      // Place inside the box if off-screen
      badgeTop = pixelRect.top + (3.0 * scale);
      badgeLeft = pixelRect.left + (3.0 * scale);
    }
    if (badgeLeft + badgeWidth > imageSize.width - 4.0) {
      badgeLeft = imageSize.width - badgeWidth - 4.0;
    }
    if (badgeLeft < 4.0) badgeLeft = 4.0;

    final badgeRect = Rect.fromLTWH(badgeLeft, badgeTop, badgeWidth, badgeHeight);
    final badgeRRect = RRect.fromRectAndRadius(badgeRect, Radius.circular(5 * scale));

    // Badge Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * scale);
    canvas.drawRRect(badgeRRect.shift(Offset(0, 2 * scale)), shadowPaint);

    // Badge Background
    final bgPaint = Paint()
      ..color = badgeColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(badgeRRect, bgPaint);

    // Badge Dark Border
    final badgeBorderPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale;
    canvas.drawRRect(badgeRRect, badgeBorderPaint);

    // Paint Text
    textPainter.paint(canvas, Offset(badgeLeft + paddingH, badgeTop + paddingV));
  }
}

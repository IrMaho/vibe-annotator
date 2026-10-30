import 'package:flutter/material.dart';

class AnnotationColorPalette {
  static const List<Color> labelColors = [
    Color(0xFFE11D48), // Sport Crimson Red (Signature)
    Color(0xFF0F172A), // Carbon Black
    Color(0xFF2563EB), // Sport Cobalt Blue
    Color(0xFF059669), // Racing Emerald
    Color(0xFFD97706), // Turbo Amber
    Color(0xFF7C3AED), // Hyper Violet
    Color(0xFF0284C7), // Sky Cyan
    Color(0xFFE11D48), // Crimson
    Color(0xFF475569), // Slate Titanium
    Color(0xFFEA580C), // Blaze Orange
  ];

  static Color getColorForIndex(int index) {
    return labelColors[index % labelColors.length];
  }

  /// Calculates whether text on top of this color should be black or white for maximum readability
  static Color getContrastingTextColor(Color background) {
    final double luminance = background.computeLuminance();
    return luminance > 0.45 ? Colors.black : Colors.white;
  }
}

import 'package:flutter/material.dart';

class SportTheme {
  // --- Backgrounds & Neutrals ---
  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubdued = Color(0xFFF1F5F9);
  static const Color canvasBg = Color(0xFFEEF2F6);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFEDF2F7);

  // --- Sport Accents: Racing Crimson Red ---
  static const Color primaryRed = Color(0xFFE11D48); // Electric Crimson
  static const Color primaryRedDark = Color(0xFFBE123C);
  static const Color primaryRedLight = Color(0xFFFFE4E6); // Rose tint
  static const Color primaryRedUltraLight = Color(0xFFFFF1F2);

  // --- Primary Dark: Carbon Black & Slate ---
  static const Color carbonBlack = Color(0xFF090D16);
  static const Color carbonCard = Color(0xFF131A29);
  static const Color carbonDark = Color(0xFF0F172A);
  static const Color carbonMedium = Color(0xFF1E293B);
  static const Color slate = Color(0xFF64748B);
  static const Color slateLight = Color(0xFF94A3B8);

  // --- Gradients ---
  static const LinearGradient redSportGradient = LinearGradient(
    colors: [Color(0xFFFF2A55), Color(0xFFD90429)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient carbonGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softRedFade = LinearGradient(
    colors: [Color(0xFFFFEEF2), Color(0x00FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient topBarBorderFade = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0x33E11D48), Color(0x00E11D48)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // --- Box Shadows ---
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get redGlowShadow => [
        BoxShadow(
          color: primaryRed.withOpacity(0.35),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get subtleGlow => [
        BoxShadow(
          color: primaryRed.withOpacity(0.12),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
}

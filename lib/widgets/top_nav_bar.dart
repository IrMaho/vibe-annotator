import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../utils/theme.dart';

class TopNavBar extends StatelessWidget {
  final AppState appState;
  final VoidCallback onShowHelp;

  const TopNavBar({
    super.key,
    required this.appState,
    required this.onShowHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: SportTheme.surface,
        border: Border(
          bottom: BorderSide(color: SportTheme.border, width: 1.0),
        ),
      ),
      child: Stack(
        children: [
          // Subtle Red Fade Accent Line at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            child: Container(
              height: 2.0,
              decoration: const BoxDecoration(
                gradient: SportTheme.topBarBorderFade,
              ),
            ),
          ),

          // Main Row Contents
          Row(
            children: [
              // Sport Brand Logo & Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: SportTheme.redSportGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: SportTheme.subtleGlow,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'VIBE',
                            style: TextStyle(
                              color: SportTheme.primaryRed,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'ANNOTATOR',
                            style: TextStyle(
                              color: SportTheme.carbonDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: SportTheme.carbonBlack,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SPORT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Visual Agent Prompting Studio',
                        style: TextStyle(
                          color: SportTheme.slate,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(width: 24),
              Container(height: 22, width: 1, color: SportTheme.border),
              const SizedBox(width: 20),

              // Action: Paste Screenshot Button (High Visibility Sport Red)
              ElevatedButton.icon(
                icon: const Icon(Icons.paste_rounded, size: 16),
                label: const Text(
                  'Paste Screenshot (Ctrl+V)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, letterSpacing: 0.3),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SportTheme.primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: SportTheme.primaryRed.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final ok = await appState.pasteFromClipboard();
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'هیچ تصویری در کلیپ‌بورد پیدا نشد! ابتدا Win+Shift+S یا PrintScreen بزنید.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: SportTheme.carbonBlack,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 10),

              // Open File Button (Sport Carbon Outline)
              OutlinedButton.icon(
                icon: const Icon(Icons.file_open_outlined, size: 15, color: SportTheme.carbonDark),
                label: const Text(
                  'Open Image',
                  style: TextStyle(color: SportTheme.carbonDark, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: SportTheme.border, width: 1.2),
                  backgroundColor: SportTheme.surfaceSubdued,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => appState.pickImageFromFile(),
              ),

              const Spacer(),

              // Status feedback chip (if any)
              if (appState.statusMessage != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SportTheme.primaryRedUltraLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: SportTheme.primaryRedLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: SportTheme.primaryRed),
                      const SizedBox(width: 6),
                      Text(
                        appState.statusMessage!,
                        style: const TextStyle(
                          color: SportTheme.primaryRed,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Help / Shortcuts button
              IconButton(
                icon: const Icon(Icons.help_outline_rounded, size: 20),
                color: SportTheme.carbonDark,
                tooltip: 'راهنمای وایب‌کدینگ و کلیدها',
                splashRadius: 18,
                onPressed: onShowHelp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

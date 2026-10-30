import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../utils/theme.dart';

class CanvasToolbar extends StatelessWidget {
  final CanvasInteractionMode currentMode;
  final ValueChanged<CanvasInteractionMode> onModeChanged;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;
  final VoidCallback onFitToScreen;
  final double currentZoom;
  final bool showTitles;
  final VoidCallback onToggleTitles;
  final VoidCallback onClearAll;

  const CanvasToolbar({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
    required this.onFitToScreen,
    required this.currentZoom,
    required this.showTitles,
    required this.onToggleTitles,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SportTheme.carbonBlack.withOpacity(0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: SportTheme.carbonBlack.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolButton(
            icon: Icons.crop_square_rounded,
            tooltip: 'Draw Bounding Box (R)',
            isActive: currentMode == CanvasInteractionMode.drawBox,
            onPressed: () => onModeChanged(CanvasInteractionMode.drawBox),
          ),
          const SizedBox(width: 4),
          _buildToolButton(
            icon: Icons.near_me_rounded,
            tooltip: 'Select & Move (V)',
            isActive: currentMode == CanvasInteractionMode.select,
            onPressed: () => onModeChanged(CanvasInteractionMode.select),
          ),
          const SizedBox(width: 4),
          _buildToolButton(
            icon: Icons.pan_tool_rounded,
            tooltip: 'Pan & Zoom (H) [یا Space]',
            isActive: currentMode == CanvasInteractionMode.pan,
            onPressed: () => onModeChanged(CanvasInteractionMode.pan),
          ),
          _buildDivider(),
          _buildIconButton(
            icon: Icons.remove_rounded,
            tooltip: 'Zoom Out',
            onPressed: onZoomOut,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${(currentZoom * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _buildIconButton(
            icon: Icons.add_rounded,
            tooltip: 'Zoom In',
            onPressed: onZoomIn,
          ),
          _buildIconButton(
            icon: Icons.fit_screen_rounded,
            tooltip: 'Fit to View',
            onPressed: onFitToScreen,
          ),
          _buildIconButton(
            icon: Icons.zoom_in_map_rounded,
            tooltip: 'Actual Size (100%)',
            onPressed: onResetZoom,
          ),
          _buildDivider(),
          _buildToolButton(
            icon: showTitles ? Icons.subtitles_rounded : Icons.subtitles_off_outlined,
            tooltip: showTitles ? 'Hide Titles in Badges' : 'Show Titles in Badges',
            isActive: showTitles,
            onPressed: onToggleTitles,
          ),
          const SizedBox(width: 4),
          _buildIconButton(
            icon: Icons.delete_sweep_rounded,
            tooltip: 'Clear All Annotations',
            color: SportTheme.primaryRed,
            onPressed: onClearAll,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 20,
      width: 1,
      color: Colors.white.withOpacity(0.18),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: isActive ? SportTheme.redSportGradient : null,
              color: isActive ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isActive ? SportTheme.subtleGlow : null,
            ),
            child: Icon(
              icon,
              size: 19,
              color: isActive ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 18, color: color ?? Colors.white70),
        splashRadius: 18,
        padding: const EdgeInsets.all(7),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: onPressed,
      ),
    );
  }
}

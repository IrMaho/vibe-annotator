import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/image_item.dart';
import '../../state/app_state.dart';
import 'annotation_painter.dart';
import 'canvas_toolbar.dart';
import '../../utils/theme.dart';

class AnnotationCanvas extends StatefulWidget {
  final ImageItem imageItem;
  final AppState appState;

  const AnnotationCanvas({
    super.key,
    required this.imageItem,
    required this.appState,
  });

  @override
  State<AnnotationCanvas> createState() => _AnnotationCanvasState();
}

class _AnnotationCanvasState extends State<AnnotationCanvas> {
  final TransformationController _transController = TransformationController();
  final FocusNode _focusNode = FocusNode();

  Offset? _dragStart;
  Offset? _dragCurrent;
  Rect? _activeDrawingRect; // in natural image pixel space

  // Dragging/resizing existing region
  String? _draggingRegionId;
  Rect? _initialRegionRect;
  Offset? _initialMousePos;

  double _currentScale = 1.0;
  bool _isSpacePressed = false;
  String? _lastFittedImageId;
  Size? _lastViewportSize;

  @override
  void initState() {
    super.initState();
    _transController.addListener(_onTransformUpdated);
  }

  @override
  void dispose() {
    _transController.removeListener(_onTransformUpdated);
    _transController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTransformUpdated() {
    final scale = _transController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.01) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  void _zoomIn(Size viewportSize) {
    final center = Offset(viewportSize.width / 2, viewportSize.height / 2);
    _zoomAt(center, 1.25);
  }

  void _zoomOut(Size viewportSize) {
    final center = Offset(viewportSize.width / 2, viewportSize.height / 2);
    _zoomAt(center, 0.8);
  }

  void _zoomAt(Offset focalPoint, double scaleFactor) {
    final matrix = _transController.value.clone();
    final translation = matrix.getTranslation();
    final currentScale = matrix.getMaxScaleOnAxis();
    final newScale = (currentScale * scaleFactor).clamp(0.05, 10.0);
    final actualFactor = newScale / currentScale;

    final newMatrix = Matrix4.identity()
      ..translate(
        focalPoint.dx - (focalPoint.dx - translation.x) * actualFactor,
        focalPoint.dy - (focalPoint.dy - translation.y) * actualFactor,
      )
      ..scale(newScale, newScale);
    _transController.value = newMatrix;
  }

  void _resetZoom(Size viewportSize, Size imageSize) {
    final dx = (viewportSize.width - imageSize.width) / 2;
    final dy = (viewportSize.height - imageSize.height) / 2;
    _transController.value = Matrix4.identity()..translate(dx, dy);
  }

  void _fitToScreen(Size viewportSize, Size imageSize) {
    if (imageSize.width <= 0 || imageSize.height <= 0 || viewportSize.width <= 0 || viewportSize.height <= 0) return;

    const padding = 48.0;
    final availW = math.max(100.0, viewportSize.width - padding);
    final availH = math.max(100.0, viewportSize.height - padding);

    final scaleX = availW / imageSize.width;
    final scaleY = availH / imageSize.height;
    final fitScale = math.min(scaleX, scaleY).clamp(0.05, 5.0);

    final dx = (viewportSize.width - (imageSize.width * fitScale)) / 2;
    final dy = (viewportSize.height - (imageSize.height * fitScale)) / 2;

    _transController.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(fitScale, fitScale);
  }

  @override
  Widget build(BuildContext context) {
    final img = widget.imageItem;
    final imgSize = Size(img.width.toDouble(), img.height.toDouble());

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Auto-fit when image changes or on initial layout
        if (_lastFittedImageId != widget.imageItem.id) {
          _lastFittedImageId = widget.imageItem.id;
          _lastViewportSize = viewportSize;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _fitToScreen(viewportSize, imgSize);
            }
          });
        }

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.space && !_isSpacePressed) {
                setState(() => _isSpacePressed = true);
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.delete ||
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                if (widget.appState.selectedRegionId != null) {
                  widget.appState.deleteAnnotation(widget.appState.selectedRegionId!);
                  return KeyEventResult.handled;
                }
              } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                widget.appState.selectRegion(null);
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
                widget.appState.setInteractionMode(CanvasInteractionMode.drawBox);
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.keyV) {
                widget.appState.setInteractionMode(CanvasInteractionMode.select);
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
                widget.appState.setInteractionMode(CanvasInteractionMode.pan);
                return KeyEventResult.handled;
              }
            } else if (event is KeyUpEvent) {
              if (event.logicalKey == LogicalKeyboardKey.space && _isSpacePressed) {
                setState(() => _isSpacePressed = false);
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Stack(
            children: [
              // Canvas Background Grid
              Positioned.fill(
                child: Container(
                  color: SportTheme.canvasBg,
                  child: CustomPaint(
                    painter: _CanvasGridPainter(),
                  ),
                ),
              ),

              // Interactive Viewport with constrained: false
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transController,
                  constrained: false, // CRITICAL: child is allowed its true natural image resolution
                  minScale: 0.05,
                  maxScale: 10.0,
                  panEnabled: _isSpacePressed || widget.appState.interactionMode == CanvasInteractionMode.pan,
                  scaleEnabled: true,
                  boundaryMargin: EdgeInsets.all(math.max(viewportSize.width, viewportSize.height)),
                  child: MouseRegion(
                    cursor: _getCursorForMode(),
                    child: Listener(
                      onPointerDown: (event) => _onPointerDown(event, imgSize),
                      onPointerMove: (event) => _onPointerMove(event, imgSize),
                      onPointerUp: (event) => _onPointerUp(event, imgSize),
                      child: Container(
                        width: imgSize.width,
                        height: imgSize.height,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: SportTheme.carbonBlack.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Raw Image rendered at 100% natural resolution
                            Image.memory(
                              img.rawBytes,
                              width: imgSize.width,
                              height: imgSize.height,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.high,
                            ),

                            // Interactive Drawing and Labels Overlay
                            CustomPaint(
                              size: imgSize,
                              painter: AnnotationPainter(
                                annotations: img.annotations,
                                selectedRegionId: widget.appState.selectedRegionId,
                                activeDrawingRect: _activeDrawingRect != null
                                    ? Rect.fromLTRB(
                                        (_activeDrawingRect!.left / imgSize.width).clamp(0.0, 1.0),
                                        (_activeDrawingRect!.top / imgSize.height).clamp(0.0, 1.0),
                                        (_activeDrawingRect!.right / imgSize.width).clamp(0.0, 1.0),
                                        (_activeDrawingRect!.bottom / imgSize.height).clamp(0.0, 1.0),
                                      )
                                    : null,
                                imageDisplaySize: imgSize,
                                showTitles: widget.appState.showTitlesInBadges,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Canvas Toolbar at bottom-center
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: CanvasToolbar(
                    currentMode: widget.appState.interactionMode,
                    onModeChanged: widget.appState.setInteractionMode,
                    onZoomIn: () => _zoomIn(viewportSize),
                    onZoomOut: () => _zoomOut(viewportSize),
                    onResetZoom: () => _resetZoom(viewportSize, imgSize),
                    onFitToScreen: () => _fitToScreen(viewportSize, imgSize),
                    currentZoom: _currentScale,
                    showTitles: widget.appState.showTitlesInBadges,
                    onToggleTitles: widget.appState.toggleShowTitlesInBadges,
                    onClearAll: () => widget.imageItem.clearAnnotations(),
                  ),
                ),
              ),

              // Quick Help Pill top-left
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: SportTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SportTheme.border),
                    boxShadow: SportTheme.cardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 15, color: SportTheme.primaryRed),
                      const SizedBox(width: 7),
                      Text(
                        _getModeHelpText(),
                        style: const TextStyle(
                          color: SportTheme.carbonDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  MouseCursor _getCursorForMode() {
    if (_isSpacePressed || widget.appState.interactionMode == CanvasInteractionMode.pan) {
      return SystemMouseCursors.grab;
    }
    switch (widget.appState.interactionMode) {
      case CanvasInteractionMode.drawBox:
        return SystemMouseCursors.precise;
      case CanvasInteractionMode.select:
        return SystemMouseCursors.basic;
      case CanvasInteractionMode.pan:
        return SystemMouseCursors.grab;
    }
  }

  String _getModeHelpText() {
    if (_isSpacePressed) {
      return 'Hold Space to pan • Release to return to tool';
    }
    switch (widget.appState.interactionMode) {
      case CanvasInteractionMode.drawBox:
        return 'Click & drag on image to mark a region [L#]';
      case CanvasInteractionMode.select:
        return 'Click an annotation to edit, move, or resize';
      case CanvasInteractionMode.pan:
        return 'Drag to pan canvas • Scroll wheel to zoom';
    }
  }

  void _onPointerDown(PointerDownEvent event, Size imgSize) {
    _focusNode.requestFocus();
    if (_isSpacePressed || widget.appState.interactionMode == CanvasInteractionMode.pan) {
      return;
    }

    final pxX = event.localPosition.dx.clamp(0.0, imgSize.width);
    final pxY = event.localPosition.dy.clamp(0.0, imgSize.height);
    final localPos = Offset(pxX, pxY);

    if (widget.appState.interactionMode == CanvasInteractionMode.drawBox) {
      setState(() {
        _dragStart = localPos;
        _dragCurrent = localPos;
        _activeDrawingRect = Rect.fromPoints(localPos, localPos);
      });
    } else if (widget.appState.interactionMode == CanvasInteractionMode.select) {
      final annotations = widget.imageItem.annotations;
      String? hitId;
      for (int i = annotations.length - 1; i >= 0; i--) {
        final ann = annotations[i];
        final pxRect = ann.toPixelRect(imgSize);
        if (pxRect.inflate(12.0).contains(localPos)) {
          hitId = ann.id;
          _draggingRegionId = ann.id;
          _initialRegionRect = pxRect;
          _initialMousePos = localPos;
          break;
        }
      }

      widget.appState.selectRegion(hitId);
    }
  }

  void _onPointerMove(PointerMoveEvent event, Size imgSize) {
    if (_isSpacePressed || widget.appState.interactionMode == CanvasInteractionMode.pan) {
      return;
    }

    final pxX = event.localPosition.dx.clamp(0.0, imgSize.width);
    final pxY = event.localPosition.dy.clamp(0.0, imgSize.height);
    final localPos = Offset(pxX, pxY);

    if (widget.appState.interactionMode == CanvasInteractionMode.drawBox && _dragStart != null) {
      setState(() {
        _dragCurrent = localPos;
        _activeDrawingRect = Rect.fromPoints(_dragStart!, _dragCurrent!);
      });
    } else if (widget.appState.interactionMode == CanvasInteractionMode.select &&
        _draggingRegionId != null &&
        _initialRegionRect != null &&
        _initialMousePos != null) {
      final delta = localPos - _initialMousePos!;
      final newPxRect = _initialRegionRect!.shift(delta);

      final clampedRect = Rect.fromLTRB(
        newPxRect.left.clamp(0.0, imgSize.width - 5),
        newPxRect.top.clamp(0.0, imgSize.height - 5),
        newPxRect.right.clamp(5.0, imgSize.width),
        newPxRect.bottom.clamp(5.0, imgSize.height),
      );

      final selected = widget.appState.selectedRegion;
      if (selected != null && selected.id == _draggingRegionId) {
        final updatedNorm = Rect.fromLTRB(
          clampedRect.left / imgSize.width,
          clampedRect.top / imgSize.height,
          clampedRect.right / imgSize.width,
          clampedRect.bottom / imgSize.height,
        );
        widget.appState.updateAnnotation(selected.copyWith(normalizedRect: updatedNorm));
      }
    }
  }

  void _onPointerUp(PointerUpEvent event, Size imgSize) {
    if (widget.appState.interactionMode == CanvasInteractionMode.drawBox && _activeDrawingRect != null) {
      final rect = _activeDrawingRect!;
      final l = (math.min(rect.left, rect.right) / imgSize.width).clamp(0.0, 1.0);
      final t = (math.min(rect.top, rect.bottom) / imgSize.height).clamp(0.0, 1.0);
      final r = (math.max(rect.left, rect.right) / imgSize.width).clamp(0.0, 1.0);
      final b = (math.max(rect.top, rect.bottom) / imgSize.height).clamp(0.0, 1.0);

      final normRect = Rect.fromLTRB(l, t, r, b);

      setState(() {
        _dragStart = null;
        _dragCurrent = null;
        _activeDrawingRect = null;
      });

      widget.appState.addAnnotationFromRect(normRect);
    }

    _draggingRegionId = null;
    _initialRegionRect = null;
    _initialMousePos = null;
  }
}

class _CanvasGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF64748B).withOpacity(0.18)
      ..style = PaintingStyle.fill;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

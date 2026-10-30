import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'annotation_region.dart';

class ImageItem {
  final String id;
  String name;
  final Uint8List rawBytes;
  final int width;
  final int height;
  final ui.Image decodedImage;
  List<AnnotationRegion> annotations;
  String globalGoal;
  final DateTime importedAt;

  ImageItem({
    required this.id,
    required this.name,
    required this.rawBytes,
    required this.width,
    required this.height,
    required this.decodedImage,
    List<AnnotationRegion>? annotations,
    this.globalGoal = '',
    DateTime? importedAt,
  })  : annotations = annotations ?? [],
        importedAt = importedAt ?? DateTime.now();

  Size get size => Size(width.toDouble(), height.toDouble());
  double get aspectRatio => width > 0 && height > 0 ? width / height : 1.0;

  /// Generate next label for this image (e.g. "L1", "L2", ...)
  String getNextLabel() {
    int maxIndex = 0;
    final regex = RegExp(r'^L(\d+)$', caseSensitive: false);
    for (final ann in annotations) {
      final match = regex.firstMatch(ann.label.trim());
      if (match != null) {
        final val = int.tryParse(match.group(1) ?? '') ?? 0;
        if (val > maxIndex) {
          maxIndex = val;
        }
      }
    }
    return 'L${maxIndex + 1}';
  }

  void addAnnotation(AnnotationRegion region) {
    annotations.add(region);
  }

  void removeAnnotation(String regionId) {
    annotations.removeWhere((ann) => ann.id == regionId);
  }

  void updateAnnotation(AnnotationRegion updated) {
    final idx = annotations.indexWhere((ann) => ann.id == updated.id);
    if (idx != -1) {
      annotations[idx] = updated;
    }
  }

  void clearAnnotations() {
    annotations.clear();
  }
}

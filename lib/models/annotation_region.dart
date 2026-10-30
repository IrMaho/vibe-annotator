import 'dart:ui';
import 'package:flutter/material.dart';

enum RegionCategory {
  uiUx('UI/UX Design', Icons.design_services),
  styling('Styling & Colors', Icons.palette_outlined),
  bugFix('Bug Fix', Icons.bug_report_outlined),
  feature('New Feature', Icons.add_circle_outline),
  content('Content / Text', Icons.text_fields),
  refactor('Refactor / Logic', Icons.code);

  final String label;
  final IconData icon;
  const RegionCategory(this.label, this.icon);
}

enum RegionPriority {
  low('Low', Colors.blueGrey),
  medium('Medium', Colors.amber),
  high('High', Colors.deepOrange),
  critical('Critical 🔥', Colors.redAccent);

  final String label;
  final Color color;
  const RegionPriority(this.label, this.color);
}

class AnnotationRegion {
  final String id;
  final String label; // e.g. "L1", "L43"
  final Rect normalizedRect; // 0.0 -> 1.0 (left, top, right, bottom)
  final Color color;
  final String title;
  final String comment;
  final RegionCategory category;
  final RegionPriority priority;
  final DateTime createdAt;

  AnnotationRegion({
    required this.id,
    required this.label,
    required this.normalizedRect,
    required this.color,
    this.title = '',
    this.comment = '',
    this.category = RegionCategory.uiUx,
    this.priority = RegionPriority.medium,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert normalized Rect (0..1) to actual pixel bounds based on original image size
  Rect toPixelRect(Size imageSize) {
    return Rect.fromLTRB(
      (normalizedRect.left * imageSize.width).clamp(0.0, imageSize.width),
      (normalizedRect.top * imageSize.height).clamp(0.0, imageSize.height),
      (normalizedRect.right * imageSize.width).clamp(0.0, imageSize.width),
      (normalizedRect.bottom * imageSize.height).clamp(0.0, imageSize.height),
    );
  }

  /// Normalized [ymin, xmin, ymax, xmax] scaled to 0-1000 (standard for multimodal AI vision)
  List<int> toNormalized1000() {
    return [
      (normalizedRect.top * 1000).round().clamp(0, 1000),
      (normalizedRect.left * 1000).round().clamp(0, 1000),
      (normalizedRect.bottom * 1000).round().clamp(0, 1000),
      (normalizedRect.right * 1000).round().clamp(0, 1000),
    ];
  }

  /// Human-readable spatial location description (e.g. "Top-Right", "Bottom-Center")
  String getSpatialLocation() {
    final cx = (normalizedRect.left + normalizedRect.right) / 2.0;
    final cy = (normalizedRect.top + normalizedRect.bottom) / 2.0;

    String vertical;
    if (cy < 0.33) {
      vertical = 'Top';
    } else if (cy < 0.66) {
      vertical = 'Center / Middle';
    } else {
      vertical = 'Bottom';
    }

    String horizontal;
    if (cx < 0.33) {
      horizontal = 'Left';
    } else if (cx < 0.66) {
      horizontal = cx < 0.4 ? 'Center-Left' : (cx > 0.6 ? 'Center-Right' : 'Center');
    } else {
      horizontal = 'Right';
    }

    if (vertical == 'Center / Middle' && horizontal == 'Center') {
      return 'Center Area';
    }
    return '$vertical-$horizontal';
  }

  AnnotationRegion copyWith({
    String? id,
    String? label,
    Rect? normalizedRect,
    Color? color,
    String? title,
    String? comment,
    RegionCategory? category,
    RegionPriority? priority,
  }) {
    return AnnotationRegion(
      id: id ?? this.id,
      label: label ?? this.label,
      normalizedRect: normalizedRect ?? this.normalizedRect,
      color: color ?? this.color,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson(Size? imageSize) {
    final pixelRect = imageSize != null ? toPixelRect(imageSize) : null;
    return {
      'id': id,
      'label': label,
      'title': title,
      'comment': comment,
      'category': category.name,
      'priority': priority.name,
      'location_hint': getSpatialLocation(),
      'normalized_box_1000': toNormalized1000(),
      'normalized_rect': {
        'left': normalizedRect.left,
        'top': normalizedRect.top,
        'right': normalizedRect.right,
        'bottom': normalizedRect.bottom,
        'width': normalizedRect.width,
        'height': normalizedRect.height,
      },
      if (pixelRect != null)
        'pixel_rect': {
          'x': pixelRect.left.round(),
          'y': pixelRect.top.round(),
          'width': pixelRect.width.round(),
          'height': pixelRect.height.round(),
        },
    };
  }
}

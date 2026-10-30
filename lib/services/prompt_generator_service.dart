import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/image_item.dart';
import '../models/annotation_region.dart';
import '../models/prompt_template.dart';

class PromptGeneratorService {
  /// Generate prompt for a single active image
  static String generatePrompt({
    required ImageItem image,
    required PromptTemplateType templateType,
    String? customInstructions,
  }) {
    switch (templateType) {
      case PromptTemplateType.vibeCodingStandard:
        return _buildVibeCodingStandard(image, customInstructions);
      case PromptTemplateType.compactVision:
        return _buildCompactVision(image, customInstructions);
      case PromptTemplateType.checklist:
        return _buildChecklist(image, customInstructions);
      case PromptTemplateType.json:
        return _buildJson(image);
    }
  }

  /// Generate combined prompt for all loaded images
  static String generateMultiImagePrompt({
    required List<ImageItem> images,
    required PromptTemplateType templateType,
    String? overallGoal,
  }) {
    if (images.isEmpty) return 'No images loaded.';
    if (images.length == 1) {
      return generatePrompt(image: images.first, templateType: templateType, customInstructions: overallGoal);
    }

    final buffer = StringBuffer();
    buffer.writeln('# 🎯 Multi-Screen Visual Instructions for AI Agent');
    if (overallGoal != null && overallGoal.trim().isNotEmpty) {
      buffer.writeln('**Overall Project Objective:** ${overallGoal.trim()}\n');
    }
    buffer.writeln('I have attached ${images.length} annotated screenshots with coordinate-tagged labels `[L1]`, `[L2]`, etc.\n');

    for (int i = 0; i < images.length; i++) {
      final img = images[i];
      buffer.writeln('---');
      buffer.writeln('## 🖼️ Screen ${i + 1}: "${img.name}" (${img.width}x${img.height}px)');
      buffer.writeln(generatePrompt(image: img, templateType: templateType));
      buffer.writeln();
    }

    return buffer.toString();
  }

  static String _buildVibeCodingStandard(ImageItem image, String? customInstructions) {
    final buffer = StringBuffer();
    buffer.writeln('# 🎨 Visual Feedback & Modification Guide for AI Agent');
    buffer.writeln('**Target Image:** "${image.name}" (${image.width} × ${image.height} px)');

    if (image.globalGoal.trim().isNotEmpty) {
      buffer.writeln('**Screen Goal:** ${image.globalGoal.trim()}');
    }
    if (customInstructions != null && customInstructions.trim().isNotEmpty) {
      buffer.writeln('**Context Note:** ${customInstructions.trim()}');
    }

    buffer.writeln('\nPlease inspect the attached image with annotated bounding boxes tagged with IDs like `[L1]`, `[L2]`, etc.');
    buffer.writeln('Below is the exact coordinate mapping and requirements for each labeled section:\n');

    if (image.annotations.isEmpty) {
      buffer.writeln('> ⚠️ No bounding box regions marked on this image yet. Please mark regions on the canvas.');
      return buffer.toString();
    }

    for (final ann in image.annotations) {
      final pixelRect = ann.toPixelRect(image.size);
      final bbox1000 = ann.toNormalized1000();

      buffer.writeln('### 🏷️ Marker `[${ann.label}]` ${ann.title.isNotEmpty ? ": ${ann.title}" : ""}');
      buffer.writeln('- **General Position:** ${ann.getSpatialLocation()}');
      buffer.writeln('- **Pixel Coordinates:** x: ${pixelRect.left.round()}, y: ${pixelRect.top.round()}, width: ${pixelRect.width.round()}, height: ${pixelRect.height.round()}');
      buffer.writeln('- **Normalized BBox (0-1000):** `[ymin: ${bbox1000[0]}, xmin: ${bbox1000[1]}, ymax: ${bbox1000[2]}, xmax: ${bbox1000[3]}]`');
      buffer.writeln('- **Category:** ${ann.category.label}');
      buffer.writeln('- **Priority:** ${ann.priority.label}');
      buffer.writeln('- **Requested Change / Comment:**');
      if (ann.comment.trim().isNotEmpty) {
        final lines = ann.comment.trim().split('\n');
        for (final line in lines) {
          buffer.writeln('  > $line');
        }
      } else {
        buffer.writeln('  > *(No specific comment provided - inspect visual change required)*');
      }
      buffer.writeln();
    }

    buffer.writeln('---');
    buffer.writeln('**Instructions for Agent:**');
    buffer.writeln('1. Cross-reference each marker tag `[L#]` against the visually stamped labels in the screenshot.');
    buffer.writeln('2. Apply the requested changes with high fidelity, maintaining clean code architecture and responsive layout.');
    buffer.writeln('3. Confirm completion of each marker tag when reporting back.');

    return buffer.toString();
  }

  static String _buildCompactVision(ImageItem image, String? customInstructions) {
    final buffer = StringBuffer();
    buffer.writeln('Refer to annotated image "${image.name}" (${image.width}x${image.height}):');
    if (image.globalGoal.trim().isNotEmpty) {
      buffer.writeln('Goal: ${image.globalGoal.trim()}');
    }
    buffer.writeln();

    for (final ann in image.annotations) {
      final bbox = ann.toNormalized1000();
      final title = ann.title.isNotEmpty ? ' (${ann.title})' : '';
      final comment = ann.comment.replaceAll('\n', ' ').trim();
      buffer.writeln('- [${ann.label}]$title @ [ymin:${bbox[0]}, xmin:${bbox[1]}, ymax:${bbox[2]}, xmax:${bbox[3]}] (${ann.getSpatialLocation()}): "$comment"');
    }
    return buffer.toString();
  }

  static String _buildChecklist(ImageItem image, String? customInstructions) {
    final buffer = StringBuffer();
    buffer.writeln('## 📋 Agent Action Checklist for "${image.name}":\n');
    for (final ann in image.annotations) {
      final title = ann.title.isNotEmpty ? ann.title : ann.getSpatialLocation();
      buffer.writeln('- [ ] **[${ann.label}] $title**');
      if (ann.comment.trim().isNotEmpty) {
        buffer.writeln('  - Requirement: ${ann.comment.trim()}');
      }
      buffer.writeln('  - Area: ${ann.getSpatialLocation()} | BBox: `${ann.toNormalized1000()}`');
    }
    return buffer.toString();
  }

  static String _buildJson(ImageItem image) {
    final map = {
      'screen_name': image.name,
      'resolution': {'width': image.width, 'height': image.height},
      'global_goal': image.globalGoal,
      'total_regions': image.annotations.length,
      'regions': image.annotations.map((a) => a.toJson(image.size)).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}

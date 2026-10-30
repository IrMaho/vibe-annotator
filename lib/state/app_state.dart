import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/image_item.dart';
import '../models/annotation_region.dart';
import '../models/prompt_template.dart';
import '../services/clipboard_service.dart';
import '../services/image_renderer_service.dart';
import '../services/prompt_generator_service.dart';
import '../utils/color_palette.dart';

enum CanvasInteractionMode {
  drawBox('Draw Box (R)', Icons.crop_square_rounded),
  select('Select & Move (V)', Icons.near_me_outlined),
  pan('Pan / Zoom (H)', Icons.pan_tool_outlined);

  final String label;
  final IconData icon;
  const CanvasInteractionMode(this.label, this.icon);
}

class AppState extends ChangeNotifier {
  static const _uuid = Uuid();

  final List<ImageItem> _images = [];
  int _activeImageIndex = 0;
  String? _selectedRegionId;

  CanvasInteractionMode _interactionMode = CanvasInteractionMode.drawBox;
  PromptTemplateType _templateType = PromptTemplateType.vibeCodingStandard;

  bool _isBusy = false;
  String? _statusMessage;
  bool _showTitlesInBadges = true;

  // Getters
  List<ImageItem> get images => _images;
  int get activeImageIndex => _activeImageIndex;
  ImageItem? get activeImage => _images.isNotEmpty && _activeImageIndex < _images.length
      ? _images[_activeImageIndex]
      : null;

  String? get selectedRegionId => _selectedRegionId;
  AnnotationRegion? get selectedRegion {
    final img = activeImage;
    if (img == null || _selectedRegionId == null) return null;
    try {
      return img.annotations.firstWhere((r) => r.id == _selectedRegionId);
    } catch (_) {
      return null;
    }
  }

  CanvasInteractionMode get interactionMode => _interactionMode;
  PromptTemplateType get templateType => _templateType;
  bool get isBusy => _isBusy;
  String? get statusMessage => _statusMessage;
  bool get showTitlesInBadges => _showTitlesInBadges;

  void setInteractionMode(CanvasInteractionMode mode) {
    _interactionMode = mode;
    notifyListeners();
  }

  void setTemplateType(PromptTemplateType type) {
    _templateType = type;
    notifyListeners();
  }

  void toggleShowTitlesInBadges() {
    _showTitlesInBadges = !_showTitlesInBadges;
    notifyListeners();
  }

  void selectRegion(String? id) {
    _selectedRegionId = id;
    notifyListeners();
  }

  void setActiveImageIndex(int index) {
    if (index >= 0 && index < _images.length) {
      _activeImageIndex = index;
      _selectedRegionId = null;
      notifyListeners();
    }
  }

  void closeImage(int index) {
    if (index >= 0 && index < _images.length) {
      _images.removeAt(index);
      if (_activeImageIndex >= _images.length) {
        _activeImageIndex = _images.isEmpty ? 0 : _images.length - 1;
      }
      _selectedRegionId = null;
      notifyListeners();
    }
  }

  // --- Clipboard / Image Input Actions ---

  Future<bool> pasteFromClipboard() async {
    _setBusy(true, 'Reading clipboard...');
    final img = await ClipboardService.pasteImageFromClipboard();
    _setBusy(false);

    if (img != null) {
      // Auto-name
      img.name = 'Screenshot ${_images.length + 1}';
      _images.add(img);
      _activeImageIndex = _images.length - 1;
      _selectedRegionId = null;
      _interactionMode = CanvasInteractionMode.drawBox;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> pickImageFromFile() async {
    _setBusy(true, 'Opening file...');
    final img = await ClipboardService.pickImageFromFile();
    _setBusy(false);

    if (img != null) {
      _images.add(img);
      _activeImageIndex = _images.length - 1;
      _selectedRegionId = null;
      _interactionMode = CanvasInteractionMode.drawBox;
      notifyListeners();
      return true;
    }
    return false;
  }

  void addSampleImage(ImageItem sample) {
    _images.add(sample);
    _activeImageIndex = _images.length - 1;
    _selectedRegionId = null;
    notifyListeners();
  }

  Future<void> loadDemoShowcase() async {
    _setBusy(true, 'Generating demo showcase...');
    try {
      const int w = 1200;
      const int h = 750;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 1200, 750));

      // Background
      final bgPaint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 1200, 750), bgPaint);

      // Sidebar
      final sidePaint = Paint()..color = const Color(0xFF1E293B);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 240, 750), sidePaint);

      // Sidebar Items
      final itemPaint = Paint()..color = const Color(0xFF334155);
      for (int i = 0; i < 5; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(20, 100.0 + (i * 60), 200, 40), const Radius.circular(8)),
          itemPaint,
        );
      }

      // Navbar
      canvas.drawRect(const Rect.fromLTWH(240, 0, 960, 70), Paint()..color = const Color(0xFF1E293B));

      // Dashboard Cards
      final cardPaint = Paint()..color = const Color(0xFF1E293B);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(270, 100, 280, 160), const Radius.circular(12)), cardPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(580, 100, 280, 160), const Radius.circular(12)), cardPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(890, 100, 280, 160), const Radius.circular(12)), cardPaint);

      // Main Chart Area
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(270, 290, 900, 420), const Radius.circular(12)), cardPaint);

      final picture = recorder.endRecording();
      final img = await picture.toImage(w, h);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final demoItem = await ClipboardService.createImageFromBytes(bytes, name: 'Sport UI Dashboard Demo');
      demoItem.globalGoal = 'طراحی اپ اسپورت با تم زمینه سفید، قرمز مسابقه‌ای و مشکی کربنی همراه با گرادیانت‌های نرم و فید.';

      // Pre-add sample annotations
      demoItem.addAnnotation(
        AnnotationRegion(
          id: _uuid.v4(),
          label: 'L1',
          normalizedRect: const Rect.fromLTWH(0.225, 0.133, 0.233, 0.213),
          color: const Color(0xFFE11D48),
          title: 'کارت متریک اسپورت',
          comment: 'افزودن گرادیانت نرم سفید به قرمز روشن، کانتر انیمیشنی درآمد و نمودار اسپارک‌لاین قرمز.',
          category: RegionCategory.uiUx,
          priority: RegionPriority.high,
        ),
      );

      demoItem.addAnnotation(
        AnnotationRegion(
          id: _uuid.v4(),
          label: 'L2',
          normalizedRect: const Rect.fromLTWH(0.225, 0.386, 0.75, 0.56),
          color: const Color(0xFF0F172A),
          title: 'نمودار پرفورمنس اصلی',
          comment: 'جایگزینی با چارت تعاملی با خط قرمز مسابقه‌ای، زمینه سفید و گرادیانت فید شونده زیر نمودار.',
          category: RegionCategory.feature,
          priority: RegionPriority.critical,
        ),
      );

      demoItem.addAnnotation(
        AnnotationRegion(
          id: _uuid.v4(),
          label: 'L3',
          normalizedRect: const Rect.fromLTWH(0.016, 0.133, 0.166, 0.4),
          color: const Color(0xFFE11D48),
          title: 'سایدبار ناوبری کربنی',
          comment: 'سایدبار با پس‌زمینه مشکی کربنی، آیکون‌های مینیمال سفید و نشانگر اکتیو قرمز با انیمیشن ترانزیشن نرم.',
          category: RegionCategory.styling,
          priority: RegionPriority.medium,
        ),
      );

      _images.add(demoItem);
      _activeImageIndex = _images.length - 1;
      _selectedRegionId = demoItem.annotations.first.id;
      _setBusy(false, 'Demo loaded! Check out the markers and generated prompt.');
      notifyListeners();
    } catch (e) {
      _setBusy(false, 'Failed to generate demo: $e');
    }
  }

  // --- Annotation Manipulation ---

  void addAnnotationFromRect(Rect normalizedRect) {
    final img = activeImage;
    if (img == null) return;

    // Reject tiny/accidental micro clicks (less than ~3px)
    if (normalizedRect.width < 0.002 && normalizedRect.height < 0.002) {
      return;
    }

    final newLabel = img.getNextLabel();
    final newColor = AnnotationColorPalette.getColorForIndex(img.annotations.length);

    final newRegion = AnnotationRegion(
      id: _uuid.v4(),
      label: newLabel,
      normalizedRect: normalizedRect,
      color: newColor,
      title: '',
      comment: '',
    );

    img.addAnnotation(newRegion);
    _selectedRegionId = newRegion.id;
    notifyListeners();
  }

  void updateAnnotation(AnnotationRegion updated) {
    final img = activeImage;
    if (img == null) return;
    img.updateAnnotation(updated);
    notifyListeners();
  }

  void deleteAnnotation(String id) {
    final img = activeImage;
    if (img == null) return;
    img.removeAnnotation(id);
    if (_selectedRegionId == id) {
      _selectedRegionId = null;
    }
    notifyListeners();
  }

  void updateGlobalGoal(String goal) {
    final img = activeImage;
    if (img == null) return;
    img.globalGoal = goal;
    notifyListeners();
  }

  // --- Export Actions ---

  Future<bool> copyAnnotatedImageToClipboard() async {
    final img = activeImage;
    if (img == null) return false;

    _setBusy(true, 'Rendering high-res annotated image...');
    try {
      final pngBytes = await ImageRendererService.renderAnnotatedImage(
        imageItem: img,
        showTitlesInBadges: _showTitlesInBadges,
      );
      await ClipboardService.copyImageToClipboard(pngBytes);
      _setBusy(false, 'Annotated image copied to clipboard! 📋');
      return true;
    } catch (e) {
      _setBusy(false, 'Failed to export image: $e');
      return false;
    }
  }

  Future<String?> saveAnnotatedImageToFile() async {
    final img = activeImage;
    if (img == null) return null;

    _setBusy(true, 'Rendering image...');
    try {
      final pngBytes = await ImageRendererService.renderAnnotatedImage(
        imageItem: img,
        showTitlesInBadges: _showTitlesInBadges,
      );

      final uri = await FilePicker.saveFile(
        dialogTitle: 'Save Annotated Screenshot',
        fileName: '${img.name.replaceAll(RegExp(r'[^\w\.-]'), '_')}_annotated.png',
        bytes: pngBytes,
        mimeType: 'image/png',
      );

      if (uri != null) {
        final path = uri.hasScheme && uri.scheme == 'file' ? uri.toFilePath() : uri.toString();
        _setBusy(false, 'Saved image! 💾');
        return path;
      }
      _setBusy(false);
      return null;
    } catch (e) {
      _setBusy(false, 'Save error: $e');
      return null;
    }
  }

  Future<void> copyPromptToClipboard() async {
    final prompt = getGeneratedPrompt();
    await ClipboardService.copyTextToClipboard(prompt);
    _setBusy(false, 'Agent prompt copied! 🚀');
  }

  String getGeneratedPrompt() {
    final img = activeImage;
    if (img == null) return 'No image selected.';
    return PromptGeneratorService.generatePrompt(
      image: img,
      templateType: _templateType,
    );
  }

  void _setBusy(bool busy, [String? message]) {
    _isBusy = busy;
    _statusMessage = message;
    notifyListeners();
  }
}

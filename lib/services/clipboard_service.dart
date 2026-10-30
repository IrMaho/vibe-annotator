import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:uuid/uuid.dart';
import '../models/image_item.dart';

class ClipboardService {
  static const _uuid = Uuid();

  /// Reads image bytes directly from OS clipboard (e.g. from PrintScreen / Snipping Tool / Win+Shift+S)
  static Future<ImageItem?> pasteImageFromClipboard() async {
    try {
      final Uint8List? bytes = await Pasteboard.image;
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      return await createImageFromBytes(bytes, name: 'Pasted Shot');
    } catch (e) {
      // ignore error, return null
      return null;
    }
  }

  /// Pick an image file from local file system
  static Future<ImageItem?> pickImageFromFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.image,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;
      return await createImageFromBytes(bytes, name: file.name);
    } catch (e) {
      return null;
    }
  }

  /// Decode Uint8List into a fully configured ImageItem
  static Future<ImageItem> createImageFromBytes(Uint8List bytes, {String name = 'Screenshot'}) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final ui.Image decoded = frame.image;

    return ImageItem(
      id: _uuid.v4(),
      name: name,
      rawBytes: bytes,
      width: decoded.width,
      height: decoded.height,
      decodedImage: decoded,
    );
  }

  /// Copy rendered PNG bytes to clipboard so user can immediately paste it into Claude/Gemini/Slack
  static Future<void> copyImageToClipboard(Uint8List bytes) async {
    await Pasteboard.writeImage(bytes);
  }

  /// Copy prompt text to system clipboard
  static Future<void> copyTextToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}

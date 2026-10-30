import 'package:flutter/material.dart';
import '../../models/image_item.dart';
import '../../models/prompt_template.dart';
import '../../state/app_state.dart';
import '../../utils/theme.dart';

class PromptPreviewView extends StatefulWidget {
  final ImageItem imageItem;
  final AppState appState;

  const PromptPreviewView({
    super.key,
    required this.imageItem,
    required this.appState,
  });

  @override
  State<PromptPreviewView> createState() => _PromptPreviewViewState();
}

class _PromptPreviewViewState extends State<PromptPreviewView> {
  bool _copiedPrompt = false;
  bool _copiedImage = false;

  void _triggerCopyPrompt() async {
    await widget.appState.copyPromptToClipboard();
    setState(() => _copiedPrompt = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedPrompt = false);
    });
  }

  void _triggerCopyImage() async {
    final success = await widget.appState.copyAnnotatedImageToClipboard();
    if (success) {
      setState(() => _copiedImage = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copiedImage = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final promptText = widget.appState.getGeneratedPrompt();
    final wordCount = promptText.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;

    return Column(
      children: [
        // Format Template Selector
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: SportTheme.surfaceSubdued,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SportTheme.border),
          ),
          child: Row(
            children: PromptTemplateType.values.map((type) {
              final isSelected = widget.appState.templateType == type;
              return Expanded(
                child: InkWell(
                  onTap: () => widget.appState.setTemplateType(type),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? SportTheme.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? SportTheme.primaryRed : Colors.transparent,
                        width: 1.2,
                      ),
                      boxShadow: isSelected ? SportTheme.cardShadow : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getTemplateShortLabel(type),
                      style: TextStyle(
                        color: isSelected ? SportTheme.primaryRed : SportTheme.slate,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Action Buttons: Copy Prompt & Copy Image
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // Main Action: Copy Prompt (Sport Red Gradient)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _copiedPrompt ? null : SportTheme.redSportGradient,
                  color: _copiedPrompt ? const Color(0xFF059669) : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _copiedPrompt ? null : SportTheme.redGlowShadow,
                ),
                child: ElevatedButton.icon(
                  icon: Icon(
                    _copiedPrompt ? Icons.check_circle_rounded : Icons.content_copy_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                  label: Text(
                    _copiedPrompt ? 'پرامپت کپی شد! 🚀' : 'کپی پرامپت ایجنت (Ctrl+C)',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _triggerCopyPrompt,
                ),
              ),
              const SizedBox(height: 8),

              // Secondary Actions Row: Copy Image & Save Image
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(
                        _copiedImage ? Icons.check_rounded : Icons.image_rounded,
                        size: 15,
                        color: _copiedImage ? const Color(0xFF059669) : SportTheme.primaryRed,
                      ),
                      label: Text(
                        _copiedImage ? 'تصویر کپی شد!' : 'کپی عکس با نشانه‌ها',
                        style: TextStyle(
                          color: _copiedImage ? const Color(0xFF059669) : SportTheme.carbonDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _copiedImage ? const Color(0xFF059669) : SportTheme.border,
                          width: 1.2,
                        ),
                        backgroundColor: SportTheme.surface,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _triggerCopyImage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 15, color: SportTheme.carbonDark),
                      label: const Text(
                        'ذخیره PNG',
                        style: TextStyle(color: SportTheme.carbonDark, fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: SportTheme.border, width: 1.2),
                        backgroundColor: SportTheme.surface,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => widget.appState.saveAnnotatedImageToFile(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Info bar: word & token count
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'LIVE AGENT PROMPT',
                style: TextStyle(
                  color: SportTheme.slate,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Prompt Code / Preview Container (Carbon Black console box)
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SportTheme.carbonBlack,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: SportTheme.carbonBlack.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                promptText,
                style: const TextStyle(
                  color: Color(0xFFF1F5F9),
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getTemplateShortLabel(PromptTemplateType type) {
    switch (type) {
      case PromptTemplateType.vibeCodingStandard:
        return '⚡ Standard';
      case PromptTemplateType.compactVision:
        return '🎯 Vision';
      case PromptTemplateType.checklist:
        return '📋 Checklist';
      case PromptTemplateType.json:
        return '📦 JSON';
    }
  }
}

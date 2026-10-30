import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/image_item.dart';
import 'state/app_state.dart';
import 'utils/theme.dart';
import 'widgets/top_nav_bar.dart';
import 'widgets/tabs/image_tab_strip.dart';
import 'widgets/canvas/annotation_canvas.dart';
import 'widgets/inspector/regions_inspector_view.dart';
import 'widgets/inspector/prompt_preview_view.dart';
import 'widgets/dialogs/quick_help_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VibeAnnotatorApp());
}

class VibeAnnotatorApp extends StatelessWidget {
  const VibeAnnotatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeAnnotator - Visual Agent Prompting Studio',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: SportTheme.background,
        primaryColor: SportTheme.primaryRed,
        colorScheme: const ColorScheme.light(
          primary: SportTheme.primaryRed,
          secondary: SportTheme.carbonDark,
          surface: SportTheme.surface,
          error: Color(0xFFE11D48),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: SportTheme.carbonDark,
          displayColor: SportTheme.carbonDark,
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: SportTheme.carbonBlack,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
              ),
            ],
          ),
          textStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      home: const MainStudioScreen(),
    );
  }
}

class MainStudioScreen extends StatefulWidget {
  const MainStudioScreen({super.key});

  @override
  State<MainStudioScreen> createState() => _MainStudioScreenState();
}

class _MainStudioScreenState extends State<MainStudioScreen> with SingleTickerProviderStateMixin {
  late final AppState _appState;
  late final TabController _inspectorTabController;
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _inspectorTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _inspectorTabController.dispose();
    _keyboardFocusNode.dispose();
    _appState.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => const QuickHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        final activeImage = _appState.activeImage;

        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.keyV, control: true): () {
              _appState.pasteFromClipboard();
            },
            const SingleActivator(LogicalKeyboardKey.keyV, meta: true): () {
              _appState.pasteFromClipboard();
            },
            const SingleActivator(LogicalKeyboardKey.keyC, control: true): () {
              _appState.copyPromptToClipboard();
            },
            const SingleActivator(LogicalKeyboardKey.keyC, meta: true): () {
              _appState.copyPromptToClipboard();
            },
          },
          child: Focus(
            focusNode: _keyboardFocusNode,
            autofocus: true,
            child: Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    // Top App Bar
                    TopNavBar(
                      appState: _appState,
                      onShowHelp: _showHelpDialog,
                    ),

                    // Multi-Image Tabs Bar (if any images loaded)
                    if (_appState.images.isNotEmpty)
                      ImageTabStrip(
                        images: _appState.images,
                        activeIndex: _appState.activeImageIndex,
                        onSelectTab: _appState.setActiveImageIndex,
                        onCloseTab: _appState.closeImage,
                        onPasteNew: _appState.pasteFromClipboard,
                        onPickNew: _appState.pickImageFromFile,
                      ),

                    // Main Content
                    Expanded(
                      child: activeImage == null
                          ? _buildEmptyWelcomeState()
                          : Row(
                              children: [
                                // Left/Center: Annotation Canvas
                                Expanded(
                                  flex: 6,
                                  child: AnnotationCanvas(
                                    key: ValueKey(activeImage.id),
                                    imageItem: activeImage,
                                    appState: _appState,
                                  ),
                                ),

                                // Divider
                                Container(
                                  width: 1,
                                  color: SportTheme.border,
                                ),

                                // Right: Inspector & Prompt Generator Panel
                                SizedBox(
                                  width: 440,
                                  child: _buildInspectorPanel(activeImage),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInspectorPanel(ImageItem imageItem) {
    return Container(
      color: SportTheme.surface,
      child: Column(
        children: [
          // Inspector Header Tabs (Sport Red active line)
          Container(
            decoration: const BoxDecoration(
              color: SportTheme.surface,
              border: Border(bottom: BorderSide(color: SportTheme.border)),
            ),
            child: TabBar(
              controller: _inspectorTabController,
              indicatorColor: SportTheme.primaryRed,
              indicatorWeight: 3.0,
              labelColor: SportTheme.primaryRed,
              unselectedLabelColor: SportTheme.slate,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bookmark_border_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text('Regions (${imageItem.annotations.length})'),
                    ],
                  ),
                ),
                const Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.terminal_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Agent Prompt ⚡'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _inspectorTabController,
              children: [
                // Tab 1: Marked Regions & Comments
                RegionsInspectorView(
                  imageItem: imageItem,
                  appState: _appState,
                ),

                // Tab 2: Agent Prompt Live Preview & Export
                PromptPreviewView(
                  imageItem: imageItem,
                  appState: _appState,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWelcomeState() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          decoration: BoxDecoration(
            color: SportTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SportTheme.border),
            boxShadow: SportTheme.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Sport Icon
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: SportTheme.redSportGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: SportTheme.redGlowShadow,
                ),
                child: const Icon(Icons.screenshot_monitor_rounded, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'استودیوی پرامپت‌نویسی بصری برای ایجنت‌های هوش مصنوعی',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SportTheme.carbonDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'اسکرین‌شات بگیرید، مستقیماً Paste کنید، روی بخش‌های مختلف کامنت بگذارید و خروجی تصویر شماره‌گذاری شده + پرامپت دقیق مختصات‌دار تحویل بگیرید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SportTheme.slate,
                  fontSize: 13.5,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              // Big Action: Paste Button (Sport Red Gradient)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: SportTheme.redSportGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: SportTheme.redGlowShadow,
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.paste_rounded, size: 20, color: Colors.white),
                  label: const Text(
                    'پیست اسکرین‌شات از کلیپ‌بورد (Ctrl + V)',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final ok = await _appState.pasteFromClipboard();
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
              ),
              const SizedBox(height: 14),

              // Secondary Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.file_open_outlined, size: 16, color: SportTheme.carbonDark),
                      label: const Text(
                        'انتخاب فایل تصویر',
                        style: TextStyle(color: SportTheme.carbonDark, fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: SportTheme.border, width: 1.2),
                        backgroundColor: SportTheme.surfaceSubdued,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _appState.pickImageFromFile(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.play_circle_outline_rounded, size: 16, color: SportTheme.primaryRed),
                      label: const Text(
                        'بارگذاری دمو تست',
                        style: TextStyle(color: SportTheme.primaryRed, fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: SportTheme.primaryRed.withOpacity(0.4), width: 1.2),
                        backgroundColor: SportTheme.primaryRedUltraLight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _appState.loadDemoShowcase(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

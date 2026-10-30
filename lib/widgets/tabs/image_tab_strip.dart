import 'package:flutter/material.dart';
import '../../models/image_item.dart';
import '../../utils/theme.dart';

class ImageTabStrip extends StatelessWidget {
  final List<ImageItem> images;
  final int activeIndex;
  final ValueChanged<int> onSelectTab;
  final ValueChanged<int> onCloseTab;
  final VoidCallback onPasteNew;
  final VoidCallback onPickNew;

  const ImageTabStrip({
    super.key,
    required this.images,
    required this.activeIndex,
    required this.onSelectTab,
    required this.onCloseTab,
    required this.onPasteNew,
    required this.onPickNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: const BoxDecoration(
        color: SportTheme.surfaceSubdued,
        border: Border(bottom: BorderSide(color: SportTheme.border)),
      ),
      child: Row(
        children: [
          // Scrollable Tabs
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index];
                final isActive = index == activeIndex;

                return InkWell(
                  onTap: () => onSelectTab(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isActive ? SportTheme.surface : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? SportTheme.primaryRed : Colors.transparent,
                          width: 2.5,
                        ),
                        right: const BorderSide(color: SportTheme.border),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          size: 15,
                          color: isActive ? SportTheme.primaryRed : SportTheme.slate,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          img.name,
                          style: TextStyle(
                            color: isActive ? SportTheme.carbonDark : SportTheme.slate,
                            fontSize: 12.5,
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                        if (img.annotations.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isActive ? SportTheme.primaryRed : SportTheme.slate.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${img.annotations.length}',
                              style: TextStyle(
                                color: isActive ? Colors.white : SportTheme.slate,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () => onCloseTab(index),
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(Icons.close_rounded, size: 14, color: SportTheme.slate),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add Buttons
          Tooltip(
            message: 'Paste Screenshot from Clipboard (Ctrl+V)',
            child: InkWell(
              onTap: onPasteNew,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.content_paste_go_rounded, size: 14, color: SportTheme.primaryRed),
                    SizedBox(width: 4),
                    Text(
                      'Paste',
                      style: TextStyle(
                        color: SportTheme.primaryRed,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(height: 18, width: 1, color: SportTheme.border),
          Tooltip(
            message: 'Open Image File...',
            child: InkWell(
              onTap: onPickNew,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const Icon(Icons.add_rounded, size: 18, color: SportTheme.carbonDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

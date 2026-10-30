import 'package:flutter/material.dart';
import '../../models/annotation_region.dart';
import '../../utils/color_palette.dart';
import '../../utils/theme.dart';

class AnnotationCard extends StatelessWidget {
  final AnnotationRegion region;
  final bool isSelected;
  final VoidCallback onSelect;
  final ValueChanged<AnnotationRegion> onUpdate;
  final VoidCallback onDelete;

  const AnnotationCard({
    super.key,
    required this.region,
    required this.isSelected,
    required this.onSelect,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? SportTheme.surface : SportTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? SportTheme.primaryRed : SportTheme.border,
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected ? SportTheme.subtleGlow : SportTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: [Badge L#] + Spatial Hint + Priority + Delete
                Row(
                  children: [
                    // Badge Tag Pill (Sport Red)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: region.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        region.label,
                        style: TextStyle(
                          color: AnnotationColorPalette.getContrastingTextColor(region.color),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Spatial location
                    Expanded(
                      child: Text(
                        region.getSpatialLocation(),
                        style: const TextStyle(
                          color: SportTheme.slate,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Priority Pill
                    _buildPriorityPill(),
                    const SizedBox(width: 6),

                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      color: SportTheme.slate,
                      splashRadius: 14,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      onPressed: onDelete,
                      tooltip: 'حذف این نشانه',
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title Input
                TextFormField(
                  initialValue: region.title,
                  style: const TextStyle(
                    color: SportTheme.carbonDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'عنوان بخش یا کامپوننت (مثلاً: دکمه سرچ هدر)',
                    hintStyle: const TextStyle(color: SportTheme.slateLight, fontSize: 12),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    filled: true,
                    fillColor: SportTheme.surfaceSubdued,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SportTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SportTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SportTheme.primaryRed, width: 1.5),
                    ),
                  ),
                  onChanged: (val) => onUpdate(region.copyWith(title: val)),
                ),
                const SizedBox(height: 8),

                // Comment / Instruction Input
                TextFormField(
                  initialValue: region.comment,
                  maxLines: 3,
                  minLines: 2,
                  style: const TextStyle(
                    color: SportTheme.carbonDark,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ایجنت با این بخش چه تغییری باید بده؟\n(مثلاً: طراحی اسپورت قرمز و مشکی شود...)',
                    hintStyle: const TextStyle(color: SportTheme.slateLight, fontSize: 12),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    filled: true,
                    fillColor: SportTheme.surfaceSubdued,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SportTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SportTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SportTheme.primaryRed, width: 1.5),
                    ),
                  ),
                  onChanged: (val) => onUpdate(region.copyWith(comment: val)),
                ),
                const SizedBox(height: 8),

                // Footer: Category & Color Picker triggers
                Row(
                  children: [
                    // Category selector dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: SportTheme.surfaceSubdued,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: SportTheme.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<RegionCategory>(
                          value: region.category,
                          isDense: true,
                          dropdownColor: SportTheme.surface,
                          style: const TextStyle(color: SportTheme.carbonDark, fontSize: 11.5, fontWeight: FontWeight.w600),
                          icon: const Icon(Icons.arrow_drop_down, size: 16, color: SportTheme.slate),
                          items: RegionCategory.values.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cat.icon, size: 13, color: region.color),
                                  const SizedBox(width: 5),
                                  Text(cat.label),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (cat) {
                            if (cat != null) onUpdate(region.copyWith(category: cat));
                          },
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Color swatches (quick selector)
                    Wrap(
                      spacing: 4,
                      children: AnnotationColorPalette.labelColors.take(4).map((c) {
                        final isColorSelected = c.value == region.color.value;
                        return InkWell(
                          onTap: () => onUpdate(region.copyWith(color: c)),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 17,
                            height: 17,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isColorSelected ? SportTheme.carbonBlack : Colors.white,
                                width: isColorSelected ? 2.0 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityPill() {
    return PopupMenuButton<RegionPriority>(
      initialValue: region.priority,
      tooltip: 'Set Priority',
      color: SportTheme.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: SportTheme.border),
      ),
      onSelected: (p) => onUpdate(region.copyWith(priority: p)),
      itemBuilder: (context) {
        return RegionPriority.values.map((p) {
          return PopupMenuItem(
            value: p,
            child: Row(
              children: [
                Icon(Icons.circle, size: 10, color: p.color),
                const SizedBox(width: 8),
                Text(
                  p.label,
                  style: const TextStyle(color: SportTheme.carbonDark, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: region.priority == RegionPriority.critical
              ? SportTheme.primaryRedUltraLight
              : region.priority.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: region.priority == RegionPriority.critical
                ? SportTheme.primaryRedLight
                : region.priority.color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 6, color: region.priority == RegionPriority.critical ? SportTheme.primaryRed : region.priority.color),
            const SizedBox(width: 4),
            Text(
              region.priority.label,
              style: TextStyle(
                color: region.priority == RegionPriority.critical ? SportTheme.primaryRed : region.priority.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

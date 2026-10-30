import 'package:flutter/material.dart';
import '../../models/image_item.dart';
import '../../state/app_state.dart';
import '../../utils/theme.dart';
import 'annotation_card.dart';

class RegionsInspectorView extends StatelessWidget {
  final ImageItem imageItem;
  final AppState appState;

  const RegionsInspectorView({
    super.key,
    required this.imageItem,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Global Screen Goal Card
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SportTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SportTheme.border),
            boxShadow: SportTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.flag_rounded, size: 16, color: SportTheme.primaryRed),
                  SizedBox(width: 6),
                  Text(
                    'Overall Screen Objective',
                    style: TextStyle(
                      color: SportTheme.carbonDark,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: imageItem.globalGoal,
                maxLines: 2,
                style: const TextStyle(color: SportTheme.carbonDark, fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'مثلاً: طراحی اپ اسپورت تم سفید و قرمز و مشکی با گرادیانت های نرم...',
                  hintStyle: const TextStyle(color: SportTheme.slateLight, fontSize: 11.5),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                onChanged: (val) => appState.updateGlobalGoal(val),
              ),
            ],
          ),
        ),

        // Subheader: Region Counter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Text(
                'MARKED REGIONS',
                style: TextStyle(
                  color: SportTheme.slate,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: SportTheme.primaryRedUltraLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SportTheme.primaryRedLight),
                ),
                child: Text(
                  '${imageItem.annotations.length} items',
                  style: const TextStyle(
                    color: SportTheme.primaryRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // List of Annotations
        Expanded(
          child: imageItem.annotations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: imageItem.annotations.length,
                  itemBuilder: (context, index) {
                    final region = imageItem.annotations[index];
                    return AnnotationCard(
                      key: ValueKey(region.id),
                      region: region,
                      isSelected: region.id == appState.selectedRegionId,
                      onSelect: () => appState.selectRegion(region.id),
                      onUpdate: appState.updateAnnotation,
                      onDelete: () => appState.deleteAnnotation(region.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SportTheme.primaryRedUltraLight,
                shape: BoxShape.circle,
                border: Border.all(color: SportTheme.primaryRedLight),
              ),
              child: const Icon(
                Icons.crop_square_rounded,
                size: 32,
                color: SportTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'هیچ ناحیه‌ای هنوز انتخاب نشده',
              style: TextStyle(
                color: SportTheme.carbonDark,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'روی تصویر کلیک و درگ کنید تا نشانه [L1] ثبت شود.\nمی‌توانید برای هر بخش کامنت و درخواست خودتان را بنویسید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SportTheme.slate,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

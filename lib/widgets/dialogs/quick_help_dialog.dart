import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class QuickHelpDialog extends StatelessWidget {
  const QuickHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SportTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: SportTheme.border),
      ),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: SportTheme.redSportGradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: SportTheme.subtleGlow,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'راهنمای وایب کدینگ با VibeAnnotator',
                    style: TextStyle(
                      color: SportTheme.carbonDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: SportTheme.slate),
                    splashRadius: 18,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Steps
              _buildStepRow(
                step: '۱',
                title: 'اسکرین‌شات و پیست مستقیم (Ctrl+V)',
                desc: 'با کلیدهای Win+Shift+S اسکرین‌شات بگیرید و مستقیماً داخل برنامه Paste کنید.',
                icon: Icons.content_paste_rounded,
                accentColor: SportTheme.primaryRed,
              ),
              _buildStepRow(
                step: '۲',
                title: 'انتخاب ناحیه و برچسب‌گذاری خودکار [L#]',
                desc: 'روی هر قسمت از تصویر کلیک و درگ کنید. باکس با شناسه مثلاً [L1] یا [L43] و مختصات دقیق روی تصویر درج می‌شود.',
                icon: Icons.crop_square_rounded,
                accentColor: SportTheme.carbonBlack,
              ),
              _buildStepRow(
                step: '۳',
                title: 'ثبت دستور و کامنت برای ایجنت',
                desc: 'در پنل سمت راست، توضیح و تغییر درخواستی را بنویسید (مثلاً: دکمه سرچ بنفش شود و پدینگ ۱۶ باشد).',
                icon: Icons.comment_outlined,
                accentColor: const Color(0xFFD97706),
              ),
              _buildStepRow(
                step: '۴',
                title: 'کپی پرامپت و تصویر شماره‌گذاری شده',
                desc: 'با یک کلیک تصویر برچسب‌خورده و پرامپت ساختاریافته را کپی و به چت با ایجنت بفرستید!',
                icon: Icons.send_rounded,
                accentColor: const Color(0xFF059669),
              ),

              const SizedBox(height: 16),
              const Divider(color: SportTheme.border),
              const SizedBox(height: 12),

              // Keyboard shortcuts table
              const Text(
                'کلیدهای میانبر (SHORTCUTS)',
                style: TextStyle(
                  color: SportTheme.slate,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildShortcutKey('Ctrl + V', 'پیست تصویر'),
                  _buildShortcutKey('Ctrl + C', 'کپی پرامپت'),
                  _buildShortcutKey('Space', 'جابجایی (Pan)'),
                  _buildShortcutKey('R', 'ابزار رسم باکس'),
                  _buildShortcutKey('V', 'ابزار انتخاب'),
                  _buildShortcutKey('Del', 'حذف باکس'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required String step,
    required String title,
    required String desc,
    required IconData icon,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              step,
              style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: SportTheme.carbonDark, fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(color: SportTheme.slate, fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutKey(String keyCombo, String action) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: SportTheme.surfaceSubdued,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: SportTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: SportTheme.carbonDark,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              keyCombo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            action,
            style: const TextStyle(color: SportTheme.carbonDark, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

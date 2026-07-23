import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/color_utils.dart';

enum AppTagVariant { accent, outline, neutral }

/// Small flat label pill — matches `.tag` / `.tag-accent` / `.tag-outline` /
/// `.tag-neutral` in the design system. Square corners like everything else
/// in this system; only the tag's own font size is small enough that a
/// quarter-radius reads as "pill" at a glance in the original mockups, so
/// this intentionally stays square rather than rounded for consistency.
class AppTag extends StatelessWidget {
  const AppTag(this.label, {super.key, this.variant = AppTagVariant.neutral});

  final String label;
  final AppTagVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    late final Color bg;
    late final Color fg;
    Border? border;

    switch (variant) {
      case AppTagVariant.accent:
        bg = tintColor(accent, 0.92);
        fg = shadeColor(accent, 0.5);
      case AppTagVariant.outline:
        bg = Colors.transparent;
        fg = accent;
        border = Border.all(color: accent);
      case AppTagVariant.neutral:
        bg = isDark ? AppColors.neutral800 : AppColors.neutral100;
        fg = isDark ? AppColors.neutral100 : AppColors.neutral800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, border: border),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: fg, letterSpacing: 0.2),
      ),
    );
  }
}

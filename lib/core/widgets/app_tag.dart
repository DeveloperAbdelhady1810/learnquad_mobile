import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/color_utils.dart';

enum AppTagVariant { accent, outline, neutral }

/// Small pill-shaped badge — matches `.tag` / `.tag-accent` / `.tag-outline`
/// / `.tag-neutral` in ds-nocturne.css. `accent` derives a fixed-direction
/// dark-shade background + light-tint text from whichever accent color is
/// currently active (admin-configurable — see remote_theme.dart), matching
/// Nocturne's `accent-800`/`accent-100` ramp steps without hardcoding them
/// (the ramp itself doesn't flip between light/dark mode, so neither does
/// the tag — same as `neutral`, which uses the fixed neutral ramp directly).
class AppTag extends StatelessWidget {
  const AppTag(this.label, {super.key, this.variant = AppTagVariant.neutral});

  final String label;
  final AppTagVariant variant;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    late final Color bg;
    late final Color fg;
    Border? border;

    switch (variant) {
      case AppTagVariant.accent:
        bg = shadeColor(accent, 0.55);
        fg = tintColor(accent, 0.90);
      case AppTagVariant.outline:
        bg = Colors.transparent;
        fg = accent;
        border = Border.all(color: accent);
      case AppTagVariant.neutral:
        bg = AppColors.neutral800;
        fg = AppColors.neutral100;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: border,
        borderRadius: BorderRadius.circular(AppRadius.md * 0.75),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: fg, letterSpacing: 0.2),
      ),
    );
  }
}

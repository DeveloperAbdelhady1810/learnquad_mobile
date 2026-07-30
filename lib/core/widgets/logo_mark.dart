import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// The recurring brand mark across splash/login/register: a rounded accent
/// badge with a bold "Q" glyph — matches Splash.dc.html/Login.dc.html.
/// Wrapped in [Align] so a fixed [size] survives a parent Column's
/// `CrossAxisAlignment.stretch` (which otherwise forces this widget's
/// SizedBox to the Column's full width regardless of its own constraints —
/// the bug behind the old diamond mark rendering as a full-width bar).
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(size * AppRadius.lg / 64),
          boxShadow: AppElevation.lg(isDark),
        ),
        child: Text(
          'Q',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: size * 0.4,
            height: 1,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Structural tokens ported from the "Nocturne" design system (claude.ai/design
/// project `LearnQuad Visual Identity` — see `ds-nocturne.css`, `Dashboard.dc.html`):
/// a soft, rounded, purple-accented look with gentle elevation shadows,
/// replacing the earlier flat/sharp-cornered "Modernist" system.
///
/// The accent color itself is NOT fixed here — it's fetched from
/// `GET /api/settings/theme` (see remote_theme.dart). By default that mirrors
/// whatever color the admin has chosen on the website
/// (`App\Helpers\Settings::activeThemeColors()`), but the admin can flip a
/// toggle in Admin Settings > Branding to give the app its own independent
/// accent instead (`App\Helpers\Settings::mobileThemeColors()`). The
/// constants below are only the last-resort fallback used before that fetch
/// resolves or if it fails — they match the app's Nocturne-purple identity,
/// since that's the sensible default when nothing else is available yet.
class AppColors {
  AppColors._();

  // Light mode — lavender-white ground, white surfaces (Nocturne's light
  // companion palette, `.nq-light` in ds-nocturne.css).
  static const bg = Color(0xFFF5F4FB);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF201F2B);

  // Dark mode — Nocturne's native navy ground.
  static const bgDark = Color(0xFF161826);
  static const surfaceDark = Color(0xFF1E2133);
  static const textDark = Color(0xFFF3F1FA);

  // Fallback accent — used only until the remote theme loads / if it fails.
  // Nocturne purple (#9184d9) — the app's own design-system accent.
  static const accent = Color(0xFF9184D9);
  static const accent700 = Color(0xFF776CB2);
  static const onAccent = Color(0xFFF8F8FC);

  // Purple-tinted neutral ramp (replaces the old warm-gray Modernist ramp)
  // used for progress tracks, subtle fills, and disabled states.
  static const neutral100 = Color(0xFFF5F4FB);
  static const neutral200 = Color(0xFFE7E5F2);
  static const neutral300 = Color(0xFFD3D0E8);
  static const neutral700 = Color(0xFF6B6684);
  static const neutral800 = Color(0xFF3A3752);
  static const neutral900 = Color(0xFF1E2133);
}

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Nocturne's 3-tier radius scale (`--radius-sm/md/lg` in ds-nocturne.css).
class AppRadius {
  AppRadius._();
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 14.0;

  static const smBr = BorderRadius.all(Radius.circular(sm));
  static const mdBr = BorderRadius.all(Radius.circular(md));
  static const lgBr = BorderRadius.all(Radius.circular(lg));
}

/// Legacy shared constant, kept so every screen that already reads `kRadius`
/// for its own ad-hoc Container/Card decorations picks up Nocturne's rounding
/// automatically instead of needing a per-file edit. Maps to the mid tier.
const kRadius = AppRadius.mdBr;

/// Nocturne's elevation identity: a hairline ring plus an ambient shadow on
/// dark surfaces, a softer ink-tinted shadow (no ring) on light surfaces.
class AppElevation {
  AppElevation._();

  static List<BoxShadow> card(bool isDark) => isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ]
      : [
          BoxShadow(
            color: AppColors.text.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ];
}

class AppTheme {
  AppTheme._();

  static ThemeData light({Color accent = AppColors.accent}) =>
      _build(Brightness.light, accent);
  static ThemeData dark({Color accent = AppColors.accent}) =>
      _build(Brightness.dark, accent);

  static ThemeData _build(Brightness brightness, Color accent) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bg;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final fg = isDark ? AppColors.textDark : AppColors.text;
    final divider = fg.withValues(alpha: isDark ? 0.14 : 0.10);

    // Arabic is the app's primary language — IBM Plex Sans Arabic stays the
    // base text theme (Inter has no meaningful Arabic glyph coverage).
    // Nocturne's identity comes through via weight (softer than the old
    // Modernist 800/700 headings) and the structural tokens above; Inter
    // itself is reserved for the Latin brand wordmark/kickers below.
    var textTheme = GoogleFonts.ibmPlexSansArabicTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(bodyColor: fg, displayColor: fg);
    textTheme = textTheme.copyWith(
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    final colorScheme =
        (isDark ? const ColorScheme.dark() : const ColorScheme.light())
            .copyWith(
              primary: accent,
              onPrimary: AppColors.onAccent,
              secondary: accent,
              surface: surface,
              onSurface: fg,
              error: const Color(0xFFD32F2F),
            );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      dividerColor: divider,
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
        iconTheme: IconThemeData(color: fg),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBr,
          side: BorderSide(color: divider),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: accent.withValues(alpha: 0.45),
          textStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: divider),
          textStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBr,
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBr,
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBr,
          borderSide: BorderSide(color: accent, width: 2),
        ),
        labelStyle: TextStyle(color: fg.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: fg.withValues(alpha: 0.45)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: AppColors.neutral300,
      ),
      iconTheme: IconThemeData(color: fg),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: fg.withValues(alpha: 0.5),
        indicatorColor: accent,
        dividerColor: divider,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: fg,
        contentTextStyle: TextStyle(color: bg),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
      ),
      extensions: [AppSemantics(surface: surface, divider: divider, fg: fg)],
    );
  }
}

/// Extra tokens that don't map to a stock [ThemeData] slot, threaded through
/// as a [ThemeExtension] so screens can read `Theme.of(context).extension`
/// instead of re-deriving divider/surface opacity math themselves.
class AppSemantics extends ThemeExtension<AppSemantics> {
  const AppSemantics({
    required this.surface,
    required this.divider,
    required this.fg,
  });

  final Color surface;
  final Color divider;
  final Color fg;

  @override
  AppSemantics copyWith({Color? surface, Color? divider, Color? fg}) {
    return AppSemantics(
      surface: surface ?? this.surface,
      divider: divider ?? this.divider,
      fg: fg ?? this.fg,
    );
  }

  @override
  AppSemantics lerp(ThemeExtension<AppSemantics>? other, double t) {
    if (other is! AppSemantics) return this;
    return AppSemantics(
      surface: Color.lerp(surface, other.surface, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      fg: Color.lerp(fg, other.fg, t)!,
    );
  }
}

/// The brand wordmark and small uppercase section kickers use Inter (the
/// design system's Latin display face) even on otherwise-Arabic screens —
/// "LearnQuad" itself is never set in the Arabic font. Colors default to the
/// current theme's (dynamic) accent.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle brand(
    BuildContext context, {
    double size = 15,
    Color? color,
  }) => GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: size,
    color: color ?? Theme.of(context).colorScheme.primary,
  );

  static TextStyle kicker(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        letterSpacing: 1.2,
        color: color ?? Theme.of(context).colorScheme.primary,
      );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens ported from the "Modernist" design system (claude.ai/design project
/// `LearnQuad design system` — see `LearnQuad Screens.dc.html`): a flat,
/// sharp-cornered, editorial look — zero border radius everywhere, thick
/// hairline dividers instead of soft shadows, one saturated accent color.
class AppColors {
  AppColors._();

  // Light mode
  static const bg = Color(0xFFF3F2F2);
  static const surface = Color(0xFFEAE9E9);
  static const text = Color(0xFF201E1D);

  // Dark mode
  static const bgDark = Color(0xFF2D2B2B);
  static const surfaceDark = Color(0xFF3A3736);
  static const textDark = Color(0xFFF8F4F4);

  // Shared accent — same in both modes
  static const accent = Color(0xFFEC3013);
  static const accent100 = Color(0xFFFFF2EF);
  static const accent600 = Color(0xFFDD2B0F);
  static const accent700 = Color(0xFFAE1800);
  static const accent800 = Color(0xFF7C1405);

  static const neutral100 = Color(0xFFF8F4F4);
  static const neutral200 = Color(0xFFEAE7E7);
  static const neutral300 = Color(0xFFD7D3D3);
  static const neutral700 = Color(0xFF605D5D);
  static const neutral800 = Color(0xFF444141);
  static const neutral900 = Color(0xFF2D2B2B);

  // Kept for the few call sites that haven't migrated to theme-driven colors.
  static const primary = accent;
  static const primaryDark = accent700;
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

/// Every corner in this design system is square — buttons, inputs, cards,
/// tags. Kept as a shared constant so nothing accidentally reverts to
/// Material's default rounding.
const kRadius = BorderRadius.zero;

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bg;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final fg = isDark ? AppColors.textDark : AppColors.text;
    final divider = fg.withValues(alpha: isDark ? 0.3 : 0.4);

    // Arabic is the app's primary language (see main.dart's fixed locale) —
    // IBM Plex Sans Arabic is the base text theme. Archivo (the Latin
    // display face from the design system) is reserved for the brand
    // wordmark and small uppercase kickers via AppTextStyles.brand below.
    var textTheme = GoogleFonts.ibmPlexSansArabicTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(bodyColor: fg, displayColor: fg);
    textTheme = textTheme.copyWith(
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );

    final colorScheme =
        (isDark ? const ColorScheme.dark() : const ColorScheme.light())
            .copyWith(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              secondary: AppColors.accent,
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
        shape: const RoundedRectangleBorder(borderRadius: kRadius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.45),
          textStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: const RoundedRectangleBorder(borderRadius: kRadius),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: divider),
          textStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: const RoundedRectangleBorder(borderRadius: kRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700),
          shape: const RoundedRectangleBorder(borderRadius: kRadius),
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
          borderRadius: kRadius,
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: kRadius,
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: kRadius,
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        labelStyle: TextStyle(color: fg.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: fg.withValues(alpha: 0.45)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.neutral300,
      ),
      iconTheme: IconThemeData(color: fg),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(borderRadius: kRadius),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.accent,
        unselectedLabelColor: fg.withValues(alpha: 0.5),
        indicatorColor: AppColors.accent,
        dividerColor: divider,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: fg,
        contentTextStyle: TextStyle(color: bg),
        shape: const RoundedRectangleBorder(borderRadius: kRadius),
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

/// The brand wordmark and small uppercase section kickers stay in Archivo
/// (the design system's Latin display face) even on otherwise-Arabic
/// screens — matches every mockup, where "LearnQuad" itself is never set in
/// the Arabic font.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle brand({double size = 15, Color? color}) =>
      GoogleFonts.archivo(
        fontWeight: FontWeight.w800,
        fontSize: size,
        color: color ?? AppColors.accent,
      );

  static TextStyle kicker({Color? color}) => GoogleFonts.archivo(
    fontWeight: FontWeight.w800,
    fontSize: 11,
    letterSpacing: 1.2,
    color: color ?? AppColors.accent,
  );
}

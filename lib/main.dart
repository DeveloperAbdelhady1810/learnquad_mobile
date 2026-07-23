import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/remote_theme.dart';
import 'l10n/gen/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: LearnQuadApp()));
}

class LearnQuadApp extends ConsumerWidget {
  const LearnQuadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Mirrors the admin's site-wide color choice from the web (see
    // remote_theme.dart) — falls back to the design system's default accent
    // until this resolves or if it fails, so the app is never left colorless.
    final remoteTheme = ref
        .watch(remoteThemeProvider)
        .maybeWhen(data: (t) => t, orElse: () => RemoteThemeColors.fallback);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: 'LearnQuad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent: remoteTheme.primary),
      darkTheme: AppTheme.dark(accent: remoteTheme.primary),
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}

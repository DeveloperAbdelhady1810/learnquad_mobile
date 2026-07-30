import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets/logo_mark.dart';
import '../../l10n/gen/app_localizations.dart';

/// Shown only while [AuthController] is checking secure storage for a stored
/// token. The router's redirect logic moves off this screen automatically
/// once that check resolves — this screen has no navigation logic itself.
///
/// Matches Splash.dc.html: badge + wordmark + tagline centered on the plain
/// theme background, with three staggered pulsing dots near the bottom.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LogoMark(size: 64),
                  const SizedBox(height: 18),
                  Text(
                    l10n.appName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.tagline,
                    style: TextStyle(
                      fontSize: 13,
                      color: fg?.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final phase =
                            2 * math.pi * (_controller.value + i * 0.125);
                        final opacity = 0.25 + 0.75 * (0.5 + 0.5 * math.sin(phase));
                        return Opacity(opacity: opacity, child: child);
                      },
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

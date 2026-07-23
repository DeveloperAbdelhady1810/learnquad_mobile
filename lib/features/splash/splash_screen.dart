import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Shown only while [AuthController] is checking secure storage for a stored
/// token. The router's redirect logic moves off this screen automatically
/// once that check resolves — this screen has no navigation logic itself.
///
/// Matches the splash mockup: an inverted "photo negative" of the current
/// theme (background painted in the ink color, content in the page-background
/// color) rather than a plain dark screen.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelBg = isDark ? AppColors.textDark : AppColors.text;
    final content = isDark ? AppColors.bgDark : AppColors.bg;

    return Scaffold(
      backgroundColor: panelBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: ColoredBox(
                        color: AppColors.accent,
                        child: Center(
                          child: Transform.rotate(
                            angle: 0.785398,
                            child: Container(
                              width: 26,
                              height: 26,
                              color: content,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'LearnQuad',
                      style: AppTextStyles.brand(size: 26, color: content),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'تعلّم. اختبر. تفوّق.',
                      style: TextStyle(
                        fontSize: 13,
                        color: content.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 60, 48),
              child: ClipRect(
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    value: null,
                    backgroundColor: content.withValues(alpha: 0.25),
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

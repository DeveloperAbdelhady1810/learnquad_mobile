import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The recurring brand mark across splash/login/register: an accent-colored
/// square with a rotated square cut out of its center. Matches every "logo"
/// occurrence in the design mockups.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 40, this.holeColor});

  final double size;
  final Color? holeColor;

  @override
  Widget build(BuildContext context) {
    final bg = holeColor ?? Theme.of(context).scaffoldBackgroundColor;
    return SizedBox(
      width: size,
      height: size,
      child: ColoredBox(
        color: AppColors.accent,
        child: Center(
          child: Transform.rotate(
            angle: 0.785398, // 45deg
            child: Container(width: size * 0.4, height: size * 0.4, color: bg),
          ),
        ),
      ),
    );
  }
}

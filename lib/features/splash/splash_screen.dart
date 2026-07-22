import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Shown only while [AuthController] is checking secure storage for a stored
/// token. The router's redirect logic moves off this screen automatically
/// once that check resolves — this screen has no navigation logic itself.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded, size: 72, color: AppColors.primary),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'app_theme.dart';

/// Mirrors GET /api/settings/theme, which itself mirrors the admin's
/// site-wide color choice on the web (`App\Helpers\Settings::activeThemeColors()`
/// — see resources/views/layouts/app.blade.php on the Laravel side). When the
/// admin changes the theme on the web (or picks a custom color), this app
/// picks it up on next launch.
class RemoteThemeColors {
  const RemoteThemeColors({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryDark,
  });

  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryDark;

  static Color _parseHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  factory RemoteThemeColors.fromJson(Map<String, dynamic> json) {
    return RemoteThemeColors(
      primary: _parseHex(json['primary'] as String),
      primaryDark: _parseHex(json['primary_dark'] as String),
      secondary: _parseHex(json['secondary'] as String),
      secondaryDark: _parseHex(json['secondary_dark'] as String),
    );
  }

  /// Used while the network call is in flight and if it fails entirely —
  /// the app must never be left without an accent color.
  static const fallback = RemoteThemeColors(
    primary: AppColors.accent,
    primaryDark: AppColors.accent700,
    secondary: AppColors.accent,
    secondaryDark: AppColors.accent700,
  );
}

class RemoteThemeRepository {
  RemoteThemeRepository(this._dio);
  final Dio _dio;

  Future<RemoteThemeColors> fetch() async {
    final response = await _dio.get('/settings/theme');
    return RemoteThemeColors.fromJson(response.data as Map<String, dynamic>);
  }
}

final remoteThemeRepositoryProvider = Provider<RemoteThemeRepository>((ref) {
  return RemoteThemeRepository(ref.watch(apiClientProvider).dio);
});

/// Falls back to [RemoteThemeColors.fallback] on any failure (offline first
/// launch, API down, etc.) rather than surfacing an error state — a themed
/// app with the wrong accent color beats a broken one.
final remoteThemeProvider = FutureProvider<RemoteThemeColors>((ref) async {
  try {
    return await ref.read(remoteThemeRepositoryProvider).fetch();
  } catch (_) {
    return RemoteThemeColors.fallback;
  }
});

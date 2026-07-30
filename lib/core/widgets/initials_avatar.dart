import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/color_utils.dart';

/// Circular avatar showing a teacher's real photo when the API provides one,
/// falling back to an accent-tinted initial letter when there's no photo or
/// it fails to load — matches the initials-circle look used everywhere else
/// in the app before a real photo exists.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 22,
    this.fontSize,
  });

  final String name;
  final String? imageUrl;
  final double radius;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bg = shadeColor(accent, 0.55);
    final fg = tintColor(accent, 0.90);
    final initial = name.trim().isNotEmpty ? name.trim()[0] : '؟';

    Widget initials() => CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        initial,
        style: AppTextStyles.brand(
          context,
          size: fontSize ?? radius * 0.68,
          color: fg,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return initials();

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (_, _) => initials(),
        errorWidget: (_, _, _) => initials(),
      ),
    );
  }
}

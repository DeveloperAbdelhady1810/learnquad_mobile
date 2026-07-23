import 'package:flutter/material.dart';

/// Lightens [base] toward white by [amount] (0-1). Used to derive a tag's
/// tint background from an arbitrary admin-chosen accent color.
Color tintColor(Color base, double amount) {
  return Color.lerp(base, Colors.white, amount)!;
}

/// Darkens [base] toward black by [amount] (0-1). Used to derive a tag's
/// on-tint text color from an arbitrary admin-chosen accent color.
Color shadeColor(Color base, double amount) {
  return Color.lerp(base, Colors.black, amount)!;
}

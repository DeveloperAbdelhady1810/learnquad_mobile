import 'package:flutter/material.dart';

/// A static caption above a form field — matches the design system's
/// `.field > label` treatment (a persistent label, not a Material floating
/// label). Wrap any input widget with this instead of using
/// `InputDecoration.labelText` to match the mockups.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: fg?.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

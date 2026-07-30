import 'package:flutter/widgets.dart';

const _western = '0123456789';
const _eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// Renders any number/numeric string using Arabic-Indic digits, matching
/// every numeral in the design mockups (prices, percentages, counts).
String _toArabicDigits(Object value) {
  final input = value.toString();
  final buffer = StringBuffer();
  for (final ch in input.split('')) {
    final index = _western.indexOf(ch);
    buffer.write(index == -1 ? ch : _eastern[index]);
  }
  return buffer.toString();
}

/// Locale-aware digit formatting: Arabic-Indic digits under the Arabic
/// locale, plain Western digits under English — used everywhere a number is
/// displayed so switching languages in the Profile screen also flips numerals.
String localizedDigits(BuildContext context, Object value) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  return isArabic ? _toArabicDigits(value) : value.toString();
}

/// Same digit localization, plus the matching percent-sign glyph (٪ vs %) —
/// use this instead of hardcoding "٪" after a digit string, which renders
/// wrong under the English locale.
String localizedPercent(BuildContext context, num value) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final digits = localizedDigits(context, value.round());
  return isArabic ? '$digits٪' : '$digits%';
}

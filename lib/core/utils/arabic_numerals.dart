const _western = '0123456789';
const _eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// Renders any number/numeric string using Arabic-Indic digits, matching
/// every numeral in the design mockups (prices, percentages, counts).
String arDigits(Object value) {
  final input = value.toString();
  final buffer = StringBuffer();
  for (final ch in input.split('')) {
    final index = _western.indexOf(ch);
    buffer.write(index == -1 ? ch : _eastern[index]);
  }
  return buffer.toString();
}

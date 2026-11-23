/// Parses an area such as "20" or "20,5". Returns null for empty,
/// invalid or negative input.
double? parseArea(String input) {
  final trimmed = input.trim().replaceAll(',', '.');
  if (trimmed.isEmpty) return null;
  final value = double.tryParse(trimmed);
  if (value == null || value < 0) return null;
  return value;
}

/// Shows whole numbers without a trailing ".0" (20 instead of 20.0).
String formatArea(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}


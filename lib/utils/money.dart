import 'dart:math' as math;

import 'package:intl/intl.dart';

const String defaultCurrency = 'VND';
const List<String> supportedCurrencies = ['VND', 'USD', 'EUR'];

/// Number formatting follows Vietnamese conventions (1.000.000,50).
const String _formatLocale = 'vi';

/// How many digits after the decimal point the currency uses.
/// Amounts are stored as integers in this smallest unit.
int decimalDigitsFor(String currency) => switch (currency) {
      'VND' || 'JPY' || 'KRW' => 0,
      _ => 2,
    };

String currencySymbol(String currency) => switch (currency) {
      'VND' => '₫',
      'USD' => r'$',
      'EUR' => '€',
      _ => currency,
    };

/// Formats an amount for display, e.g. 3000000 VND -> "3.000.000 ₫".
String formatMoney(int minorUnits, String currency) {
  final digits = decimalDigitsFor(currency);
  final format = NumberFormat.currency(
    locale: _formatLocale,
    symbol: currencySymbol(currency),
    decimalDigits: digits,
  );
  return format.format(minorUnits / math.pow(10, digits));
}

/// Formats an amount for an input field, without grouping or symbol.
String formatMoneyPlain(int minorUnits, String currency) {
  final digits = decimalDigitsFor(currency);
  if (digits == 0) return minorUnits.toString();
  return (minorUnits / math.pow(10, digits)).toStringAsFixed(digits);
}

/// Parses what the user typed into minor units. Returns null when the
/// input is empty or not a number.
///
/// For currencies without decimals every non-digit is ignored, so
/// "3.000.000" and "3,000,000" both read as three million.
/// Otherwise the last "." or "," is the decimal separator when at most
/// [decimalDigitsFor] digits follow it; any other mark is grouping.
int? parseMoney(String input, String currency) {
  final digits = decimalDigitsFor(currency);
  if (digits == 0) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.isEmpty ? null : int.tryParse(cleaned);
  }

  final cleaned = input.replaceAll(RegExp(r'[^0-9.,]'), '');
  if (cleaned.isEmpty) return null;
  final separators = RegExp(r'[.,]');
  final lastSeparator = cleaned.lastIndexOf(separators);
  String normalized;
  if (lastSeparator == -1) {
    normalized = cleaned;
  } else {
    final whole = cleaned.substring(0, lastSeparator).replaceAll(separators, '');
    final fraction = cleaned.substring(lastSeparator + 1);
    normalized =
        fraction.length <= digits ? '$whole.$fraction' : '$whole$fraction';
  }
  final value = double.tryParse(normalized);
  if (value == null) return null;
  return (value * math.pow(10, digits)).round();
}

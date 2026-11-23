// Unit tests for the number and money helpers.
// (Kept in widget_test.dart so `flutter create .` does not add its own
// default test that refers to a counter app.)
import 'package:flutter_test/flutter_test.dart';
import 'package:ime/utils/dates.dart';
import 'package:ime/utils/money.dart';
import 'package:ime/utils/numbers.dart';

void main() {
  group('parseMoney', () {
    test('reads VND with grouping marks', () {
      expect(parseMoney('3.000.000', 'VND'), 3000000);
      expect(parseMoney('3,000,000', 'VND'), 3000000);
      expect(parseMoney('3000000', 'VND'), 3000000);
    });

    test('reads USD with decimals', () {
      expect(parseMoney('1,000.50', 'USD'), 100050);
      expect(parseMoney('12,5', 'USD'), 1250);
      expect(parseMoney('7', 'USD'), 700);
    });

    test('returns null for empty or invalid input', () {
      expect(parseMoney('', 'VND'), isNull);
      expect(parseMoney('abc', 'VND'), isNull);
      expect(parseMoney('', 'USD'), isNull);
    });
  });

  group('formatMoney', () {
    test('groups VND thousands with dots', () {
      expect(formatMoney(3000000, 'VND'), contains('3.000.000'));
    });

    test('round-trips through the plain input format', () {
      const amount = 100050;
      final plain = formatMoneyPlain(amount, 'USD');
      expect(parseMoney(plain, 'USD'), amount);
    });
  });

  group('area', () {
    test('parses commas and dots', () {
      expect(parseArea('20,5'), 20.5);
      expect(parseArea('20'), 20);
      expect(parseArea('-3'), isNull);
    });

    test('formats whole numbers without decimals', () {
      expect(formatArea(20), '20');
      expect(formatArea(20.5), '20.5');
    });
  });

  group('dueStatusFor', () {
    final today = DateTime(2026, 11, 23);

    test('counts days overdue', () {
      final status = dueStatusFor(dueDate: DateTime(2026, 11, 20), today: today);
      expect(status.state, DueState.overdue);
      expect(status.days, 3);
    });

    test('detects due today', () {
      final status = dueStatusFor(dueDate: today, today: today);
      expect(status.state, DueState.today);
    });

    test('a promise still ahead wins over overdue', () {
      final status = dueStatusFor(
        dueDate: DateTime(2026, 11, 10),
        snoozedUntil: DateTime(2026, 11, 25),
        today: today,
      );
      expect(status.state, DueState.promised);
      expect(status.date, DateTime(2026, 11, 25));
    });

    test('a broken promise falls back to overdue', () {
      final status = dueStatusFor(
        dueDate: DateTime(2026, 11, 10),
        snoozedUntil: DateTime(2026, 11, 20),
        today: today,
      );
      expect(status.state, DueState.overdue);
      expect(status.days, 13);
    });
  });

  group('dates', () {
    test('round-trips ISO dates', () {
      final date = DateTime(2026, 1, 5);
      expect(isoDate(date), '2026-01-05');
      expect(parseIsoDate('2026-01-05'), date);
      expect(parseIsoDate('bad'), isNull);
    });
  });
}

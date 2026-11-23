/// Calendar dates are stored as ISO strings `yyyy-MM-dd`.
String isoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// Parses `yyyy-MM-dd` into a local date at midnight. Null when invalid.
DateTime? parseIsoDate(String? value) {
  if (value == null || value.length < 10) return null;
  final year = int.tryParse(value.substring(0, 4));
  final month = int.tryParse(value.substring(5, 7));
  final day = int.tryParse(value.substring(8, 10));
  if (year == null || month == null || day == null) return null;
  return DateTime(year, month, day);
}

/// "dd/MM", e.g. 25/11.
String shortDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$day/$month';
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// First day of the month that contains [date].
DateTime monthStart(DateTime date) => DateTime(date.year, date.month);

/// First day of the following month.
DateTime nextMonthStart(DateTime date) => DateTime(date.year, date.month + 1);

enum DueState { overdue, today, promised, upcoming }

/// Where an unpaid due stands relative to [today].
class DueStatus {
  const DueStatus(this.state, {this.days = 0, this.date});

  final DueState state;

  /// Days overdue, only for [DueState.overdue].
  final int days;

  /// The promised date for [DueState.promised], the due date for
  /// [DueState.upcoming].
  final DateTime? date;
}

/// A promise to pay (snooze) that is still ahead wins over everything else;
/// otherwise the due date decides.
DueStatus dueStatusFor({
  required DateTime dueDate,
  DateTime? snoozedUntil,
  required DateTime today,
}) {
  final day = dateOnly(today);
  final due = dateOnly(dueDate);
  final promised = snoozedUntil == null ? null : dateOnly(snoozedUntil);

  if (promised != null && !promised.isBefore(day)) {
    return DueStatus(DueState.promised, date: promised);
  }
  if (due.isBefore(day)) {
    // Days between two local midnights; rounding absorbs daylight saving.
    final days = (day.difference(due).inHours / 24).round();
    return DueStatus(DueState.overdue, days: days);
  }
  if (due == day) return const DueStatus(DueState.today);
  return DueStatus(DueState.upcoming, date: due);
}

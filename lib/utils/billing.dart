import 'dart:math' as math;

import '../data/models.dart';

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// The billing date one [cycle] after [from].
///
/// Monthly bills stay on [anchorDay] (the move-in day). In months that are
/// too short they fall on the last day instead, and return to [anchorDay]
/// the month after: 31 Jan -> 28 Feb -> 31 Mar.
DateTime addCycle(DateTime from, BillingCycle cycle, int anchorDay) {
  switch (cycle) {
    case BillingCycle.day:
      return DateTime(from.year, from.month, from.day + 1);
    case BillingCycle.week:
      return DateTime(from.year, from.month, from.day + 7);
    case BillingCycle.month:
      final year = from.month == 12 ? from.year + 1 : from.year;
      final month = from.month == 12 ? 1 : from.month + 1;
      return DateTime(year, month, math.min(anchorDay, daysInMonth(year, month)));
  }
}

/// The first bill of a contract starting on [start].
///
/// Postpaid rent (live first, pay after) is first collected one cycle
/// after moving in; prepaid rent on the move-in day itself.
DateTime firstDueDate(DateTime start, BillingCycle cycle, RentTiming timing) {
  if (timing == RentTiming.prepaid) return start;
  return addCycle(start, cycle, start.day);
}

/// Deposit suggested for a new contract: [months] of rent.
int suggestedDeposit(int rentAmount, int months) => rentAmount * months;

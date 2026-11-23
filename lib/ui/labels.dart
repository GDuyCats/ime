import 'package:flutter/material.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../utils/money.dart';

String templateLabel(AppLocalizations l10n, BookTemplate template) {
  return switch (template) {
    BookTemplate.rental => l10n.templateRental,
    BookTemplate.trading => l10n.templateTrading,
    BookTemplate.blank => l10n.templateBlank,
  };
}

String templateDescription(AppLocalizations l10n, BookTemplate template) {
  return switch (template) {
    BookTemplate.rental => l10n.templateRentalDesc,
    BookTemplate.trading => l10n.templateTradingDesc,
    BookTemplate.blank => l10n.templateBlankDesc,
  };
}

IconData templateIcon(BookTemplate template) {
  return switch (template) {
    BookTemplate.rental => Icons.apartment,
    BookTemplate.trading => Icons.storefront_outlined,
    BookTemplate.blank => Icons.menu_book_outlined,
  };
}

/// Heading for the item list of a book, e.g. "Properties" for rentals.
String itemsSectionLabel(AppLocalizations l10n, BookTemplate template) {
  return switch (template) {
    BookTemplate.rental => l10n.itemsRental,
    BookTemplate.trading => l10n.itemsTrading,
    BookTemplate.blank => l10n.itemsBlank,
  };
}

ItemKind defaultItemKind(BookTemplate template) {
  return switch (template) {
    BookTemplate.rental => ItemKind.room,
    BookTemplate.trading => ItemKind.product,
    BookTemplate.blank => ItemKind.other,
  };
}

String itemKindLabel(AppLocalizations l10n, ItemKind kind) {
  return switch (kind) {
    ItemKind.room => l10n.kindRoom,
    ItemKind.house => l10n.kindHouse,
    ItemKind.vehicle => l10n.kindVehicle,
    ItemKind.product => l10n.kindProduct,
    ItemKind.other => l10n.kindOther,
  };
}

IconData itemKindIcon(ItemKind kind) {
  return switch (kind) {
    ItemKind.room => Icons.meeting_room_outlined,
    ItemKind.house => Icons.home_outlined,
    ItemKind.vehicle => Icons.two_wheeler,
    ItemKind.product => Icons.inventory_2_outlined,
    ItemKind.other => Icons.category_outlined,
  };
}

String calcTypeLabel(AppLocalizations l10n, ChargeCalcType type) {
  return switch (type) {
    ChargeCalcType.meter => l10n.calcMeter,
    ChargeCalcType.perPerson => l10n.calcPerPerson,
    ChargeCalcType.fixed => l10n.calcFixed,
    ChargeCalcType.manual => l10n.calcManual,
  };
}

/// Label of the price field, which depends on how the charge is counted.
String chargePriceLabel(AppLocalizations l10n, ChargeCalcType type) {
  return switch (type) {
    ChargeCalcType.meter => l10n.priceMeter,
    ChargeCalcType.perPerson => l10n.pricePerPerson,
    ChargeCalcType.fixed || ChargeCalcType.manual => l10n.priceFixed,
  };
}

/// One-line summary of a charge, e.g. "3.500 ₫/unit".
String chargeSummary(
  AppLocalizations l10n,
  ChargeInput charge,
  String currency,
) {
  final price = formatMoney(charge.unitPrice, currency);
  return switch (charge.calcType) {
    ChargeCalcType.meter => l10n.unitMeter(price),
    ChargeCalcType.perPerson => l10n.unitPerPerson(price),
    ChargeCalcType.fixed => l10n.unitFixed(price),
    ChargeCalcType.manual => l10n.calcManualShort,
  };
}

String cycleLabel(AppLocalizations l10n, BillingCycle cycle) {
  return switch (cycle) {
    BillingCycle.day => l10n.cycleDay,
    BillingCycle.week => l10n.cycleWeek,
    BillingCycle.month => l10n.cycleMonth,
  };
}

/// Rent with its period, e.g. "3.000.000 ₫/month".
String rentPerCycle(
  AppLocalizations l10n,
  int amount,
  String currency,
  BillingCycle cycle,
) {
  final money = formatMoney(amount, currency);
  return switch (cycle) {
    BillingCycle.day => l10n.rentPerDay(money),
    BillingCycle.week => l10n.rentPerWeek(money),
    BillingCycle.month => l10n.rentPerMonth(money),
  };
}

/// A template's name, or "Default template" for the one created
/// automatically from older default charges.
String templateName(AppLocalizations l10n, RentalTemplate template) {
  return template.name.trim().isEmpty ? l10n.templateUnnamed : template.name;
}

/// e.g. "3.000.000 ₫/month · 3 charges" or "Room price · 2 charges".
String templateSummary(
  AppLocalizations l10n,
  RentalTemplate template,
  String currency,
) {
  final rent = template.rentAmount;
  final rentText = rent == null
      ? l10n.templateRoomPrice
      : rentPerCycle(l10n, rent, currency, template.cycle);
  return '$rentText · ${l10n.chargeCount(template.charges.length)}';
}

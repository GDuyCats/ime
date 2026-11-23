import 'package:flutter/material.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';

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

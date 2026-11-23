// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IME';

  @override
  String get booksTitle => 'Books';

  @override
  String get noBooksTitle => 'No books yet';

  @override
  String get noBooksBody =>
      'Create a book for each thing you manage: a boarding house, a shop, a rental vehicle.';

  @override
  String get createBook => 'Create book';

  @override
  String get editBook => 'Edit book';

  @override
  String get bookName => 'Book name';

  @override
  String get bookNameHint => 'Boarding house Q7';

  @override
  String get bookTemplate => 'Template';

  @override
  String get templateRental => 'Rental';

  @override
  String get templateRentalDesc =>
      'Rooms, houses and vehicles with contracts and periodic bills';

  @override
  String get templateTrading => 'Trading';

  @override
  String get templateTradingDesc =>
      'Income and expenses by category, monthly profit';

  @override
  String get templateBlank => 'Blank';

  @override
  String get templateBlankDesc => 'Set everything up yourself';

  @override
  String get templateLocked =>
      'The template and currency can\'t be changed after the book is created.';

  @override
  String get currency => 'Currency';

  @override
  String get note => 'Note';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get deleteBookTitle => 'Delete this book?';

  @override
  String get deleteBookBody => 'The book and everything in it will be removed.';

  @override
  String get deleteItemTitle => 'Delete this item?';

  @override
  String get deleteItemBody => 'This item will be removed from the book.';

  @override
  String get itemsRental => 'Properties';

  @override
  String get itemsTrading => 'Products';

  @override
  String get itemsBlank => 'Items';

  @override
  String get addItem => 'Add';

  @override
  String get editItem => 'Edit';

  @override
  String get noItems => 'Nothing here yet. Tap Add to create the first one.';

  @override
  String get itemName => 'Name';

  @override
  String get itemNameHint => 'Room 101';

  @override
  String get itemKind => 'Type';

  @override
  String get kindRoom => 'Room';

  @override
  String get kindHouse => 'House';

  @override
  String get kindVehicle => 'Vehicle';

  @override
  String get kindProduct => 'Product';

  @override
  String get kindOther => 'Other';

  @override
  String get area => 'Area (m²)';

  @override
  String get defaultPrice => 'Default price';

  @override
  String get filterAll => 'All';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String errorLoading(String message) {
    return 'Something went wrong: $message';
  }

  @override
  String get catRent => 'Rent';

  @override
  String get catElectricity => 'Electricity';

  @override
  String get catWater => 'Water';

  @override
  String get catInternet => 'Internet';

  @override
  String get catRepairs => 'Repairs';

  @override
  String get catSales => 'Sales';

  @override
  String get catIngredients => 'Ingredients';

  @override
  String get catPackaging => 'Packaging';

  @override
  String get catPremises => 'Premises rent';

  @override
  String get catWages => 'Wages';

  @override
  String get catOtherIncome => 'Other income';

  @override
  String get catOtherExpense => 'Other expense';

  @override
  String get navOverview => 'Overview';

  @override
  String get navBooks => 'Books';

  @override
  String monthTitle(int month, int year) {
    return 'Month $month/$year';
  }

  @override
  String get statIncome => 'Received';

  @override
  String get statExpense => 'Spent';

  @override
  String get statProfit => 'Profit';

  @override
  String get statLoss => 'Loss';

  @override
  String get toHandleTitle => 'To handle';

  @override
  String get toHandleEmpty =>
      'Nothing to collect or pay. Amounts show up here once you add contracts or recurring payments.';

  @override
  String get booksSection => 'Your books';

  @override
  String get dueReceivable => 'To collect';

  @override
  String get duePayable => 'To pay';

  @override
  String badgeOverdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String get badgeToday => 'Due today';

  @override
  String badgePromised(String date) {
    return 'Promised $date';
  }

  @override
  String badgeDue(String date) {
    return 'Due $date';
  }
}

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

  @override
  String get bookSettings => 'Book settings';

  @override
  String get rentTimingLabel => 'Rent collection';

  @override
  String get rentPostpaid => 'After the period';

  @override
  String get rentPostpaidDesc =>
      'Tenant lives first and pays at the end of each period.';

  @override
  String get rentPrepaid => 'Before the period';

  @override
  String get rentPrepaidDesc => 'Tenant pays at the start of each period.';

  @override
  String get depositMonthsLabel => 'Default deposit (months of rent)';

  @override
  String get noticeDaysLabel => 'Days of notice before moving out';

  @override
  String get noCharges => 'No extra charges yet.';

  @override
  String get addCharge => 'Add charge';

  @override
  String get editCharge => 'Edit charge';

  @override
  String get chargeName => 'Name';

  @override
  String get chargeNameHint => 'Electricity';

  @override
  String get calcType => 'Calculated by';

  @override
  String get calcMeter => 'Meter reading';

  @override
  String get calcPerPerson => 'Per person';

  @override
  String get calcFixed => 'Fixed amount';

  @override
  String get calcManual => 'Typed each period';

  @override
  String get calcManualShort => 'Typed each period';

  @override
  String get priceMeter => 'Price per unit';

  @override
  String get pricePerPerson => 'Price per person';

  @override
  String get priceFixed => 'Amount per period';

  @override
  String unitMeter(String price) {
    return '$price/unit';
  }

  @override
  String unitPerPerson(String price) {
    return '$price/person';
  }

  @override
  String unitFixed(String price) {
    return '$price/period';
  }

  @override
  String get meterStart => 'Starting reading';

  @override
  String meterReadingValue(String reading) {
    return 'Starts at $reading';
  }

  @override
  String get removeCharge => 'Remove';

  @override
  String get mustBeWholeNumber => 'Enter a whole number';

  @override
  String get currentContract => 'Contract';

  @override
  String get roomVacant => 'Vacant';

  @override
  String get roomVacantBody => 'Nobody rents this right now.';

  @override
  String get rentOut => 'Rent out';

  @override
  String get editContract => 'Edit contract';

  @override
  String get tenant => 'Tenant';

  @override
  String get rentAmount => 'Rent';

  @override
  String get cycle => 'Billing cycle';

  @override
  String get cycleDay => 'Daily';

  @override
  String get cycleWeek => 'Weekly';

  @override
  String get cycleMonth => 'Monthly';

  @override
  String rentPerDay(String amount) {
    return '$amount/day';
  }

  @override
  String rentPerWeek(String amount) {
    return '$amount/week';
  }

  @override
  String rentPerMonth(String amount) {
    return '$amount/month';
  }

  @override
  String get moveInDate => 'Move-in date';

  @override
  String get nextDue => 'Next bill';

  @override
  String firstDueInfo(String date) {
    return 'First bill: $date';
  }

  @override
  String get occupants => 'Occupants';

  @override
  String get deposit => 'Deposit';

  @override
  String get depositHeld => 'held';

  @override
  String get depositNone => 'No deposit';

  @override
  String get extraCharges => 'Extra charges';

  @override
  String get contractLocked =>
      'The move-in date and billing cycle can\'t change after the contract is created.';

  @override
  String get tenantExisting => 'Saved person';

  @override
  String get tenantNew => 'New person';

  @override
  String get chooseTenant => 'Choose a tenant';

  @override
  String get noContactsYet => 'Nobody is saved yet. Choose New person.';

  @override
  String get phone => 'Phone';

  @override
  String get idNumber => 'ID number';

  @override
  String get personName => 'Full name';

  @override
  String get personNameHint => 'Nguyen Van A';

  @override
  String get navPeople => 'People';

  @override
  String get addPerson => 'Add person';

  @override
  String get editPerson => 'Edit person';

  @override
  String get noPeopleTitle => 'No one yet';

  @override
  String get noPeopleBody =>
      'Tenants show up here when you rent out a room. You can also add people yourself.';

  @override
  String get notRenting => 'Not renting';

  @override
  String get cannotDeleteRenting =>
      'This person still rents something. End the contract before deleting.';

  @override
  String get deletePersonTitle => 'Delete this person?';

  @override
  String get deletePersonBody => 'This person will be removed from the list.';

  @override
  String get quickPick => 'Quick pick';

  @override
  String get presetElectricity => 'Electricity';

  @override
  String get presetWater => 'Water';

  @override
  String get presetInternet => 'Wifi';

  @override
  String get presetTrash => 'Trash';

  @override
  String get presetParking => 'Parking';

  @override
  String get templatesTitle => 'Rental templates';

  @override
  String get templatesHint =>
      'Save the usual rent, deposit and charges once, then fill the rent-out form for a new tenant in one tap.';

  @override
  String get noTemplates =>
      'No templates yet. Add one here, or tap \"Save as template\" when renting out.';

  @override
  String get templateDefaultBadge => 'Default';

  @override
  String get addTemplate => 'Add template';

  @override
  String get editTemplate => 'Edit template';

  @override
  String get templateUnnamed => 'Default template';

  @override
  String get templateRoomPrice => 'Room\'s own price';

  @override
  String chargeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count extra charges',
      one: '1 extra charge',
      zero: 'no extra charges',
    );
    return '$_temp0';
  }

  @override
  String get deleteTemplateTitle => 'Delete this template?';

  @override
  String get deleteTemplateBody =>
      'Contracts already made from it stay the same.';

  @override
  String get templateNameLabel => 'Template name';

  @override
  String get templateNameHint => 'Standard room';

  @override
  String get templateRentHelper => 'Leave empty to use each room\'s own price.';

  @override
  String get templateIsDefault => 'Default template';

  @override
  String get templateIsDefaultHint =>
      'Filled in automatically when you rent out a room.';

  @override
  String get useTemplate => 'Use template';

  @override
  String get saveAsTemplate => 'Save as template';

  @override
  String templateSaved(String name) {
    return 'Saved template \"$name\"';
  }
}

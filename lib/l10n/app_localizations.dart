import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'IME'**
  String get appTitle;

  /// No description provided for @booksTitle.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get booksTitle;

  /// No description provided for @noBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'No books yet'**
  String get noBooksTitle;

  /// No description provided for @noBooksBody.
  ///
  /// In en, this message translates to:
  /// **'Create a book for each thing you manage: a boarding house, a shop, a rental vehicle.'**
  String get noBooksBody;

  /// No description provided for @createBook.
  ///
  /// In en, this message translates to:
  /// **'Create book'**
  String get createBook;

  /// No description provided for @editBook.
  ///
  /// In en, this message translates to:
  /// **'Edit book'**
  String get editBook;

  /// No description provided for @bookName.
  ///
  /// In en, this message translates to:
  /// **'Book name'**
  String get bookName;

  /// No description provided for @bookNameHint.
  ///
  /// In en, this message translates to:
  /// **'Boarding house Q7'**
  String get bookNameHint;

  /// No description provided for @bookTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get bookTemplate;

  /// No description provided for @templateRental.
  ///
  /// In en, this message translates to:
  /// **'Rental'**
  String get templateRental;

  /// No description provided for @templateRentalDesc.
  ///
  /// In en, this message translates to:
  /// **'Rooms, houses and vehicles with contracts and periodic bills'**
  String get templateRentalDesc;

  /// No description provided for @templateTrading.
  ///
  /// In en, this message translates to:
  /// **'Trading'**
  String get templateTrading;

  /// No description provided for @templateTradingDesc.
  ///
  /// In en, this message translates to:
  /// **'Income and expenses by category, monthly profit'**
  String get templateTradingDesc;

  /// No description provided for @templateBlank.
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get templateBlank;

  /// No description provided for @templateBlankDesc.
  ///
  /// In en, this message translates to:
  /// **'Set everything up yourself'**
  String get templateBlankDesc;

  /// No description provided for @templateLocked.
  ///
  /// In en, this message translates to:
  /// **'The template and currency can\'t be changed after the book is created.'**
  String get templateLocked;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @deleteBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this book?'**
  String get deleteBookTitle;

  /// No description provided for @deleteBookBody.
  ///
  /// In en, this message translates to:
  /// **'The book and everything in it will be removed.'**
  String get deleteBookBody;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemBody.
  ///
  /// In en, this message translates to:
  /// **'This item will be removed from the book.'**
  String get deleteItemBody;

  /// No description provided for @itemsRental.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get itemsRental;

  /// No description provided for @itemsTrading.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get itemsTrading;

  /// No description provided for @itemsBlank.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsBlank;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editItem;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Tap Add to create the first one.'**
  String get noItems;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get itemName;

  /// No description provided for @itemNameHint.
  ///
  /// In en, this message translates to:
  /// **'Room 101'**
  String get itemNameHint;

  /// No description provided for @itemKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get itemKind;

  /// No description provided for @kindRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get kindRoom;

  /// No description provided for @kindHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get kindHouse;

  /// No description provided for @kindVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get kindVehicle;

  /// No description provided for @kindProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get kindProduct;

  /// No description provided for @kindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get kindOther;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area (m²)'**
  String get area;

  /// No description provided for @defaultPrice.
  ///
  /// In en, this message translates to:
  /// **'Default price'**
  String get defaultPrice;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {message}'**
  String errorLoading(String message);

  /// No description provided for @catRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// No description provided for @catElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get catElectricity;

  /// No description provided for @catWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get catWater;

  /// No description provided for @catInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get catInternet;

  /// No description provided for @catRepairs.
  ///
  /// In en, this message translates to:
  /// **'Repairs'**
  String get catRepairs;

  /// No description provided for @catSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get catSales;

  /// No description provided for @catIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get catIngredients;

  /// No description provided for @catPackaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging'**
  String get catPackaging;

  /// No description provided for @catPremises.
  ///
  /// In en, this message translates to:
  /// **'Premises rent'**
  String get catPremises;

  /// No description provided for @catWages.
  ///
  /// In en, this message translates to:
  /// **'Wages'**
  String get catWages;

  /// No description provided for @catOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get catOtherIncome;

  /// No description provided for @catOtherExpense.
  ///
  /// In en, this message translates to:
  /// **'Other expense'**
  String get catOtherExpense;

  /// No description provided for @navOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// No description provided for @navBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get navBooks;

  /// No description provided for @monthTitle.
  ///
  /// In en, this message translates to:
  /// **'Month {month}/{year}'**
  String monthTitle(int month, int year);

  /// No description provided for @statIncome.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get statIncome;

  /// No description provided for @statExpense.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get statExpense;

  /// No description provided for @statProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get statProfit;

  /// No description provided for @statLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get statLoss;

  /// No description provided for @toHandleTitle.
  ///
  /// In en, this message translates to:
  /// **'To handle'**
  String get toHandleTitle;

  /// No description provided for @toHandleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to collect or pay. Amounts show up here once you add contracts or recurring payments.'**
  String get toHandleEmpty;

  /// No description provided for @booksSection.
  ///
  /// In en, this message translates to:
  /// **'Your books'**
  String get booksSection;

  /// No description provided for @dueReceivable.
  ///
  /// In en, this message translates to:
  /// **'To collect'**
  String get dueReceivable;

  /// No description provided for @duePayable.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get duePayable;

  /// No description provided for @badgeOverdue.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day overdue} other{{days} days overdue}}'**
  String badgeOverdue(int days);

  /// No description provided for @badgeToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get badgeToday;

  /// No description provided for @badgePromised.
  ///
  /// In en, this message translates to:
  /// **'Promised {date}'**
  String badgePromised(String date);

  /// No description provided for @badgeDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String badgeDue(String date);

  /// No description provided for @bookSettings.
  ///
  /// In en, this message translates to:
  /// **'Book settings'**
  String get bookSettings;

  /// No description provided for @rentTimingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rent collection'**
  String get rentTimingLabel;

  /// No description provided for @rentPostpaid.
  ///
  /// In en, this message translates to:
  /// **'After the period'**
  String get rentPostpaid;

  /// No description provided for @rentPostpaidDesc.
  ///
  /// In en, this message translates to:
  /// **'Tenant lives first and pays at the end of each period.'**
  String get rentPostpaidDesc;

  /// No description provided for @rentPrepaid.
  ///
  /// In en, this message translates to:
  /// **'Before the period'**
  String get rentPrepaid;

  /// No description provided for @rentPrepaidDesc.
  ///
  /// In en, this message translates to:
  /// **'Tenant pays at the start of each period.'**
  String get rentPrepaidDesc;

  /// No description provided for @depositMonthsLabel.
  ///
  /// In en, this message translates to:
  /// **'Default deposit (months of rent)'**
  String get depositMonthsLabel;

  /// No description provided for @noticeDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days of notice before moving out'**
  String get noticeDaysLabel;

  /// No description provided for @defaultChargesTitle.
  ///
  /// In en, this message translates to:
  /// **'Default charges'**
  String get defaultChargesTitle;

  /// No description provided for @defaultChargesHint.
  ///
  /// In en, this message translates to:
  /// **'New contracts start with these charges. Each room can still change them.'**
  String get defaultChargesHint;

  /// No description provided for @noCharges.
  ///
  /// In en, this message translates to:
  /// **'No extra charges yet.'**
  String get noCharges;

  /// No description provided for @addCharge.
  ///
  /// In en, this message translates to:
  /// **'Add charge'**
  String get addCharge;

  /// No description provided for @editCharge.
  ///
  /// In en, this message translates to:
  /// **'Edit charge'**
  String get editCharge;

  /// No description provided for @chargeName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get chargeName;

  /// No description provided for @chargeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get chargeNameHint;

  /// No description provided for @calcType.
  ///
  /// In en, this message translates to:
  /// **'Calculated by'**
  String get calcType;

  /// No description provided for @calcMeter.
  ///
  /// In en, this message translates to:
  /// **'Meter reading'**
  String get calcMeter;

  /// No description provided for @calcPerPerson.
  ///
  /// In en, this message translates to:
  /// **'Per person'**
  String get calcPerPerson;

  /// No description provided for @calcFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount'**
  String get calcFixed;

  /// No description provided for @calcManual.
  ///
  /// In en, this message translates to:
  /// **'Typed each period'**
  String get calcManual;

  /// No description provided for @calcManualShort.
  ///
  /// In en, this message translates to:
  /// **'Typed each period'**
  String get calcManualShort;

  /// No description provided for @priceMeter.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get priceMeter;

  /// No description provided for @pricePerPerson.
  ///
  /// In en, this message translates to:
  /// **'Price per person'**
  String get pricePerPerson;

  /// No description provided for @priceFixed.
  ///
  /// In en, this message translates to:
  /// **'Amount per period'**
  String get priceFixed;

  /// No description provided for @unitMeter.
  ///
  /// In en, this message translates to:
  /// **'{price}/unit'**
  String unitMeter(String price);

  /// No description provided for @unitPerPerson.
  ///
  /// In en, this message translates to:
  /// **'{price}/person'**
  String unitPerPerson(String price);

  /// No description provided for @unitFixed.
  ///
  /// In en, this message translates to:
  /// **'{price}/period'**
  String unitFixed(String price);

  /// No description provided for @meterStart.
  ///
  /// In en, this message translates to:
  /// **'Starting reading'**
  String get meterStart;

  /// No description provided for @meterReadingValue.
  ///
  /// In en, this message translates to:
  /// **'Starts at {reading}'**
  String meterReadingValue(String reading);

  /// No description provided for @removeCharge.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeCharge;

  /// No description provided for @mustBeWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get mustBeWholeNumber;

  /// No description provided for @currentContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get currentContract;

  /// No description provided for @roomVacant.
  ///
  /// In en, this message translates to:
  /// **'Vacant'**
  String get roomVacant;

  /// No description provided for @roomVacantBody.
  ///
  /// In en, this message translates to:
  /// **'Nobody rents this right now.'**
  String get roomVacantBody;

  /// No description provided for @rentOut.
  ///
  /// In en, this message translates to:
  /// **'Rent out'**
  String get rentOut;

  /// No description provided for @editContract.
  ///
  /// In en, this message translates to:
  /// **'Edit contract'**
  String get editContract;

  /// No description provided for @tenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get tenant;

  /// No description provided for @rentAmount.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rentAmount;

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Billing cycle'**
  String get cycle;

  /// No description provided for @cycleDay.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get cycleDay;

  /// No description provided for @cycleWeek.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get cycleWeek;

  /// No description provided for @cycleMonth.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get cycleMonth;

  /// No description provided for @rentPerDay.
  ///
  /// In en, this message translates to:
  /// **'{amount}/day'**
  String rentPerDay(String amount);

  /// No description provided for @rentPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{amount}/week'**
  String rentPerWeek(String amount);

  /// No description provided for @rentPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount}/month'**
  String rentPerMonth(String amount);

  /// No description provided for @moveInDate.
  ///
  /// In en, this message translates to:
  /// **'Move-in date'**
  String get moveInDate;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'Next bill'**
  String get nextDue;

  /// No description provided for @firstDueInfo.
  ///
  /// In en, this message translates to:
  /// **'First bill: {date}'**
  String firstDueInfo(String date);

  /// No description provided for @occupants.
  ///
  /// In en, this message translates to:
  /// **'Occupants'**
  String get occupants;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @depositHeld.
  ///
  /// In en, this message translates to:
  /// **'held'**
  String get depositHeld;

  /// No description provided for @depositNone.
  ///
  /// In en, this message translates to:
  /// **'No deposit'**
  String get depositNone;

  /// No description provided for @extraCharges.
  ///
  /// In en, this message translates to:
  /// **'Extra charges'**
  String get extraCharges;

  /// No description provided for @contractLocked.
  ///
  /// In en, this message translates to:
  /// **'The move-in date and billing cycle can\'t change after the contract is created.'**
  String get contractLocked;

  /// No description provided for @tenantExisting.
  ///
  /// In en, this message translates to:
  /// **'Saved person'**
  String get tenantExisting;

  /// No description provided for @tenantNew.
  ///
  /// In en, this message translates to:
  /// **'New person'**
  String get tenantNew;

  /// No description provided for @chooseTenant.
  ///
  /// In en, this message translates to:
  /// **'Choose a tenant'**
  String get chooseTenant;

  /// No description provided for @noContactsYet.
  ///
  /// In en, this message translates to:
  /// **'Nobody is saved yet. Choose New person.'**
  String get noContactsYet;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID number'**
  String get idNumber;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get personName;

  /// No description provided for @personNameHint.
  ///
  /// In en, this message translates to:
  /// **'Nguyen Van A'**
  String get personNameHint;

  /// No description provided for @navPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get navPeople;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPerson;

  /// No description provided for @editPerson.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get editPerson;

  /// No description provided for @noPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'No one yet'**
  String get noPeopleTitle;

  /// No description provided for @noPeopleBody.
  ///
  /// In en, this message translates to:
  /// **'Tenants show up here when you rent out a room. You can also add people yourself.'**
  String get noPeopleBody;

  /// No description provided for @notRenting.
  ///
  /// In en, this message translates to:
  /// **'Not renting'**
  String get notRenting;

  /// No description provided for @cannotDeleteRenting.
  ///
  /// In en, this message translates to:
  /// **'This person still rents something. End the contract before deleting.'**
  String get cannotDeleteRenting;

  /// No description provided for @deletePersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this person?'**
  String get deletePersonTitle;

  /// No description provided for @deletePersonBody.
  ///
  /// In en, this message translates to:
  /// **'This person will be removed from the list.'**
  String get deletePersonBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

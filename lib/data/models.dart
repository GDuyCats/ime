/// The preset a book was created from. It decides the default categories,
/// item kinds and which screens the book shows.
enum BookTemplate {
  rental,
  trading,
  blank;

  static BookTemplate fromDb(String value) => BookTemplate.values
      .firstWhere((t) => t.name == value, orElse: () => BookTemplate.blank);
}

enum ItemKind {
  room,
  house,
  vehicle,
  product,
  other;

  static ItemKind fromDb(String value) => ItemKind.values
      .firstWhere((k) => k.name == value, orElse: () => ItemKind.other);

  /// Whether an area in square meters makes sense for this kind.
  bool get hasArea =>
      this == ItemKind.room || this == ItemKind.house || this == ItemKind.other;
}

enum CategoryDirection {
  income,
  expense;

  static CategoryDirection fromDb(String value) => CategoryDirection.values
      .firstWhere((d) => d.name == value, orElse: () => CategoryDirection.expense);
}

class Book {
  const Book({
    required this.id,
    required this.name,
    required this.template,
    required this.currency,
    this.note,
    this.rentTiming = RentTiming.postpaid,
    this.depositMonths = 1,
    this.noticeDays = 14,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final BookTemplate template;
  final String currency;
  final String? note;

  /// Rental defaults, edited in the book settings screen.
  final RentTiming rentTiming;
  final int depositMonths;
  final int noticeDays;
  final int createdAt;
  final int updatedAt;

  factory Book.fromMap(Map<String, Object?> map) {
    return Book(
      id: map['id']! as String,
      name: map['name']! as String,
      template: BookTemplate.fromDb(map['template']! as String),
      currency: map['currency']! as String,
      note: map['note'] as String?,
      rentTiming: RentTiming.fromDb(map['rent_timing'] as String?),
      depositMonths: (map['deposit_months'] as int?) ?? 1,
      noticeDays: (map['notice_days'] as int?) ?? 14,
      createdAt: map['created_at']! as int,
      updatedAt: map['updated_at']! as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'template': template.name,
      'currency': currency,
      'note': note,
      'rent_timing': rentTiming.name,
      'deposit_months': depositMonths,
      'notice_days': noticeDays,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// A book together with numbers shown in the book list.
class BookSummary {
  const BookSummary({required this.book, required this.itemCount});

  final Book book;
  final int itemCount;
}

class Item {
  const Item({
    required this.id,
    required this.bookId,
    required this.name,
    required this.kind,
    this.areaM2,
    this.defaultPrice,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String bookId;
  final String name;
  final ItemKind kind;
  final double? areaM2;

  /// Default price in the book currency's minor unit.
  final int? defaultPrice;
  final String? note;
  final int createdAt;
  final int updatedAt;

  factory Item.fromMap(Map<String, Object?> map) {
    return Item(
      id: map['id']! as String,
      bookId: map['book_id']! as String,
      name: map['name']! as String,
      kind: ItemKind.fromDb(map['kind']! as String),
      areaM2: (map['area_m2'] as num?)?.toDouble(),
      defaultPrice: map['default_price'] as int?,
      note: map['note'] as String?,
      createdAt: map['created_at']! as int,
      updatedAt: map['updated_at']! as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'name': name,
      'kind': kind.name,
      'area_m2': areaM2,
      'default_price': defaultPrice,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// A category to create together with a new book.
class CategorySeed {
  const CategorySeed(this.name, this.direction);

  final String name;
  final CategoryDirection direction;
}

/// When rent for a period is collected.
enum RentTiming {
  /// At the end of the period: the tenant lives first, then pays.
  postpaid,

  /// At the start of the period.
  prepaid;

  static RentTiming fromDb(String? value) => RentTiming.values
      .firstWhere((t) => t.name == value, orElse: () => RentTiming.postpaid);
}

enum BillingCycle {
  day,
  week,
  month;

  static BillingCycle fromDb(String value) => BillingCycle.values
      .firstWhere((c) => c.name == value, orElse: () => BillingCycle.month);
}

/// How an extra charge (electricity, water, wifi, ...) is calculated.
enum ChargeCalcType {
  /// (new reading - old reading) x unit price.
  meter('meter'),

  /// Number of occupants x unit price.
  perPerson('per_person'),

  /// The same amount every period.
  fixed('fixed'),

  /// Typed in each period.
  manual('manual');

  const ChargeCalcType(this.dbValue);

  final String dbValue;

  static ChargeCalcType fromDb(String value) => ChargeCalcType.values
      .firstWhere((t) => t.dbValue == value, orElse: () => ChargeCalcType.manual);
}

enum DepositStatus {
  none,
  held,
  returned,
  kept;

  static DepositStatus fromDb(String value) => DepositStatus.values
      .firstWhere((s) => s.name == value, orElse: () => DepositStatus.none);
}

enum ContractStatus {
  active,
  ended;

  static ContractStatus fromDb(String value) => ContractStatus.values
      .firstWhere((s) => s.name == value, orElse: () => ContractStatus.active);
}

/// A person: tenant, supplier or buyer.
class Contact {
  const Contact({
    required this.id,
    required this.name,
    this.phone,
    this.idNumber,
    this.note,
  });

  final String id;
  final String name;
  final String? phone;
  final String? idNumber;
  final String? note;

  factory Contact.fromMap(Map<String, Object?> map) {
    return Contact(
      id: map['id']! as String,
      name: map['name']! as String,
      phone: map['phone'] as String?,
      idNumber: map['id_number'] as String?,
      note: map['note'] as String?,
    );
  }
}

/// A contact plus the places they rent right now, for the people list.
class ContactSummary {
  const ContactSummary({required this.contact, required this.rentals});

  final Contact contact;

  /// Lines such as "Room 101 · Boarding house 1".
  final List<String> rentals;
}

/// An extra charge as stored: a book default or one contract's charge.
class ChargeTemplate {
  const ChargeTemplate({
    required this.id,
    required this.name,
    required this.calcType,
    required this.unitPrice,
    this.lastMeterReading,
  });

  final String id;
  final String name;
  final ChargeCalcType calcType;

  /// Minor units per meter unit, per person or per period.
  final int unitPrice;

  /// Latest meter reading, used as the "old" reading of the next bill.
  final double? lastMeterReading;

  factory ChargeTemplate.fromMap(Map<String, Object?> map) {
    return ChargeTemplate(
      id: map['id']! as String,
      name: map['name']! as String,
      calcType: ChargeCalcType.fromDb(map['calc_type']! as String),
      unitPrice: (map['unit_price'] as int?) ?? 0,
      lastMeterReading: (map['last_meter_reading'] as num?)?.toDouble(),
    );
  }

  ChargeInput toInput() => ChargeInput(
        name: name,
        calcType: calcType,
        unitPrice: unitPrice,
        meterReading: lastMeterReading,
      );
}

/// An extra charge being created or edited in a form.
class ChargeInput {
  const ChargeInput({
    required this.name,
    required this.calcType,
    required this.unitPrice,
    this.meterReading,
  });

  final String name;
  final ChargeCalcType calcType;
  final int unitPrice;

  /// Starting meter reading, only for [ChargeCalcType.meter].
  final double? meterReading;
}

class Contract {
  const Contract({
    required this.id,
    required this.itemId,
    required this.contactId,
    required this.startDate,
    this.endDate,
    required this.rentAmount,
    required this.currency,
    required this.cycle,
    required this.nextDueDate,
    required this.anchorDay,
    required this.occupants,
    required this.depositAmount,
    required this.depositStatus,
    required this.status,
    required this.noticeDays,
    this.noticeDate,
    this.moveOutDate,
    this.note,
  });

  final String id;
  final String itemId;
  final String contactId;
  final DateTime startDate;
  final DateTime? endDate;

  /// Rent per period in minor units.
  final int rentAmount;
  final String currency;
  final BillingCycle cycle;
  final DateTime nextDueDate;

  /// Day of month monthly bills fall on (from the move-in date).
  final int anchorDay;
  final int occupants;
  final int depositAmount;
  final DepositStatus depositStatus;
  final ContractStatus status;
  final int noticeDays;
  final DateTime? noticeDate;
  final DateTime? moveOutDate;
  final String? note;

  factory Contract.fromMap(Map<String, Object?> map) {
    return Contract(
      id: map['id']! as String,
      itemId: map['item_id']! as String,
      contactId: map['contact_id']! as String,
      startDate: _date(map['start_date'])!,
      endDate: _date(map['end_date']),
      rentAmount: map['rent_amount']! as int,
      currency: map['currency']! as String,
      cycle: BillingCycle.fromDb(map['cycle']! as String),
      nextDueDate: _date(map['next_due_date'])!,
      anchorDay: (map['anchor_day'] as int?) ?? 1,
      occupants: (map['occupants'] as int?) ?? 1,
      depositAmount: (map['deposit_amount'] as int?) ?? 0,
      depositStatus: DepositStatus.fromDb(map['deposit_status']! as String),
      status: ContractStatus.fromDb(map['status']! as String),
      noticeDays: (map['notice_days'] as int?) ?? 14,
      noticeDate: _date(map['notice_date']),
      moveOutDate: _date(map['move_out_date']),
      note: map['note'] as String?,
    );
  }

  /// Reads a `yyyy-MM-dd` column into a local date.
  static DateTime? _date(Object? value) {
    if (value is! String || value.length < 10) return null;
    return DateTime.tryParse(value.substring(0, 10));
  }
}

/// A contract with its tenant and extra charges, for detail screens.
class ContractDetail {
  const ContractDetail({
    required this.contract,
    required this.contact,
    required this.charges,
  });

  final Contract contract;
  final Contact contact;
  final List<ChargeTemplate> charges;
}

/// A saved set of rent-out settings that fills the form for a new tenant.
class RentalTemplate {
  const RentalTemplate({
    required this.id,
    required this.bookId,
    required this.name,
    this.rentAmount,
    required this.cycle,
    required this.occupants,
    required this.depositMonths,
    required this.isDefault,
    required this.charges,
  });

  final String id;
  final String bookId;

  /// Empty for the template made automatically from older default charges;
  /// the app shows a localized name instead.
  final String name;

  /// Null means "use the room's own default price".
  final int? rentAmount;
  final BillingCycle cycle;
  final int occupants;
  final int depositMonths;

  /// Applied automatically when a rent-out form opens.
  final bool isDefault;
  final List<ChargeInput> charges;

  factory RentalTemplate.fromMap(
    Map<String, Object?> map,
    List<ChargeInput> charges,
  ) {
    return RentalTemplate(
      id: map['id']! as String,
      bookId: map['book_id']! as String,
      name: (map['name'] as String?) ?? '',
      rentAmount: map['rent_amount'] as int?,
      cycle: BillingCycle.fromDb(map['cycle']! as String),
      occupants: (map['occupants'] as int?) ?? 1,
      depositMonths: (map['deposit_months'] as int?) ?? 1,
      isDefault: map['is_default'] == 1,
      charges: charges,
    );
  }
}

/// Values of a template being created or edited.
class RentalTemplateInput {
  const RentalTemplateInput({
    required this.name,
    this.rentAmount,
    required this.cycle,
    required this.occupants,
    required this.depositMonths,
    required this.isDefault,
    required this.charges,
  });

  final String name;
  final int? rentAmount;
  final BillingCycle cycle;
  final int occupants;
  final int depositMonths;
  final bool isDefault;
  final List<ChargeInput> charges;
}

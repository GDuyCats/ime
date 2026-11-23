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
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final BookTemplate template;
  final String currency;
  final String? note;
  final int createdAt;
  final int updatedAt;

  factory Book.fromMap(Map<String, Object?> map) {
    return Book(
      id: map['id']! as String,
      name: map['name']! as String,
      template: BookTemplate.fromDb(map['template']! as String),
      currency: map['currency']! as String,
      note: map['note'] as String?,
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

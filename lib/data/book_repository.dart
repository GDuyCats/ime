import '../utils/ids.dart';
import 'app_database.dart';
import 'models.dart';

class BookRepository {
  BookRepository([AppDatabase? database])
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<BookSummary>> listBooks() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT b.*,
        (SELECT COUNT(*) FROM items i
          WHERE i.book_id = b.id AND i.deleted_at IS NULL) AS item_count
      FROM books b
      WHERE b.deleted_at IS NULL
      ORDER BY b.created_at ASC
    ''');
    return rows
        .map((row) => BookSummary(
              book: Book.fromMap(row),
              itemCount: (row['item_count'] as int?) ?? 0,
            ))
        .toList();
  }

  Future<Book?> getBook(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      'books',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Book.fromMap(rows.first);
  }

  /// Creates a book and its starting categories in one transaction.
  Future<Book> createBook({
    required String name,
    required BookTemplate template,
    required String currency,
    String? note,
    required List<CategorySeed> categories,
  }) async {
    final db = await _database.database;
    final now = nowMillis();
    final book = Book(
      id: newId(),
      name: name,
      template: template,
      currency: currency,
      note: note,
      createdAt: now,
      updatedAt: now,
    );

    await db.transaction((txn) async {
      await txn.insert('books', book.toMap());
      for (var i = 0; i < categories.length; i++) {
        final seed = categories[i];
        await txn.insert('categories', {
          'id': newId(),
          'book_id': book.id,
          'name': seed.name,
          'direction': seed.direction.name,
          'sort_order': i,
          'created_at': now,
          'updated_at': now,
        });
      }
    });
    return book;
  }

  /// Template and currency are fixed after creation, so only these change.
  Future<void> updateBook(
    String id, {
    required String name,
    String? note,
  }) async {
    final db = await _database.database;
    await db.update(
      'books',
      {'name': name, 'note': note, 'updated_at': nowMillis()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Saves the rental defaults of a book and replaces its default extra
  /// charges with [charges], in one transaction.
  Future<void> saveRentalSettings(
    String bookId, {
    required RentTiming rentTiming,
    required int depositMonths,
    required int noticeDays,
    required List<ChargeInput> charges,
  }) async {
    final db = await _database.database;
    final now = nowMillis();
    await db.transaction((txn) async {
      await txn.update(
        'books',
        {
          'rent_timing': rentTiming.name,
          'deposit_months': depositMonths,
          'notice_days': noticeDays,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [bookId],
      );
      await txn.update(
        'charge_templates',
        {'deleted_at': now, 'updated_at': now},
        where: 'book_id = ? AND contract_id IS NULL AND deleted_at IS NULL',
        whereArgs: [bookId],
      );
      for (var i = 0; i < charges.length; i++) {
        final charge = charges[i];
        await txn.insert('charge_templates', {
          'id': newId(),
          'book_id': bookId,
          'name': charge.name,
          'calc_type': charge.calcType.dbValue,
          'unit_price': charge.unitPrice,
          'sort_order': i,
          'created_at': now,
          'updated_at': now,
        });
      }
    });
  }

  /// Default extra charges of a book, copied into new contracts.
  Future<List<ChargeTemplate>> listDefaultCharges(String bookId) async {
    final db = await _database.database;
    final rows = await db.query(
      'charge_templates',
      where: 'book_id = ? AND contract_id IS NULL AND deleted_at IS NULL',
      whereArgs: [bookId],
      orderBy: 'sort_order ASC',
    );
    return rows.map(ChargeTemplate.fromMap).toList();
  }

  /// Soft-deletes the book together with its items and categories.
  Future<void> deleteBook(String id) async {
    final db = await _database.database;
    final now = nowMillis();
    final removed = {'deleted_at': now, 'updated_at': now};
    await db.transaction((txn) async {
      await txn.update('books', removed, where: 'id = ?', whereArgs: [id]);
      await txn.update('items', removed,
          where: 'book_id = ? AND deleted_at IS NULL', whereArgs: [id]);
      await txn.update('categories', removed,
          where: 'book_id = ? AND deleted_at IS NULL', whereArgs: [id]);
    });
  }
}

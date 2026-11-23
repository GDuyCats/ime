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

  /// Saves the settings shared by every contract of a rental book.
  /// Prices and extra charges live in rental templates.
  Future<void> saveRentalSettings(
    String bookId, {
    required RentTiming rentTiming,
    required int noticeDays,
  }) async {
    final db = await _database.database;
    await db.update(
      'books',
      {
        'rent_timing': rentTiming.name,
        'notice_days': noticeDays,
        'updated_at': nowMillis(),
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
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

import '../utils/ids.dart';
import 'app_database.dart';
import 'models.dart';

class ItemRepository {
  ItemRepository([AppDatabase? database])
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Item>> listItems(String bookId) async {
    final db = await _database.database;
    final rows = await db.query(
      'items',
      where: 'book_id = ? AND deleted_at IS NULL',
      whereArgs: [bookId],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Item.fromMap).toList();
  }

  Future<Item> createItem({
    required String bookId,
    required String name,
    required ItemKind kind,
    double? areaM2,
    int? defaultPrice,
    String? note,
  }) async {
    final db = await _database.database;
    final now = nowMillis();
    final item = Item(
      id: newId(),
      bookId: bookId,
      name: name,
      kind: kind,
      areaM2: areaM2,
      defaultPrice: defaultPrice,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('items', item.toMap());
    return item;
  }

  Future<void> updateItem(
    String id, {
    required String name,
    required ItemKind kind,
    double? areaM2,
    int? defaultPrice,
    String? note,
  }) async {
    final db = await _database.database;
    await db.update(
      'items',
      {
        'name': name,
        'kind': kind.name,
        'area_m2': areaM2,
        'default_price': defaultPrice,
        'note': note,
        'updated_at': nowMillis(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await _database.database;
    final now = nowMillis();
    await db.update(
      'items',
      {'deleted_at': now, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

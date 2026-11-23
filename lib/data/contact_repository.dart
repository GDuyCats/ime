import '../utils/ids.dart';
import 'app_database.dart';
import 'models.dart';

class ContactRepository {
  ContactRepository([AppDatabase? database])
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Contact>> listContacts() async {
    final db = await _database.database;
    final rows = await db.query(
      'contacts',
      where: 'deleted_at IS NULL',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Contact.fromMap).toList();
  }

  /// Every contact with the places they currently rent.
  Future<List<ContactSummary>> listSummaries() async {
    final db = await _database.database;
    final contacts = await listContacts();
    final rentalRows = await db.rawQuery('''
      SELECT c.contact_id, i.name AS item_name, b.name AS book_name
      FROM contracts c
      JOIN items i ON i.id = c.item_id
      JOIN books b ON b.id = i.book_id
      WHERE c.deleted_at IS NULL AND c.status = 'active'
        AND i.deleted_at IS NULL AND b.deleted_at IS NULL
      ORDER BY b.name, i.name
    ''');
    final rentals = <String, List<String>>{};
    for (final row in rentalRows) {
      rentals
          .putIfAbsent(row['contact_id']! as String, () => [])
          .add('${row['item_name']} · ${row['book_name']}');
    }
    return [
      for (final contact in contacts)
        ContactSummary(
          contact: contact,
          rentals: rentals[contact.id] ?? const [],
        ),
    ];
  }

  Future<Contact> createContact({
    required String name,
    String? phone,
    String? idNumber,
    String? note,
  }) async {
    final db = await _database.database;
    final now = nowMillis();
    final contact = Contact(
      id: newId(),
      name: name,
      phone: phone,
      idNumber: idNumber,
      note: note,
    );
    await db.insert('contacts', {
      'id': contact.id,
      'name': name,
      'phone': phone,
      'id_number': idNumber,
      'note': note,
      'created_at': now,
      'updated_at': now,
    });
    return contact;
  }

  Future<void> updateContact(
    String id, {
    required String name,
    String? phone,
    String? idNumber,
    String? note,
  }) async {
    final db = await _database.database;
    await db.update(
      'contacts',
      {
        'name': name,
        'phone': phone,
        'id_number': idNumber,
        'note': note,
        'updated_at': nowMillis(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Whether the contact still rents something; such contacts can't be
  /// deleted until the contract ends.
  Future<bool> hasActiveContract(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      'contracts',
      columns: ['id'],
      where: "contact_id = ? AND status = 'active' AND deleted_at IS NULL",
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> deleteContact(String id) async {
    final db = await _database.database;
    final now = nowMillis();
    await db.update(
      'contacts',
      {'deleted_at': now, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

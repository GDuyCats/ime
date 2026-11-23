import 'package:sqflite/sqflite.dart';

import '../utils/billing.dart';
import '../utils/dates.dart';
import '../utils/ids.dart';
import 'app_database.dart';
import 'models.dart';

/// Who rents an item: either someone already saved, or a new person to
/// save together with the contract.
class TenantInput {
  const TenantInput.existing(String this.contactId)
      : name = null,
        phone = null;

  const TenantInput.newContact({required String this.name, this.phone})
      : contactId = null;

  final String? contactId;
  final String? name;
  final String? phone;
}

class ContractRepository {
  ContractRepository([AppDatabase? database])
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// The running contract of an item, or null when the item is free.
  Future<ContractDetail?> activeForItem(String itemId) async {
    final db = await _database.database;
    final rows = await db.query(
      'contracts',
      where: "item_id = ? AND status = 'active' AND deleted_at IS NULL",
      whereArgs: [itemId],
      orderBy: 'start_date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final contract = Contract.fromMap(rows.first);

    final contactRows = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [contract.contactId],
      limit: 1,
    );
    if (contactRows.isEmpty) return null;

    return ContractDetail(
      contract: contract,
      contact: Contact.fromMap(contactRows.first),
      charges: await _charges(db, contract.id),
    );
  }

  /// Tenant name of each rented item in a book, keyed by item id.
  Future<Map<String, String>> tenantNamesForBook(String bookId) async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT c.item_id, p.name
      FROM contracts c
      JOIN items i ON i.id = c.item_id
      JOIN contacts p ON p.id = c.contact_id
      WHERE i.book_id = ? AND c.status = 'active' AND c.deleted_at IS NULL
    ''', [bookId]);
    return {
      for (final row in rows) row['item_id']! as String: row['name']! as String,
    };
  }

  /// Saves a new contract, its extra charges and, when needed, the new
  /// tenant, all in one transaction.
  Future<void> createContract({
    required Book book,
    required Item item,
    required TenantInput tenant,
    required int rentAmount,
    required BillingCycle cycle,
    required DateTime startDate,
    required int occupants,
    required int depositAmount,
    String? note,
    required List<ChargeInput> charges,
  }) async {
    final db = await _database.database;
    final now = nowMillis();
    final start = dateOnly(startDate);

    await db.transaction((txn) async {
      var contactId = tenant.contactId;
      if (contactId == null) {
        contactId = newId();
        await txn.insert('contacts', {
          'id': contactId,
          'name': tenant.name,
          'phone': tenant.phone,
          'created_at': now,
          'updated_at': now,
        });
      }

      final contractId = newId();
      await txn.insert('contracts', {
        'id': contractId,
        'item_id': item.id,
        'contact_id': contactId,
        'start_date': isoDate(start),
        'rent_amount': rentAmount,
        'currency': book.currency,
        'cycle': cycle.name,
        'next_due_date': isoDate(firstDueDate(start, cycle, book.rentTiming)),
        'anchor_day': start.day,
        'occupants': occupants,
        'deposit_amount': depositAmount,
        'deposit_status':
            depositAmount > 0 ? DepositStatus.held.name : DepositStatus.none.name,
        'status': ContractStatus.active.name,
        'notice_days': book.noticeDays,
        'note': note,
        'created_at': now,
        'updated_at': now,
      });
      await _insertCharges(txn, contractId, charges, now);
    });
  }

  /// Changes the terms of a running contract. The start date and billing
  /// cycle stay fixed because past and future bill dates depend on them.
  Future<void> updateContract(
    String contractId, {
    required int rentAmount,
    required int occupants,
    required int depositAmount,
    String? note,
    required List<ChargeInput> charges,
  }) async {
    final db = await _database.database;
    final now = nowMillis();
    await db.transaction((txn) async {
      await txn.update(
        'contracts',
        {
          'rent_amount': rentAmount,
          'occupants': occupants,
          'deposit_amount': depositAmount,
          'note': note,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [contractId],
      );
      await txn.update(
        'charge_templates',
        {'deleted_at': now, 'updated_at': now},
        where: 'contract_id = ? AND deleted_at IS NULL',
        whereArgs: [contractId],
      );
      await _insertCharges(txn, contractId, charges, now);
    });
  }

  Future<List<ChargeTemplate>> _charges(
    DatabaseExecutor db,
    String contractId,
  ) async {
    final rows = await db.query(
      'charge_templates',
      where: 'contract_id = ? AND deleted_at IS NULL',
      whereArgs: [contractId],
      orderBy: 'sort_order ASC',
    );
    return rows.map(ChargeTemplate.fromMap).toList();
  }

  Future<void> _insertCharges(
    DatabaseExecutor txn,
    String contractId,
    List<ChargeInput> charges,
    int now,
  ) async {
    for (var i = 0; i < charges.length; i++) {
      final charge = charges[i];
      await txn.insert('charge_templates', {
        'id': newId(),
        'contract_id': contractId,
        'name': charge.name,
        'calc_type': charge.calcType.dbValue,
        'unit_price': charge.unitPrice,
        'last_meter_reading':
            charge.calcType == ChargeCalcType.meter ? charge.meterReading : null,
        'sort_order': i,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}

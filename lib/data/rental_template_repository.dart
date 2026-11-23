import 'package:sqflite/sqflite.dart';

import '../utils/ids.dart';
import 'app_database.dart';
import 'models.dart';

class RentalTemplateRepository {
  RentalTemplateRepository([AppDatabase? database])
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Templates of a book, the default one first.
  Future<List<RentalTemplate>> listTemplates(String bookId) async {
    final db = await _database.database;
    final rows = await db.query(
      'rental_templates',
      where: 'book_id = ? AND deleted_at IS NULL',
      whereArgs: [bookId],
      orderBy: 'is_default DESC, sort_order ASC, created_at ASC',
    );
    final templates = <RentalTemplate>[];
    for (final row in rows) {
      final chargeRows = await db.query(
        'charge_templates',
        where: 'rental_template_id = ? AND deleted_at IS NULL',
        whereArgs: [row['id']],
        orderBy: 'sort_order ASC',
      );
      templates.add(RentalTemplate.fromMap(row, [
        for (final charge in chargeRows) ChargeTemplate.fromMap(charge).toInput(),
      ]));
    }
    return templates;
  }

  /// Creates a template when [id] is null, otherwise replaces it.
  /// Only one template per book can be the default.
  Future<void> saveTemplate(
    String bookId,
    RentalTemplateInput input, {
    String? id,
  }) async {
    final db = await _database.database;
    final now = nowMillis();
    await db.transaction((txn) async {
      if (input.isDefault) {
        await txn.update(
          'rental_templates',
          {'is_default': 0, 'updated_at': now},
          where: 'book_id = ? AND is_default = 1',
          whereArgs: [bookId],
        );
      }
      final values = {
        'name': input.name,
        'rent_amount': input.rentAmount,
        'cycle': input.cycle.name,
        'occupants': input.occupants,
        'deposit_months': input.depositMonths,
        'is_default': input.isDefault ? 1 : 0,
        'updated_at': now,
      };

      final templateId = id ?? newId();
      if (id == null) {
        await txn.insert('rental_templates', {
          ...values,
          'id': templateId,
          'book_id': bookId,
          'created_at': now,
        });
      } else {
        await txn.update(
          'rental_templates',
          values,
          where: 'id = ?',
          whereArgs: [id],
        );
        await txn.update(
          'charge_templates',
          {'deleted_at': now, 'updated_at': now},
          where: 'rental_template_id = ? AND deleted_at IS NULL',
          whereArgs: [id],
        );
      }
      await _insertCharges(txn, templateId, input.charges, now);
    });
  }

  Future<void> deleteTemplate(String id) async {
    final db = await _database.database;
    final now = nowMillis();
    await db.update(
      'rental_templates',
      {'deleted_at': now, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _insertCharges(
    DatabaseExecutor txn,
    String templateId,
    List<ChargeInput> charges,
    int now,
  ) async {
    for (var i = 0; i < charges.length; i++) {
      final charge = charges[i];
      await txn.insert('charge_templates', {
        'id': newId(),
        'rental_template_id': templateId,
        'name': charge.name,
        'calc_type': charge.calcType.dbValue,
        'unit_price': charge.unitPrice,
        'sort_order': i,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}

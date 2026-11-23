import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;

import '../utils/ids.dart';
import 'schema.dart';

/// Opens and owns the single local SQLite database of the app.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _fileName = 'ime.db';
  static const int _version = 3;

  Future<Database>? _opening;

  /// The opened database. The first call opens it; later calls reuse it.
  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    final path = p.join(directory.path, _fileName);

    // Desktop platforms have no built-in SQLite plugin, so they use the FFI
    // implementation. Android and iOS use the regular sqflite plugin.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      return databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: _version,
          onConfigure: _onConfigure,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    }
    return openDatabase(
      path,
      version: _version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// A new install builds version 1, then applies every migration, so it
  /// ends up exactly like an upgraded install.
  static Future<void> _onCreate(Database db, int version) async {
    await _run(db, schemaV1);
    await _onUpgrade(db, 1, version);
  }

  /// Applies each migration newer than [oldVersion], in order.
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) await _run(db, migrationV2);
    if (oldVersion < 3) {
      await _run(db, migrationV3);
      await _moveBookChargesIntoTemplates(db);
    }
  }

  /// Turns each book's old default charges into a default rental template,
  /// so nothing typed before version 3 is lost. The template gets an empty
  /// name; the app shows it as "Default template" in the user's language.
  static Future<void> _moveBookChargesIntoTemplates(Database db) async {
    final books = await db.rawQuery('''
      SELECT DISTINCT b.id, b.deposit_months
      FROM books b
      JOIN charge_templates c ON c.book_id = b.id
      WHERE c.contract_id IS NULL AND c.deleted_at IS NULL
        AND b.deleted_at IS NULL
    ''');
    final now = nowMillis();
    for (final book in books) {
      final templateId = newId();
      await db.insert('rental_templates', {
        'id': templateId,
        'book_id': book['id'],
        'name': '',
        'deposit_months': (book['deposit_months'] as int?) ?? 1,
        'is_default': 1,
        'created_at': now,
        'updated_at': now,
      });
      await db.update(
        'charge_templates',
        {'rental_template_id': templateId, 'book_id': null, 'updated_at': now},
        where: 'book_id = ? AND contract_id IS NULL AND deleted_at IS NULL',
        whereArgs: [book['id']],
      );
    }
  }

  static Future<void> _run(Database db, List<String> statements) async {
    final batch = db.batch();
    for (final statement in statements) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }
}

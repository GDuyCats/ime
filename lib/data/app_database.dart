import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;

import 'schema.dart';

/// Opens and owns the single local SQLite database of the app.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _fileName = 'ime.db';
  static const int _version = 1;

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
        ),
      );
    }
    return openDatabase(
      path,
      version: _version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    for (final statement in schemaV1) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }
}

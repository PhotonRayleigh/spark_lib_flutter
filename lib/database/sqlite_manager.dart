import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spark_lib/filesystem/file_paths.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;

final _SqliteManager _sqliteManager = _SqliteManager();

class SqliteManager {
  static _SqliteManager getInstance() => _sqliteManager;
}

class _SqliteManager {
  // late Future initialized;
  // Completer initCompleter = Completer();

  _SqliteManager() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // initialized = initCompleter.future;
  }

  Future<Database> openDB(String path) async {
    Directory dir = Directory(systemPaths.applicationStorage);
    print(dir);
    return await openDatabase(p.join(dir.path, 'currencyData.db'));
    // initCompleter.complete();
  }

  Future<void> closeDB(Database db) async {
    db.close();
  }

  Future<bool> checkTableExists(Database db, String name) async {
    // await initialized;
    // var db = this.db!;

    var tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");
    if (tables.length == 0) return false;

    for (var row in tables) {
      if (row["name"] == name) return true;
    }

    return false;
  }
}

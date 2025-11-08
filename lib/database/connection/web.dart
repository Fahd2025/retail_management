import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

/// Opens a connection to the database for web platforms using WASM
QueryExecutor connect() {
  return LazyDatabase(() async {
    // Load the sqlite3 WASM binary
    final fs = await IndexedDbFileSystem.open(dbName: 'retail_management_db');
    final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));

    // Create the database
    final db = sqlite3.open(
      'retail_management.db',
      fileSystem: fs,
    );

    return WasmDatabase(
      sqlite3: sqlite3,
      databaseFile: db.path!,
      fileSystem: fs,
    );
  });
}


import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens a connection to the database for web platforms using WASM
QueryExecutor connect() {
  return LazyDatabase(() async {
    final db = await WasmDatabase.open(
      databaseName: 'retail_management.db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    if (db.missingFeatures.isNotEmpty) {
      // Log missing features for debugging
      print('Using database with missing features: ${db.missingFeatures}');
    }

    return db.resolvedExecutor;
  });
}


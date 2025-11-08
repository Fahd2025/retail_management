import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens a connection to the database for web platforms using WASM
QueryExecutor connect() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'retail_management_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      // Handle missing features - fallback to simple implementation
      print('Missing features: ${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  });
}

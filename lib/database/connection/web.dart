import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Opens a connection to the database for web platforms using IndexedDB
QueryExecutor connect() {
  return WebDatabase.withStorage(
    DriftWebStorage.indexedDb('retail_management_db', inWebWorker: false)
  );
}


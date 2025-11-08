import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Opens a connection to the database for web platforms
QueryExecutor connect() {
  return WebDatabase.withStorage(
    DriftWebStorage.indexedDbIfSupported('retail_management_db'),
  );
}

import 'package:drift/drift.dart';

/// Fallback for unsupported platforms
QueryExecutor connect() {
  throw UnsupportedError(
    'No suitable database implementation was found on this platform.',
  );
}

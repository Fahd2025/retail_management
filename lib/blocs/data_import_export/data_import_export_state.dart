import 'package:equatable/equatable.dart';

abstract class DataImportExportState extends Equatable {
  const DataImportExportState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DataImportExportInitial extends DataImportExportState {
  const DataImportExportInitial();
}

/// State when data is being exported
class DataExporting extends DataImportExportState {
  final double progress;

  const DataExporting({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

/// State when data export is successful
class DataExported extends DataImportExportState {
  final String filePath;
  final String message;

  const DataExported({
    required this.filePath,
    required this.message,
  });

  @override
  List<Object?> get props => [filePath, message];
}

/// State when data is being imported
class DataImporting extends DataImportExportState {
  final double progress;

  const DataImporting({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

/// State when data import is successful
class DataImported extends DataImportExportState {
  final String message;
  final int itemsImported;

  const DataImported({
    required this.message,
    required this.itemsImported,
  });

  @override
  List<Object?> get props => [message, itemsImported];
}

/// State when there's an error during import/export
class DataImportExportError extends DataImportExportState {
  final String message;
  final String? errorDetails;

  const DataImportExportError({
    required this.message,
    this.errorDetails,
  });

  @override
  List<Object?> get props => [message, errorDetails];
}

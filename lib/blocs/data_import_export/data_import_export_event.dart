import 'package:equatable/equatable.dart';

/// Enum for data types that can be imported/exported
enum DataType {
  products,
  categories,
  customers,
  sales,
  users,
  settings,
  all,
}

/// Enum for export file formats
enum ExportFormat {
  json,
  csv,
}

abstract class DataImportExportEvent extends Equatable {
  const DataImportExportEvent();

  @override
  List<Object?> get props => [];
}

/// Event to trigger data export
class ExportDataRequested extends DataImportExportEvent {
  final List<DataType> dataTypes;
  final ExportFormat format;

  const ExportDataRequested({
    required this.dataTypes,
    required this.format,
  });

  @override
  List<Object?> get props => [dataTypes, format];
}

/// Event to trigger data import
class ImportDataRequested extends DataImportExportEvent {
  final String filePath;
  final List<DataType> dataTypes;

  const ImportDataRequested({
    required this.filePath,
    required this.dataTypes,
  });

  @override
  List<Object?> get props => [filePath, dataTypes];
}

/// Event to reset the state
class ResetDataImportExportState extends DataImportExportEvent {
  const ResetDataImportExportState();
}

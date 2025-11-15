import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/data_import_export_service.dart';
import 'data_import_export_event.dart';
import 'data_import_export_state.dart';

/// BLoC for handling data import and export operations
class DataImportExportBloc
    extends Bloc<DataImportExportEvent, DataImportExportState> {
  final DataImportExportService _service;

  DataImportExportBloc({
    required DataImportExportService service,
  })  : _service = service,
        super(const DataImportExportInitial()) {
    on<ExportDataRequested>(_onExportDataRequested);
    on<ImportDataRequested>(_onImportDataRequested);
    on<ResetDataImportExportState>(_onResetState);
  }

  /// Handle export data request
  Future<void> _onExportDataRequested(
    ExportDataRequested event,
    Emitter<DataImportExportState> emit,
  ) async {
    emit(const DataExporting(progress: 0.0));

    try {
      final result = await _service.exportData(
        dataTypes: event.dataTypes,
        format: event.format,
        onProgress: (progress) {
          emit(DataExporting(progress: progress));
        },
      );

      if (result.success) {
        emit(DataExported(
          filePath: result.filePath!,
          message: result.message,
        ));
      } else {
        emit(DataImportExportError(
          message: result.message,
          errorDetails: result.errorDetails,
        ));
      }
    } catch (e) {
      emit(DataImportExportError(
        message: 'Export failed',
        errorDetails: e.toString(),
      ));
    }
  }

  /// Handle import data request
  Future<void> _onImportDataRequested(
    ImportDataRequested event,
    Emitter<DataImportExportState> emit,
  ) async {
    emit(const DataImporting(progress: 0.0));

    try {
      final result = await _service.importData(
        filePath: event.filePath,
        dataTypes: event.dataTypes,
        onProgress: (progress) {
          emit(DataImporting(progress: progress));
        },
      );

      if (result.success) {
        emit(DataImported(
          message: result.message,
          itemsImported: result.itemsImported ?? 0,
        ));
      } else {
        emit(DataImportExportError(
          message: result.message,
          errorDetails: result.errorDetails,
        ));
      }
    } catch (e) {
      emit(DataImportExportError(
        message: 'Import failed',
        errorDetails: e.toString(),
      ));
    }
  }

  /// Reset state to initial
  void _onResetState(
    ResetDataImportExportState event,
    Emitter<DataImportExportState> emit,
  ) {
    emit(const DataImportExportInitial());
  }
}

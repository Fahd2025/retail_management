import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../blocs/data_import_export/data_import_export_event.dart';
import '../services/data_import_export_service.dart';
import 'package:retail_management/l10n/app_localizations.dart';

/// Dialog to show detected data types from import file
/// and allow user to confirm or modify selection
class DataTypeDetectionDialog extends StatefulWidget {
  final DataTypeDetectionResult detectionResult;
  final VoidCallback onCancel;
  final Function(List<DataType>) onConfirm;

  const DataTypeDetectionDialog({
    super.key,
    required this.detectionResult,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<DataTypeDetectionDialog> createState() =>
      _DataTypeDetectionDialogState();
}

class _DataTypeDetectionDialogState extends State<DataTypeDetectionDialog> {
  late Set<DataType> _selectedTypes;

  @override
  void initState() {
    super.initState();
    // Pre-select all detected types
    _selectedTypes = Set.from(widget.detectionResult.detectedTypes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500.w,
          maxHeight: 600.h,
        ),
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: colorScheme.primary,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10n.detectedDataTypes,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.detectedDataTypesDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            // Warning banner if app configuration is detected
            if (widget.detectionResult.hasAppConfig) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: colorScheme.secondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.onSecondaryContainer,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        l10n.appConfigNotAppliedNote,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 24.h),

            // Detected data types list
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: _buildDataTypeItems(context),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(l10n.cancel),
                ),
                SizedBox(width: 12.w),
                FilledButton.icon(
                  onPressed: _selectedTypes.isEmpty
                      ? null
                      : () => widget.onConfirm(_selectedTypes.toList()),
                  icon: const Icon(Icons.file_download),
                  label: Text(l10n.importData),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDataTypeItems(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return widget.detectionResult.detectedTypes.map((dataType) {
      final isSelected = _selectedTypes.contains(dataType);
      final itemCount = widget.detectionResult.itemCounts[dataType] ?? 0;

      return CheckboxListTile(
        value: isSelected,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _selectedTypes.add(dataType);
            } else {
              _selectedTypes.remove(dataType);
            }
          });
        },
        title: Row(
          children: [
            Icon(
              _getDataTypeIcon(dataType),
              size: 20.sp,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                _getDataTypeLabel(dataType, l10n),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(left: 32.w, top: 4.h),
          child: Text(
            l10n.itemsCount(itemCount),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        activeColor: colorScheme.primary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      );
    }).toList();
  }

  IconData _getDataTypeIcon(DataType type) {
    switch (type) {
      case DataType.products:
        return Icons.inventory_2;
      case DataType.categories:
        return Icons.category;
      case DataType.customers:
        return Icons.people;
      case DataType.sales:
        return Icons.receipt_long;
      case DataType.users:
        return Icons.admin_panel_settings;
      case DataType.settings:
        return Icons.settings;
      case DataType.all:
        return Icons.select_all;
    }
  }

  String _getDataTypeLabel(DataType type, AppLocalizations l10n) {
    switch (type) {
      case DataType.products:
        return l10n.products;
      case DataType.categories:
        return l10n.categories;
      case DataType.customers:
        return l10n.customers;
      case DataType.sales:
        return l10n.sales;
      case DataType.users:
        return l10n.users;
      case DataType.settings:
        return l10n.settings;
      case DataType.all:
        return l10n.allData;
    }
  }
}

/// Show data type detection dialog
Future<List<DataType>?> showDataTypeDetectionDialog({
  required BuildContext context,
  required DataTypeDetectionResult detectionResult,
}) async {
  return showDialog<List<DataType>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DataTypeDetectionDialog(
      detectionResult: detectionResult,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: (selectedTypes) => Navigator.of(context).pop(selectedTypes),
    ),
  );
}

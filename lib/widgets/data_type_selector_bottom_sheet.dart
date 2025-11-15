import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../blocs/data_import_export/data_import_export_event.dart';
import 'package:retail_management/l10n/app_localizations.dart';

/// Modal Bottom Sheet for selecting data types to import/export
class DataTypeSelectorBottomSheet extends StatefulWidget {
  final bool allowMultipleSelection;
  final Function(List<DataType>, ExportFormat?) onConfirm;
  final bool isExport; // true for export, false for import

  const DataTypeSelectorBottomSheet({
    super.key,
    this.allowMultipleSelection = true,
    required this.onConfirm,
    this.isExport = true,
  });

  @override
  State<DataTypeSelectorBottomSheet> createState() =>
      _DataTypeSelectorBottomSheetState();
}

class _DataTypeSelectorBottomSheetState
    extends State<DataTypeSelectorBottomSheet> {
  final Set<DataType> _selectedDataTypes = {};
  ExportFormat _selectedFormat = ExportFormat.json;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          SizedBox(height: 16.h),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Icon(
                  widget.isExport ? Icons.upload : Icons.download,
                  color: colorScheme.primary,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  widget.isExport
                      ? l10n.selectDataToExport
                      : l10n.selectDataToImport,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              widget.allowMultipleSelection
                  ? l10n.selectMultipleDataTypes
                  : l10n.selectSingleDataType,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Data type list
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDataTypeItem(
                    context,
                    DataType.all,
                    l10n.allData,
                    l10n.allDataDescription,
                    Icons.dataset,
                  ),
                  Divider(height: 1.h, indent: 72.w),
                  _buildDataTypeItem(
                    context,
                    DataType.products,
                    l10n.products,
                    l10n.productsDataDescription,
                    Icons.inventory_2,
                  ),
                  Divider(height: 1.h, indent: 72.w),
                  _buildDataTypeItem(
                    context,
                    DataType.categories,
                    l10n.categories,
                    l10n.categoriesDataDescription,
                    Icons.category,
                  ),
                  Divider(height: 1.h, indent: 72.w),
                  _buildDataTypeItem(
                    context,
                    DataType.customers,
                    l10n.customers,
                    l10n.customersDataDescription,
                    Icons.people,
                  ),
                  Divider(height: 1.h, indent: 72.w),
                  _buildDataTypeItem(
                    context,
                    DataType.sales,
                    l10n.sales,
                    l10n.salesDataDescription,
                    Icons.receipt_long,
                  ),
                  Divider(height: 1.h, indent: 72.w),
                  _buildDataTypeItem(
                    context,
                    DataType.users,
                    l10n.users,
                    l10n.usersDataDescription,
                    Icons.person,
                  ),
                  Divider(height: 1.h, indent: 72.w),
                  _buildDataTypeItem(
                    context,
                    DataType.settings,
                    l10n.settings,
                    l10n.settingsDataDescription,
                    Icons.settings,
                  ),
                ],
              ),
            ),
          ),

          // Format selector (only for export)
          if (widget.isExport) ...[
            SizedBox(height: 16.h),
            Divider(height: 1.h),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.exportFormat,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormatOption(
                          context,
                          ExportFormat.json,
                          'JSON',
                          Icons.code,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildFormatOption(
                          context,
                          ExportFormat.csv,
                          'CSV',
                          Icons.table_chart,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 24.h),

          // Action buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedDataTypes.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context);
                            widget.onConfirm(
                              _selectedDataTypes.toList(),
                              widget.isExport ? _selectedFormat : null,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(l10n.confirm),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDataTypeItem(
    BuildContext context,
    DataType type,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedDataTypes.contains(type);
    final isAllSelected = _selectedDataTypes.contains(DataType.all);

    // If "All" is selected and this is not "All", disable the item
    final isDisabled = isAllSelected && type != DataType.all;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                setState(() {
                  if (type == DataType.all) {
                    // If "All" is selected, clear other selections
                    _selectedDataTypes.clear();
                    if (!isSelected) {
                      _selectedDataTypes.add(DataType.all);
                    }
                  } else {
                    // If any other type is selected, remove "All"
                    _selectedDataTypes.remove(DataType.all);
                    if (isSelected) {
                      _selectedDataTypes.remove(type);
                    } else {
                      if (!widget.allowMultipleSelection) {
                        _selectedDataTypes.clear();
                      }
                      _selectedDataTypes.add(type);
                    }
                  }
                });
              },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withOpacity(0.2)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? colorScheme.primary : Colors.grey[600],
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isDisabled ? Colors.grey[400] : null,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.allowMultipleSelection)
                Checkbox(
                  value: isSelected,
                  onChanged: isDisabled
                      ? null
                      : (value) {
                          setState(() {
                            if (type == DataType.all) {
                              _selectedDataTypes.clear();
                              if (value == true) {
                                _selectedDataTypes.add(DataType.all);
                              }
                            } else {
                              _selectedDataTypes.remove(DataType.all);
                              if (value == true) {
                                _selectedDataTypes.add(type);
                              } else {
                                _selectedDataTypes.remove(type);
                              }
                            }
                          });
                        },
                )
              else
                Radio<DataType>(
                  value: type,
                  groupValue:
                      _selectedDataTypes.isEmpty ? null : _selectedDataTypes.first,
                  onChanged: isDisabled
                      ? null
                      : (value) {
                          setState(() {
                            _selectedDataTypes.clear();
                            if (value != null) {
                              _selectedDataTypes.add(value);
                            }
                          });
                        },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatOption(
    BuildContext context,
    ExportFormat format,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : Colors.grey[600],
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show the data type selector bottom sheet
Future<void> showDataTypeSelectorBottomSheet({
  required BuildContext context,
  required bool isExport,
  required Function(List<DataType>, ExportFormat?) onConfirm,
  bool allowMultipleSelection = true,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DataTypeSelectorBottomSheet(
      isExport: isExport,
      onConfirm: onConfirm,
      allowMultipleSelection: allowMultipleSelection,
    ),
  );
}

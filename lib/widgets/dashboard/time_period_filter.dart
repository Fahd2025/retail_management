import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../../models/dashboard_statistics.dart';

/// Widget for time period filter dropdown with custom date picker
class TimePeriodFilter extends StatelessWidget {
  final TimePeriod selectedPeriod;
  final DateRange dateRange;
  final Function(TimePeriod, DateRange?) onPeriodChanged;

  const TimePeriodFilter({
    super.key,
    required this.selectedPeriod,
    required this.dateRange,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: theme.colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  l10n.timePeriod,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                DropdownButton<TimePeriod>(
                  value: selectedPeriod,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  borderRadius: BorderRadius.circular(8.r),
                  items: TimePeriod.values.map((TimePeriod period) {
                    return DropdownMenuItem<TimePeriod>(
                      value: period,
                      child: Row(
                        children: [
                          Icon(
                            _getPeriodIcon(period),
                            size: 18.sp,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _getLocalizedPeriodName(period, l10n),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (TimePeriod? newPeriod) {
                    if (newPeriod != null) {
                      if (newPeriod == TimePeriod.custom) {
                        _showCustomDatePicker(context);
                      } else {
                        onPeriodChanged(newPeriod, null);
                      }
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      dateRange.format(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selectedPeriod == TimePeriod.custom)
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 16.sp,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => _showCustomDatePicker(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 32.w,
                        minHeight: 32.h,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPeriodIcon(TimePeriod period) {
    switch (period) {
      case TimePeriod.last7Days:
        return Icons.view_week;
      case TimePeriod.lastMonth:
        return Icons.calendar_month;
      case TimePeriod.lastYear:
        return Icons.calendar_today;
      case TimePeriod.custom:
        return Icons.date_range;
    }
  }

  String _getLocalizedPeriodName(TimePeriod period, AppLocalizations l10n) {
    switch (period) {
      case TimePeriod.last7Days:
        return l10n.last7Days;
      case TimePeriod.lastMonth:
        return l10n.monthly;
      case TimePeriod.lastYear:
        return l10n.yearly;
      case TimePeriod.custom:
        return l10n.customPeriod;
    }
  }

  void _showCustomDatePicker(BuildContext context) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    DateTime? startDate = dateRange.start;
    DateTime? endDate = dateRange.end;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(l10n.custom),
                ],
              ),
              content: SizedBox(
                width: 400.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectStartAndEndDates,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Start Date
                    Text(
                      l10n.from,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              0,
                              0,
                              0,
                            );
                            // If end date is before start date, adjust it
                            if (endDate != null &&
                                endDate!.isBefore(startDate!)) {
                              endDate = startDate;
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18.sp,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              startDate != null
                                  ? '${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year}'
                                  : l10n.selectStartDate,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // End Date
                    Text(
                      l10n.to,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: startDate ?? DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            endDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              23,
                              59,
                              59,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18.sp,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              endDate != null
                                  ? '${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year}'
                                  : l10n.selectEndDate,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (startDate != null && endDate != null) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16.sp,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                l10n.durationDays(
                                    endDate!.difference(startDate!).inDays + 1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: startDate != null && endDate != null
                      ? () {
                          Navigator.of(context).pop();
                          onPeriodChanged(
                            TimePeriod.custom,
                            DateRange(start: startDate!, end: endDate!),
                          );
                        }
                      : null,
                  child: Text(l10n.apply),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

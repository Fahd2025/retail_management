import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// A reusable card widget to display a single metric/statistic
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isCurrency;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.subtitle,
    this.onTap,
    this.isLoading = false,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? effectiveColor.withOpacity(0.1);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: effectiveBackgroundColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            icon,
                            color: effectiveColor,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      value,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  /// Factory constructor for currency values
  factory MetricCard.currency({
    required String title,
    required double amount,
    required IconData icon,
    Color? color,
    Color? backgroundColor,
    String? subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final formatter = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);
    return MetricCard(
      title: title,
      value: formatter.format(amount),
      icon: icon,
      color: color,
      backgroundColor: backgroundColor,
      subtitle: subtitle,
      onTap: onTap,
      isLoading: isLoading,
      isCurrency: true,
    );
  }

  /// Factory constructor for count values
  factory MetricCard.count({
    required String title,
    required int count,
    required IconData icon,
    Color? color,
    Color? backgroundColor,
    String? subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final formatter = NumberFormat('#,###');
    return MetricCard(
      title: title,
      value: formatter.format(count),
      icon: icon,
      color: color,
      backgroundColor: backgroundColor,
      subtitle: subtitle,
      onTap: onTap,
      isLoading: isLoading,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui.dart';
import '../../utils/currency_helper.dart';

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

    return LiquidCard(
      elevation: 3,
      blur: 18,
      opacity: 0.15,
      borderRadius: 12,
      padding: EdgeInsets.all(16.w),
      onTap: onTap,
      child: isLoading
          ? Center(
              child: LiquidLoader(
                size: 40,
                color: effectiveColor,
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
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    LiquidContainer(
                      width: 50.w,
                      height: 50.w,
                      borderRadius: 10,
                      blur: 10,
                      opacity: 0.15,
                      color: effectiveColor,
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
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
    final formatter = CurrencyHelper.getCurrencyFormatterSync();
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

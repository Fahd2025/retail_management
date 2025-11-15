import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:glassmorphism/glassmorphism.dart';
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

    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: null,
        borderRadius: 12,
        blur: 18,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.15),
            theme.colorScheme.surface.withValues(alpha: 0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.5),
            theme.colorScheme.surface.withValues(alpha: 0.2),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: effectiveColor,
                      strokeWidth: 3,
                    ),
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
                        GlassmorphicContainer(
                          width: 50.w,
                          height: 50.w,
                          borderRadius: 10,
                          blur: 10,
                          alignment: Alignment.center,
                          border: 2,
                          linearGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              effectiveColor.withValues(alpha: 0.15),
                              effectiveColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              effectiveColor.withValues(alpha: 0.5),
                              effectiveColor.withValues(alpha: 0.2),
                            ],
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
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
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

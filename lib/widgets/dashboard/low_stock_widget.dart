import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../../models/dashboard_statistics.dart';

/// Widget to display low stock notifications
class LowStockWidget extends StatelessWidget {
  final List<LowStockProduct> products;
  final bool isLoading;

  const LowStockWidget({
    super.key,
    required this.products,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final numberFormatter = NumberFormat('#,##0.##');

    return LayoutBuilder(
      builder: (context, constraints) {
        return GlassmorphicContainer(
          width: constraints.maxWidth,
          height: 550,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        l10n.lowStockNotifications,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (products.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '${products.length}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),
                if (isLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.h),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                  )
                else if (products.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48.sp,
                            color: Colors.green.withValues(alpha: 0.6),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            l10n.allProductsWellStocked,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: products.length > 10 ? 10 : products.length,
                      separatorBuilder: (context, index) => Divider(height: 1.h),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final stockPercentage = product.reorderLevel != null
                            ? (product.currentQuantity / product.reorderLevel!) * 100
                            : 0.0;
                        final isCritical = product.currentQuantity <= 5;

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          leading: GlassmorphicContainer(
                            width: 50.w,
                            height: 50.w,
                            borderRadius: 8,
                            blur: 10,
                            alignment: Alignment.center,
                            border: 2,
                            linearGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                (isCritical ? Colors.red : Colors.orange).withValues(alpha: 0.1),
                                (isCritical ? Colors.red : Colors.orange).withValues(alpha: 0.05),
                              ],
                            ),
                            borderGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                (isCritical ? Colors.red : Colors.orange).withValues(alpha: 0.5),
                                (isCritical ? Colors.red : Colors.orange).withValues(alpha: 0.2),
                              ],
                            ),
                            child: product.productImage != null &&
                                    product.productImage!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.asset(
                                      product.productImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.inventory_2,
                                          color:
                                              isCritical ? Colors.red : Colors.orange,
                                          size: 24.sp,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.inventory_2,
                                    color: isCritical ? Colors.red : Colors.orange,
                                    size: 24.sp,
                                  ),
                          ),
                          title: Text(
                            product.productName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    isCritical
                                        ? Icons.error_outline
                                        : Icons.warning_amber_outlined,
                                    size: 14.sp,
                                    color: isCritical ? Colors.red : Colors.orange,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    isCritical
                                        ? l10n.critical
                                        : l10n.lowStockNotifications,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isCritical ? Colors.red : Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2.r),
                                child: LinearProgressIndicator(
                                  value: stockPercentage.clamp(0.0, 100.0) / 100,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCritical ? Colors.red : Colors.orange,
                                  ),
                                  minHeight: 4.h,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                numberFormatter.format(product.currentQuantity),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCritical ? Colors.red : Colors.orange,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                l10n.unitsLeft,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                if (products.length > 10) ...[
                  SizedBox(height: 8.h),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Navigate to products screen with low stock filter
                      },
                      child: Text(l10n.viewAllLowStockItems(products.length)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

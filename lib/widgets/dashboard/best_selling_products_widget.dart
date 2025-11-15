import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../../models/dashboard_statistics.dart';
import '../../utils/currency_helper.dart';

/// Widget to display best-selling products
class BestSellingProductsWidget extends StatelessWidget {
  final List<BestSellingProduct> products;
  final bool isLoading;

  const BestSellingProductsWidget({
    super.key,
    required this.products,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyFormatter = CurrencyHelper.getCurrencyFormatterSync();
    final numberFormatter = NumberFormat('#,##0.##');

    return LiquidCard(
      elevation: 3,
      blur: 18,
      opacity: 0.15,
      borderRadius: 12,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: theme.colorScheme.primary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.bestSellingProducts,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: LiquidLoader(
                  size: 60,
                  color: theme.colorScheme.primary,
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
                      Icons.inbox_outlined,
                      size: 48.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.noSalesDataAvailable,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) => Divider(height: 1.h),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 8.h,
                  ),
                  leading: LiquidContainer(
                    width: 50.w,
                    height: 50.w,
                    borderRadius: 8,
                    blur: 10,
                    opacity: 0.1,
                    child: product.productImage != null &&
                            product.productImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.asset(
                              product.productImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.shopping_bag,
                                  color: theme.colorScheme.primary,
                                  size: 24.sp,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.shopping_bag,
                            color: theme.colorScheme.primary,
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
                      Text(
                        '${l10n.quantitySold}: ${numberFormatter.format(product.totalQuantitySold)} • ${l10n.salesCount(product.transactionCount)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormatter.format(product.totalRevenue),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      LiquidContainer(
                        borderRadius: 4,
                        blur: 8,
                        opacity: 0.1,
                        color: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

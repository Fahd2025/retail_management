import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui_design.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../../models/sale.dart';
import '../../utils/currency_helper.dart';

/// Widget to display latest sales invoices
class LatestInvoicesWidget extends StatelessWidget {
  final List<Sale> invoices;
  final bool isLoading;
  final Function(Sale)? onInvoiceTap;

  const LatestInvoicesWidget({
    super.key,
    required this.invoices,
    this.isLoading = false,
    this.onInvoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyFormatter = CurrencyHelper.getCurrencyFormatterSync();
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

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
                Icons.receipt_long,
                color: theme.colorScheme.primary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.latestSalesInvoices,
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
          else if (invoices.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 48.sp,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.noInvoicesAvailable,
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoices.length > 10 ? 10 : invoices.length,
              separatorBuilder: (context, index) => Divider(height: 1.h),
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 8.h,
                  ),
                  onTap: onInvoiceTap != null
                      ? () => onInvoiceTap!(invoice)
                      : null,
                  leading: LiquidContainer(
                    width: 50.w,
                    height: 50.w,
                    borderRadius: 8,
                    blur: 10,
                    opacity: 0.1,
                    color: _getStatusColor(invoice.status, theme),
                    child: Icon(
                      _getStatusIcon(invoice.status),
                      color: _getStatusColor(invoice.status, theme),
                      size: 24.sp,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          invoice.invoiceNumber,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildStatusBadge(invoice.status, theme, context),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(
                        dateFormatter.format(invoice.saleDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      if (invoice.customerId != null) ...[
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 12.sp,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${l10n.customerId}: ${invoice.customerId}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormatter.format(invoice.totalAmount),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildPaymentMethodBadge(
                          invoice.paymentMethod, theme, context),
                    ],
                  ),
                );
              },
            ),
          if (invoices.length > 10) ...[
            SizedBox(height: 8.h),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to sales screen
                },
                child: Text(l10n.viewAllInvoices(invoices.length)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
      SaleStatus status, ThemeData theme, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String text;
    Color color;

    switch (status) {
      case SaleStatus.completed:
        text = l10n.complete;
        color = Colors.green;
        break;
      case SaleStatus.returned:
        text = l10n.return_sale;
        color = Colors.orange;
        break;
      case SaleStatus.cancelled:
        text = l10n.cancelled;
        color = Colors.red;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodBadge(
      PaymentMethod method, ThemeData theme, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    IconData icon;
    String text;

    switch (method) {
      case PaymentMethod.cash:
        icon = Icons.payments_outlined;
        text = l10n.cashPayment;
        break;
      case PaymentMethod.card:
        icon = Icons.credit_card;
        text = l10n.cardPayment;
        break;
      case PaymentMethod.transfer:
        icon = Icons.account_balance;
        text = l10n.transfer;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12.sp,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SaleStatus status, ThemeData theme) {
    switch (status) {
      case SaleStatus.completed:
        return Colors.green;
      case SaleStatus.returned:
        return Colors.orange;
      case SaleStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(SaleStatus status) {
    switch (status) {
      case SaleStatus.completed:
        return Icons.check_circle_outline;
      case SaleStatus.returned:
        return Icons.restart_alt;
      case SaleStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:retail_management/generated/l10n/app_localizations.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../blocs/dashboard/dashboard_event.dart';
import '../blocs/dashboard/dashboard_state.dart';
import '../models/dashboard_statistics.dart';
import '../models/sale.dart';
import '../database/drift_database.dart' hide Sale;
import '../widgets/dashboard/metric_card.dart';
import '../widgets/dashboard/best_selling_products_widget.dart';
import '../widgets/dashboard/low_stock_widget.dart';
import '../widgets/dashboard/latest_invoices_widget.dart';
import '../widgets/dashboard/sales_chart_widget.dart';
import '../widgets/dashboard/time_period_filter.dart';
import '../widgets/invoice_preview_dialog.dart';

/// Analytics Dashboard Screen - Main dashboard with statistics and charts
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial dashboard data with default time period (last 7 days)
    context.read<DashboardBloc>().add(
          const LoadDashboardStatisticsEvent(
            timePeriod: TimePeriod.last7Days,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardInitial || state is DashboardLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.loadingDashboardData,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is DashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: theme.colorScheme.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Error loading dashboard',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.errorLoadingDashboard,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  FilledButton.icon(
                    onPressed: () {
                      context
                          .read<DashboardBloc>()
                          .add(const RefreshDashboardEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

        if (state is DashboardLoaded) {
          return _buildDashboardContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardLoaded state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statistics = state.statistics;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const RefreshDashboardEvent());
        // Wait for the refresh to complete
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Period Filter
            TimePeriodFilter(
              selectedPeriod: state.timePeriod,
              dateRange: state.dateRange,
              onPeriodChanged: (period, customRange) {
                context.read<DashboardBloc>().add(
                      ChangeTimePeriodEvent(
                        timePeriod: period,
                        customDateRange: customRange,
                      ),
                    );
              },
            ),
            SizedBox(height: 16.h),

            // Key Metrics Cards
            Text(
              l10n.keyMetrics,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.5,
              children: [
                MetricCard.currency(
                  title: l10n.totalSales,
                  amount: statistics.totalSales,
                  icon: Icons.attach_money,
                  color: Colors.green,
                  subtitle: '${statistics.completedInvoices} ${l10n.completedInvoices}',
                ),
                MetricCard.currency(
                  title: l10n.totalVat,
                  amount: statistics.totalVat,
                  icon: Icons.receipt,
                  color: Colors.orange,
                  subtitle: l10n.vatCollected,
                ),
                MetricCard.count(
                  title: l10n.totalProducts,
                  count: statistics.totalProducts,
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                  subtitle: '${statistics.activeProducts} ${l10n.activeProducts}',
                ),
                MetricCard.count(
                  title: l10n.totalCustomers,
                  count: statistics.totalCustomers,
                  icon: Icons.people,
                  color: Colors.purple,
                  subtitle: '${statistics.activeCustomers} ${l10n.activeCustomers}',
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Sales Trend Chart
            SalesChartWidget(
              dailySalesData: statistics.dailySalesData,
            ),
            SizedBox(height: 16.h),

            // Category Sales Chart
            if (statistics.categorySalesData.isNotEmpty) ...[
              CategorySalesChartWidget(
                categorySalesData: statistics.categorySalesData,
              ),
              SizedBox(height: 16.h),
            ],

            // Two Column Layout for Best Selling and Low Stock
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  // Wide screen: Two columns
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BestSellingProductsWidget(
                          products: statistics.bestSellingProducts,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: LowStockWidget(
                          products: statistics.lowStockProducts,
                        ),
                      ),
                    ],
                  );
                } else {
                  // Narrow screen: Stacked
                  return Column(
                    children: [
                      BestSellingProductsWidget(
                        products: statistics.bestSellingProducts,
                      ),
                      SizedBox(height: 16.h),
                      LowStockWidget(
                        products: statistics.lowStockProducts,
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 16.h),

            // Latest Invoices
            LatestInvoicesWidget(
              invoices: state.latestInvoices,
              onInvoiceTap: (invoice) {
                // Navigate to invoice details or print
                _showInvoiceDetails(context, invoice);
              },
            ),
            SizedBox(height: 16.h),

            // Footer with statistics summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.invoiceStatistics,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          l10n.total,
                          statistics.totalInvoices.toString(),
                          Colors.blue,
                          Icons.receipt_long,
                        ),
                        _buildStatItem(
                          context,
                          l10n.completed,
                          statistics.completedInvoices.toString(),
                          Colors.green,
                          Icons.check_circle,
                        ),
                        _buildStatItem(
                          context,
                          l10n.returned,
                          statistics.returnedInvoices.toString(),
                          Colors.orange,
                          Icons.undo,
                        ),
                        _buildStatItem(
                          context,
                          l10n.cancelled,
                          statistics.cancelledInvoices.toString(),
                          Colors.red,
                          Icons.cancel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _showInvoiceDetails(BuildContext context, Sale sale) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get company info and customer from database
      final db = AppDatabase();
      final companyInfo = await db.getCompanyInfo();

      // Get customer if sale has a customerId
      final customer = sale.customerId != null
          ? await db.getCustomer(sale.customerId!)
          : null;

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show invoice preview dialog
      if (context.mounted && companyInfo != null) {
        await InvoicePreviewDialog.show(
          context: context,
          sale: sale,
          companyInfo: companyInfo,
          customer: customer,
        );
      } else if (context.mounted) {
        // Show error if company info not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.companyInfoNotFound),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoadingInvoice(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

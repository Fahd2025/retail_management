import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../blocs/sale/sale_bloc.dart';
import '../blocs/sale/sale_event.dart';
import '../blocs/sale/sale_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../models/sale.dart';
import '../widgets/invoice_preview_dialog.dart';
import '../database/drift_database.dart' hide Sale;
import '../utils/currency_helper.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    context.read<SaleBloc>().add(const LoadSalesEvent());
  }

  Future<void> _reprintInvoice(Sale sale) async {
    try {
      final db = AppDatabase();
      final companyInfo = await db.getCompanyInfo();

      if (companyInfo == null) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.companyInfoNotFound)),
          );
        }
        return;
      }

      final customer = sale.customerId != null
          ? await db.getCustomer(sale.customerId!)
          : null;

      // Get current print format configuration from AppConfig
      final appConfigState = context.read<AppConfigBloc>().state;
      final printConfig = appConfigState.printFormatConfig;

      // Show print preview bottom sheet with format selection
      await InvoicePreviewBottomSheet.show(
        context: context,
        sale: sale,
        companyInfo: companyInfo,
        customer: customer,
        initialConfig: printConfig,
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.printError(e.toString()))),
        );
      }
    }
  }

  Widget _buildSaleCard(
      Sale sale, DateFormat dateFormat, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);
    final vatEnabled = context.watch<AppConfigBloc>().state.vatEnabled;
    final statusColor = sale.status == SaleStatus.completed
        ? Colors.green
        : sale.status == SaleStatus.returned
            ? Colors.orange
            : theme.colorScheme.error;

    final statusText = sale.status == SaleStatus.completed
        ? l10n.complete
        : sale.status == SaleStatus.returned
            ? l10n.return_sale
            : sale.status.toString().split('.').last.toUpperCase();

    return LiquidCard(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      blur: 18,
      opacity: 0.15,
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        leading: LiquidContainer(
          width: 48,
          height: 48,
          borderRadius: 24,
          blur: 12,
          opacity: 0.2,
          backgroundColor: statusColor,
          child: Icon(Icons.receipt, color: statusColor, size: 24),
        ),
        title: Text(
          l10n.invoiceLabel(sale.invoiceNumber),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: liquidTheme.textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dateLabel(dateFormat.format(sale.saleDate)),
              style: TextStyle(
                fontSize: 13,
                color: liquidTheme.textColor.withValues(alpha: 0.7),
              ),
            ),
            Text(
              l10n.totalLabel(
                  CurrencyHelper.formatCurrencySync(sale.totalAmount)),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.statusLabelText(statusText),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LiquidButton(
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.small,
              onTap: () => _reprintInvoice(sale),
              child: Icon(
                Icons.print,
                color: theme.colorScheme.primary,
              ),
            ),
            if (sale.status == SaleStatus.completed)
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is Authenticated && authState.isAdmin) {
                    return LiquidButton(
                      type: LiquidButtonType.icon,
                      size: LiquidButtonSize.small,
                      onTap: () => _returnSale(sale),
                      child: const Icon(Icons.undo, color: Colors.orange),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.itemsLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: liquidTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...sale.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} x ${item.quantity}',
                            style: TextStyle(
                              color:
                                  liquidTheme.textColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        Text(
                          CurrencyHelper.formatCurrencySync(item.total),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: liquidTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                Divider(color: liquidTheme.textColor.withValues(alpha: 0.2)),
                if (vatEnabled) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.subtotalLabel,
                        style: TextStyle(color: liquidTheme.textColor),
                      ),
                      Text(
                        CurrencyHelper.formatCurrencySync(sale.subtotal),
                        style: TextStyle(color: liquidTheme.textColor),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.vatLabel,
                        style: TextStyle(color: liquidTheme.textColor),
                      ),
                      Text(
                        CurrencyHelper.formatCurrencySync(sale.vatAmount),
                        style: TextStyle(color: liquidTheme.textColor),
                      ),
                    ],
                  ),
                  Divider(color: liquidTheme.textColor.withValues(alpha: 0.2)),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalLabelColon,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: liquidTheme.textColor,
                      ),
                    ),
                    Text(
                      CurrencyHelper.formatCurrencySync(sale.totalAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (sale.paidAmount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.paidLabel,
                        style: TextStyle(color: liquidTheme.textColor),
                      ),
                      Text(
                        CurrencyHelper.formatCurrencySync(sale.paidAmount),
                        style: TextStyle(color: liquidTheme.textColor),
                      ),
                    ],
                  ),
                  if (sale.changeAmount > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.changeLabel,
                          style: TextStyle(color: liquidTheme.textColor),
                        ),
                        Text(
                          CurrencyHelper.formatCurrencySync(sale.changeAmount),
                          style: TextStyle(color: liquidTheme.textColor),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _returnSale(Sale sale) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => LiquidDialog(
        title: l10n.returnSale,
        content: Text(
          l10n.returnSaleConfirm(sale.invoiceNumber),
          style: TextStyle(color: LiquidTheme.of(context).textColor),
        ),
        actions: [
          LiquidButton(
            onTap: () => Navigator.pop(context, false),
            type: LiquidButtonType.text,
            child: Text(l10n.cancel),
          ),
          LiquidButton(
            onTap: () => Navigator.pop(context, true),
            type: LiquidButtonType.filled,
            backgroundColor: Colors.orange,
            child: Text(
              l10n.returnSale,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;

      if (authState is Authenticated) {
        context.read<SaleBloc>().add(ReturnSaleEvent(
              sale.id,
              authState.user.id,
            ));

        // Wait for operation to complete
        await Future.delayed(const Duration(milliseconds: 200));
        final saleState = context.read<SaleBloc>().state;

        if (mounted && saleState is SaleOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.saleReturnedSuccess)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return LiquidScaffold(
      body: BlocBuilder<SaleBloc, SaleState>(
        builder: (context, state) {
          if (state is SaleLoading) {
            return Center(
              child: LiquidLoader(size: 60),
            );
          }

          List<Sale> sales = [];
          if (state is SaleLoaded) {
            sales = state.sales;
          } else if (state is SaleError) {
            sales = state.sales;
          } else if (state is SaleOperationSuccess) {
            sales = state.sales;
          } else if (state is SaleCompleted) {
            sales = state.sales;
          }

          if (sales.isEmpty) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LiquidContainer(
                    width: 120,
                    height: 120,
                    borderRadius: 60,
                    blur: 15,
                    opacity: 0.2,
                    child: Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: liquidTheme.textColor.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noSalesFound,
                    style: TextStyle(color: liquidTheme.textColor),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              final l10n = AppLocalizations.of(context)!;
              final vatEnabled =
                  context.watch<AppConfigBloc>().state.vatEnabled;

              if (isDesktop) {
                // Desktop: DataTable layout that fills width
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: LiquidCard(
                          elevation: 4,
                          blur: 20,
                          opacity: 0.15,
                          borderRadius: 16,
                          padding: const EdgeInsets.all(16),
                          child: DataTable(
                            columnSpacing: 24,
                            horizontalMargin: 16,
                            headingTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: liquidTheme.textColor,
                            ),
                            dataTextStyle: TextStyle(
                              color:
                                  liquidTheme.textColor.withValues(alpha: 0.9),
                            ),
                            columns: [
                              DataColumn(label: Text(l10n.invoiceLabel(''))),
                              DataColumn(label: Text(l10n.dateLabel(''))),
                              if (vatEnabled)
                                DataColumn(
                                    label: Text('${l10n.vat} ${l10n.amount}')),
                              DataColumn(label: Text(l10n.totalLabel(''))),
                              DataColumn(label: Text(l10n.statusLabelText(''))),
                              DataColumn(label: Text(l10n.itemsLabel)),
                              DataColumn(label: Text(l10n.actions)),
                            ],
                            rows: sales.map((sale) {
                              final statusColor =
                                  sale.status == SaleStatus.completed
                                      ? Colors.green
                                      : sale.status == SaleStatus.returned
                                          ? Colors.orange
                                          : theme.colorScheme.error;

                              final statusText =
                                  sale.status == SaleStatus.completed
                                      ? l10n.complete
                                      : sale.status == SaleStatus.returned
                                          ? l10n.return_sale
                                          : sale.status
                                              .toString()
                                              .split('.')
                                              .last
                                              .toUpperCase();

                              return DataRow(cells: [
                                DataCell(Text(sale.invoiceNumber)),
                                DataCell(
                                    Text(dateFormat.format(sale.saleDate))),
                                if (vatEnabled)
                                  DataCell(Text(
                                      CurrencyHelper.formatCurrencySync(
                                          sale.vatAmount))),
                                DataCell(Text(CurrencyHelper.formatCurrencySync(
                                    sale.totalAmount))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          statusColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(sale.items.length.toString())),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LiquidButton(
                                        type: LiquidButtonType.icon,
                                        size: LiquidButtonSize.small,
                                        onTap: () => _reprintInvoice(sale),
                                        child: Icon(
                                          Icons.print,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (sale.status == SaleStatus.completed)
                                        BlocBuilder<AuthBloc, AuthState>(
                                          builder: (context, authState) {
                                            if (authState is Authenticated &&
                                                authState.isAdmin) {
                                              return LiquidButton(
                                                type: LiquidButtonType.icon,
                                                size: LiquidButtonSize.small,
                                                onTap: () => _returnSale(sale),
                                                child: const Icon(
                                                  Icons.undo,
                                                  size: 20,
                                                  color: Colors.orange,
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                // Mobile: Card with ExpansionTile layout
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    return _buildSaleCard(sales[index], dateFormat, context);
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

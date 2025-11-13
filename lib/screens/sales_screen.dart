import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
    final statusColor = sale.status == SaleStatus.completed
        ? Colors.green
        : sale.status == SaleStatus.returned
            ? Colors.orange
            : Colors.red;

    final statusText = sale.status == SaleStatus.completed
        ? l10n.complete
        : sale.status == SaleStatus.returned
            ? l10n.return_sale
            : sale.status.toString().split('.').last.toUpperCase();

    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(Icons.receipt, color: statusColor),
        ),
        title: Text(
          l10n.invoiceLabel(sale.invoiceNumber),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dateLabel(dateFormat.format(sale.saleDate))),
            Text(l10n.totalLabel(sale.totalAmount.toStringAsFixed(2))),
            Text(
              l10n.statusLabelText(statusText),
              style: TextStyle(color: statusColor),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () => _reprintInvoice(sale),
              tooltip: l10n.reprint,
            ),
            if (sale.status == SaleStatus.completed)
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is Authenticated && authState.isAdmin) {
                    return IconButton(
                      icon: const Icon(Icons.undo, color: Colors.orange),
                      onPressed: () => _returnSale(sale),
                      tooltip: l10n.return_sale,
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                          ),
                        ),
                        Text(
                          'SAR ${item.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.subtotalLabel),
                    Text('SAR ${sale.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.vatLabel),
                    Text('SAR ${sale.vatAmount.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalLabelColon,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'SAR ${sale.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (sale.paidAmount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.paidLabel),
                      Text('SAR ${sale.paidAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                  if (sale.changeAmount > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.changeLabel),
                        Text('SAR ${sale.changeAmount.toStringAsFixed(2)}'),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.returnSale),
        content: Text(AppLocalizations.of(context)!
            .returnSaleConfirm(sale.invoiceNumber)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(AppLocalizations.of(context)!.returnSale),
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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.saleReturnedSuccess)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      body: BlocBuilder<SaleBloc, SaleState>(
        builder: (context, state) {
          if (state is SaleLoading) {
            return const Center(child: CircularProgressIndicator());
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
                  Icon(Icons.receipt_long,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(l10n.noSalesFound),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              final l10n = AppLocalizations.of(context)!;

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
                      child: DataTable(
                        columnSpacing: 24,
                        horizontalMargin: 16,
                        columns: [
                          DataColumn(label: Text(l10n.invoiceLabel(''))),
                          DataColumn(label: Text(l10n.dateLabel(''))),
                          DataColumn(label: Text('${l10n.vat} Amount')),
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
                                      : Colors.red;

                          final statusText = sale.status == SaleStatus.completed
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
                            DataCell(Text(dateFormat.format(sale.saleDate))),
                            DataCell(Text(
                                'SAR ${sale.vatAmount.toStringAsFixed(2)}')),
                            DataCell(Text(
                                'SAR ${sale.totalAmount.toStringAsFixed(2)}')),
                            DataCell(
                              Chip(
                                label: Text(
                                  statusText,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor:
                                    statusColor.withValues(alpha: 0.2),
                                labelStyle: TextStyle(color: statusColor),
                              ),
                            ),
                            DataCell(Text(sale.items.length.toString())),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.print, size: 20),
                                    onPressed: () => _reprintInvoice(sale),
                                    tooltip: l10n.reprint,
                                  ),
                                  if (sale.status == SaleStatus.completed)
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, authState) {
                                        if (authState is Authenticated &&
                                            authState.isAdmin) {
                                          return IconButton(
                                            icon: const Icon(Icons.undo,
                                                size: 20, color: Colors.orange),
                                            onPressed: () => _returnSale(sale),
                                            tooltip: l10n.return_sale,
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
                );
              } else {
                // Mobile: Card with ExpansionTile layout
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildSaleCard(sales[index], dateFormat, context),
                    );
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../models/sale.dart';
import '../models/company_info.dart';
import '../models/customer.dart';
import '../models/print_format.dart';
import '../services/invoice_service.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_state.dart';

/// Dialog for previewing and printing invoices
///
/// This dialog allows users to:
/// 1. Preview the invoice PDF before printing
/// 2. Select a different print format
/// 3. Print the invoice with the selected format
/// 4. Share or save the PDF
class InvoicePreviewDialog extends StatefulWidget {
  final Sale sale;
  final CompanyInfo companyInfo;
  final Customer? customer;
  final PrintFormatConfig? initialConfig;

  const InvoicePreviewDialog({
    super.key,
    required this.sale,
    required this.companyInfo,
    this.customer,
    this.initialConfig,
  });

  @override
  State<InvoicePreviewDialog> createState() => _InvoicePreviewDialogState();

  /// Show the invoice preview dialog
  static Future<void> show({
    required BuildContext context,
    required Sale sale,
    required CompanyInfo companyInfo,
    Customer? customer,
    PrintFormatConfig? initialConfig,
  }) {
    return showDialog(
      context: context,
      builder: (context) => InvoicePreviewDialog(
        sale: sale,
        companyInfo: companyInfo,
        customer: customer,
        initialConfig: initialConfig,
      ),
    );
  }
}

class _InvoicePreviewDialogState extends State<InvoicePreviewDialog> {
  late PrintFormatConfig _selectedConfig;
  final _invoiceService = InvoiceService();

  @override
  void initState() {
    super.initState();
    _selectedConfig = widget.initialConfig ?? PrintFormatConfig.defaultConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.print),
                  const SizedBox(width: 8),
                  Text(
                    'Invoice Preview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Format selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Format:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  ...PrintFormat.all.map((format) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(format.displayName),
                        selected: _selectedConfig.format == format,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedConfig = _selectedConfig.copyWith(
                                format: format,
                              );
                            });
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            // PDF Preview
            Expanded(
              child: BlocBuilder<AppConfigBloc, AppConfigState>(
                builder: (context, configState) {
                  return PdfPreview(
                    build: (format) => _invoiceService.previewInvoice(
                      sale: widget.sale,
                      companyInfo: widget.companyInfo,
                      customer: widget.customer,
                      config: _selectedConfig,
                      vatIncludedInPrice: configState.vatIncludedInPrice,
                      vatEnabled: configState.vatEnabled,
                    ),
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    pdfFileName:
                        'Invoice_${widget.sale.invoiceNumber}_${_selectedConfig.format.id}.pdf',
                    actions: [
                      PdfPreviewAction(
                        icon: const Icon(Icons.print),
                        onPressed: (context, build, pageFormat) async {
                          await _invoiceService.printInvoice(
                            sale: widget.sale,
                            companyInfo: widget.companyInfo,
                            customer: widget.customer,
                            config: _selectedConfig,
                            vatIncludedInPrice: configState.vatIncludedInPrice,
                            vatEnabled: configState.vatEnabled,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for quick invoice preview and print
///
/// A more compact version suitable for mobile devices
class InvoicePreviewBottomSheet extends StatefulWidget {
  final Sale sale;
  final CompanyInfo companyInfo;
  final Customer? customer;
  final PrintFormatConfig? initialConfig;

  const InvoicePreviewBottomSheet({
    super.key,
    required this.sale,
    required this.companyInfo,
    this.customer,
    this.initialConfig,
  });

  @override
  State<InvoicePreviewBottomSheet> createState() =>
      _InvoicePreviewBottomSheetState();

  /// Show the invoice preview bottom sheet
  static Future<void> show({
    required BuildContext context,
    required Sale sale,
    required CompanyInfo companyInfo,
    Customer? customer,
    PrintFormatConfig? initialConfig,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoicePreviewBottomSheet(
        sale: sale,
        companyInfo: companyInfo,
        customer: customer,
        initialConfig: initialConfig,
      ),
    );
  }
}

class _InvoicePreviewBottomSheetState extends State<InvoicePreviewBottomSheet> {
  late PrintFormat _selectedFormat;
  final _invoiceService = InvoiceService();

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.initialConfig?.format ?? PrintFormat.a4;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          children: [
                            const Icon(Icons.print),
                            const SizedBox(width: 8),
                            Text(
                              l10n.printInvoice,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // Format selector
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${l10n.selectFormat}:',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: PrintFormat.all.map((format) {
                                return ChoiceChip(
                                  label: Text(format.displayName),
                                  selected: _selectedFormat == format,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedFormat = format;
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: BlocBuilder<AppConfigBloc, AppConfigState>(
                          builder: (context, configState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final config = PrintFormatConfig(
                                      format: _selectedFormat,
                                    );
                                    await _invoiceService.printInvoice(
                                      sale: widget.sale,
                                      companyInfo: widget.companyInfo,
                                      customer: widget.customer,
                                      config: config,
                                      vatIncludedInPrice: configState.vatIncludedInPrice,
                                      vatEnabled: configState.vatEnabled,
                                    );
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  icon: const Icon(Icons.print),
                                  label: Text(l10n.printNow),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    InvoicePreviewDialog.show(
                                      context: context,
                                      sale: widget.sale,
                                      companyInfo: widget.companyInfo,
                                      customer: widget.customer,
                                      initialConfig: PrintFormatConfig(
                                        format: _selectedFormat,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.preview),
                                  label: Text(l10n.preview),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

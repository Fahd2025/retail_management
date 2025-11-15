import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../models/sale.dart';
import '../models/company_info.dart';
import '../models/customer.dart';
import '../models/print_format.dart';
import '../services/invoice_service.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_state.dart';

/// Dialog for previewing and printing invoices with Glassmorphism UI
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        borderRadius: 20,
        blur: 30,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.2),
            isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.1),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Column(
          children: [
            // Header with glassmorphism effect
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.print,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Invoice Preview',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.onSurface,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surface.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.onSurface.withOpacity(0.1),
                          colorScheme.onSurface.withOpacity(0.3),
                          colorScheme.onSurface.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Format selector with glassmorphism chips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Format:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ...PrintFormat.all.map((format) {
                        final isSelected = _selectedConfig.format == format;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: isSelected
                              ? FilledButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedConfig =
                                          _selectedConfig.copyWith(
                                        format: format,
                                      );
                                    });
                                  },
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    backgroundColor: colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    format.displayName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedConfig =
                                          _selectedConfig.copyWith(
                                        format: format,
                                      );
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    side: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    format.displayName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.onSurface.withOpacity(0.1),
                          colorScheme.onSurface.withOpacity(0.3),
                          colorScheme.onSurface.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
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

/// Bottom sheet for quick invoice preview and print with Glassmorphism UI
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 20,
          blur: 25,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.2),
              isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.1),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
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
                  color: colorScheme.onSurface.withOpacity(0.4),
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
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.onSurface.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.print,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.printInvoice,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: Icon(
                                    Icons.close,
                                    color: colorScheme.onSurface,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        colorScheme.surface.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.onSurface.withOpacity(0.1),
                                    colorScheme.onSurface.withOpacity(0.3),
                                    colorScheme.onSurface.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Format selector
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${l10n.selectFormat}:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: PrintFormat.all.map((format) {
                                final isSelected = _selectedFormat == format;
                                return isSelected
                                    ? FilledButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedFormat = format;
                                          });
                                        },
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          backgroundColor: colorScheme.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          format.displayName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedFormat = format;
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          side: BorderSide(
                                            color: colorScheme.outline,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          format.displayName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.onSurface.withOpacity(0.1),
                              colorScheme.onSurface.withOpacity(0.3),
                              colorScheme.onSurface.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: BlocBuilder<AppConfigBloc, AppConfigState>(
                          builder: (context, configState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FilledButton(
                                  onPressed: () async {
                                    final config = PrintFormatConfig(
                                      format: _selectedFormat,
                                    );
                                    await _invoiceService.printInvoice(
                                      sale: widget.sale,
                                      companyInfo: widget.companyInfo,
                                      customer: widget.customer,
                                      config: config,
                                      vatIncludedInPrice:
                                          configState.vatIncludedInPrice,
                                      vatEnabled: configState.vatEnabled,
                                    );
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    backgroundColor: colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.print,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.printNow,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
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
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    side: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.preview,
                                        color: colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.preview,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui_design.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../models/sale.dart';
import '../models/company_info.dart';
import '../models/customer.dart';
import '../models/print_format.dart';
import '../services/invoice_service.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_state.dart';

/// Dialog for previewing and printing invoices with Liquid Glass UI
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
    final liquidTheme = LiquidTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: LiquidCard(
        elevation: 12,
        blur: 30,
        opacity: 0.2,
        borderRadius: 20,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Header with Liquid Glass effect
              LiquidContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 0,
                blur: 10,
                opacity: 0.15,
                child: Column(
                  children: [
                    Row(
                      children: [
                        LiquidContainer(
                          padding: const EdgeInsets.all(8),
                          borderRadius: 8,
                          blur: 8,
                          opacity: 0.2,
                          child: Icon(
                            Icons.print,
                            color: liquidTheme.textColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Invoice Preview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: liquidTheme.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        LiquidButton(
                          onPressed: () => Navigator.of(context).pop(),
                          type: LiquidButtonType.icon,
                          size: LiquidButtonSize.small,
                          child: Icon(
                            Icons.close,
                            color: liquidTheme.textColor,
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
                            liquidTheme.textColor.withValues(alpha: 0.1),
                            liquidTheme.textColor.withValues(alpha: 0.3),
                            liquidTheme.textColor.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Format selector with Liquid Glass chips
              LiquidContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 0,
                blur: 5,
                opacity: 0.1,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Format:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: liquidTheme.textColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ...PrintFormat.all.map((format) {
                          final isSelected = _selectedConfig.format == format;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: LiquidButton(
                              onPressed: () {
                                setState(() {
                                  _selectedConfig = _selectedConfig.copyWith(
                                    format: format,
                                  );
                                });
                              },
                              type: isSelected
                                  ? LiquidButtonType.filled
                                  : LiquidButtonType.outlined,
                              size: LiquidButtonSize.small,
                              child: Text(
                                format.displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : liquidTheme.textColor,
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
                            liquidTheme.textColor.withValues(alpha: 0.1),
                            liquidTheme.textColor.withValues(alpha: 0.3),
                            liquidTheme.textColor.withValues(alpha: 0.1),
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
      ),
    );
  }
}

/// Bottom sheet for quick invoice preview and print with Liquid Glass UI
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
    final liquidTheme = LiquidTheme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return LiquidCard(
          borderRadius: 20,
          elevation: 8,
          blur: 25,
          opacity: 0.18,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: liquidTheme.textColor.withValues(alpha: 0.4),
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
                      LiquidContainer(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        borderRadius: 0,
                        blur: 5,
                        opacity: 0.1,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                LiquidContainer(
                                  padding: const EdgeInsets.all(8),
                                  borderRadius: 8,
                                  blur: 8,
                                  opacity: 0.2,
                                  child: Icon(
                                    Icons.print,
                                    color: liquidTheme.textColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.printInvoice,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: liquidTheme.textColor,
                                      ),
                                ),
                                const Spacer(),
                                LiquidButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  type: LiquidButtonType.icon,
                                  size: LiquidButtonSize.small,
                                  child: Icon(
                                    Icons.close,
                                    color: liquidTheme.textColor,
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
                                    liquidTheme.textColor
                                        .withValues(alpha: 0.1),
                                    liquidTheme.textColor
                                        .withValues(alpha: 0.3),
                                    liquidTheme.textColor
                                        .withValues(alpha: 0.1),
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
                                color: liquidTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: PrintFormat.all.map((format) {
                                final isSelected = _selectedFormat == format;
                                return LiquidButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedFormat = format;
                                    });
                                  },
                                  type: isSelected
                                      ? LiquidButtonType.filled
                                      : LiquidButtonType.outlined,
                                  size: LiquidButtonSize.small,
                                  child: Text(
                                    format.displayName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.white
                                          : liquidTheme.textColor,
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
                              liquidTheme.textColor.withValues(alpha: 0.1),
                              liquidTheme.textColor.withValues(alpha: 0.3),
                              liquidTheme.textColor.withValues(alpha: 0.1),
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
                                LiquidButton(
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
                                  type: LiquidButtonType.filled,
                                  size: LiquidButtonSize.large,
                                  width: double.infinity,
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
                                LiquidButton(
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
                                  type: LiquidButtonType.outlined,
                                  size: LiquidButtonSize.large,
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.preview,
                                        color: liquidTheme.textColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.preview,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: liquidTheme.textColor,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../models/print_format.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_event.dart';
import '../blocs/app_config/app_config_state.dart';

/// Widget for selecting and configuring print format settings
///
/// This widget displays the available print formats and allows users
/// to select their preferred format along with display options.
class PrintFormatSelector extends StatelessWidget {
  const PrintFormatSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AppConfigBloc, AppConfigState>(
      builder: (context, state) {
        final config = state.printFormatConfig;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Format Selection
            Text(
              l10n.printFormat,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...PrintFormat.all.map((format) {
              return RadioListTile<PrintFormat>(
                title: Text(format.displayName),
                subtitle: Text(
                  format.isThermal
                      ? l10n.thermalReceiptPrinter
                      : l10n.standardPaperFormat,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: format,
                groupValue: config.format,
                onChanged: (value) {
                  if (value != null) {
                    context.read<AppConfigBloc>().add(
                          UpdatePrintFormatEvent(
                            config.copyWith(format: value),
                          ),
                        );
                  }
                },
              );
            }),
            const Divider(height: 32),

            // Display Options
            Text(
              l10n.displayOptions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: Text(l10n.showCompanyLogo),
              subtitle: Text(l10n.displayLogoPlaceholder),
              value: config.showLogo,
              onChanged: (value) {
                context.read<AppConfigBloc>().add(
                      UpdatePrintFormatEvent(
                        config.copyWith(showLogo: value),
                      ),
                    );
              },
            ),

            SwitchListTile(
              title: Text(l10n.showQrCode),
              subtitle: Text(l10n.displayZatcaQrCode),
              value: config.showQrCode,
              onChanged: (value) {
                context.read<AppConfigBloc>().add(
                      UpdatePrintFormatEvent(
                        config.copyWith(showQrCode: value),
                      ),
                    );
              },
            ),

            SwitchListTile(
              title: Text(l10n.showCustomerInformation),
              subtitle: Text(l10n.displayCustomerDetails),
              value: config.showCustomerInfo,
              onChanged: (value) {
                context.read<AppConfigBloc>().add(
                      UpdatePrintFormatEvent(
                        config.copyWith(showCustomerInfo: value),
                      ),
                    );
              },
            ),

            SwitchListTile(
              title: Text(l10n.showNotes),
              subtitle: Text(l10n.displaySaleNotes),
              value: config.showNotes,
              onChanged: (value) {
                context.read<AppConfigBloc>().add(
                      UpdatePrintFormatEvent(
                        config.copyWith(showNotes: value),
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Compact widget for quick format selection (e.g., in dialogs)
class PrintFormatQuickSelector extends StatelessWidget {
  final PrintFormat selectedFormat;
  final ValueChanged<PrintFormat> onFormatChanged;

  const PrintFormatQuickSelector({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.selectFormat,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...PrintFormat.all.map((format) {
          return RadioListTile<PrintFormat>(
            dense: true,
            title: Text(format.displayName),
            subtitle: Text(
              l10n.mmWidth(format.widthMm.toInt().toString()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: format,
            groupValue: selectedFormat,
            onChanged: (value) {
              if (value != null) {
                onFormatChanged(value);
              }
            },
          );
        }),
      ],
    );
  }
}

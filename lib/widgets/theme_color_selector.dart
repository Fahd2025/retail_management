import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../models/theme_color_scheme.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_event.dart';
import '../blocs/app_config/app_config_state.dart';

/// Compact widget for selecting theme color scheme
///
/// Features:
/// - Horizontal scrollable list of color chips
/// - Visual preview of primary color for each scheme
/// - Selected scheme indicator with check mark
/// - Compact design that takes minimal space
/// - Touch-friendly tap targets
class ThemeColorSelector extends StatelessWidget {
  const ThemeColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AppConfigBloc, AppConfigState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.themeColorScheme,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ThemeColorScheme.predefinedSchemes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final scheme = ThemeColorScheme.predefinedSchemes[index];
                  final isSelected = state.colorScheme.id == scheme.id;

                  return _CompactColorChip(
                    scheme: scheme,
                    isSelected: isSelected,
                    onTap: () {
                      context.read<AppConfigBloc>().add(
                            UpdateColorSchemeEvent(scheme),
                          );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Compact color chip for displaying a color scheme option
class _CompactColorChip extends StatelessWidget {
  final ThemeColorScheme scheme;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactColorChip({
    required this.scheme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final primaryColor = isDarkMode ? scheme.darkPrimary : scheme.lightPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.5),
            width: isSelected ? 2.5 : 1,
          ),
          color: theme.cardColor,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Color preview circle
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: _getContrastColor(primaryColor),
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            // Scheme name
            Text(
              scheme.getLocalizedName(locale),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 11,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate contrasting color for check icon
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

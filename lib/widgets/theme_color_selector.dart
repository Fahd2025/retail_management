import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../models/theme_color_scheme.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_event.dart';
import '../blocs/app_config/app_config_state.dart';

/// Widget for selecting theme color scheme
///
/// Features:
/// - Display predefined color schemes in a grid
/// - Visual preview of colors for each scheme
/// - Selected scheme indicator
/// - Custom color picker option (future enhancement)
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
            Text(
              l10n.themeColorScheme,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: ThemeColorScheme.predefinedSchemes.length,
              itemBuilder: (context, index) {
                final scheme = ThemeColorScheme.predefinedSchemes[index];
                final isSelected = state.colorScheme.id == scheme.id;

                return _ColorSchemeCard(
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
          ],
        );
      },
    );
  }
}

/// Card widget for displaying a color scheme option
class _ColorSchemeCard extends StatelessWidget {
  final ThemeColorScheme scheme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSchemeCard({
    required this.scheme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.cardColor,
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Color preview
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Primary color
                Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? scheme.darkPrimary
                        : scheme.lightPrimary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Secondary color
                Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? scheme.darkSecondary
                        : scheme.lightSecondary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Scheme name
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme.getLocalizedName(locale),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.selected,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Reusable settings section widget with consistent styling
class SettingsSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? subtitle;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool isCollapsible;
  final bool initiallyExpanded;

  const SettingsSection({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    required this.children,
    this.padding,
    this.isCollapsible = false,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const Divider(),
        ...children,
      ],
    );

    if (isCollapsible) {
      return Card(
        margin: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: icon != null ? Icon(icon) : null,
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: subtitle != null ? Text(subtitle!) : null,
            initiallyExpanded: initiallyExpanded,
            children: [
              Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: content,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 28),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Responsive grid for settings sections
class SettingsGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const SettingsGrid({
    super.key,
    required this.children,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Mobile: 1 column
        if (width < 600) {
          return Column(
            children: children
                .map((child) => Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: child,
                    ))
                .toList(),
          );
        }

        // Tablet: 1-2 columns based on content
        if (width < 1200) {
          return Column(
            children: children
                .map((child) => Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: child,
                    ))
                .toList(),
          );
        }

        // Desktop: 2-column grid
        return _buildTwoColumnGrid();
      },
    );
  }

  Widget _buildTwoColumnGrid() {
    final leftColumn = <Widget>[];
    final rightColumn = <Widget>[];

    for (int i = 0; i < children.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(children[i]);
      } else {
        rightColumn.add(children[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn
                .map((child) => Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: child,
                    ))
                .toList(),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            children: rightColumn
                .map((child) => Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: child,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Settings item with icon, title, and trailing widget
class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

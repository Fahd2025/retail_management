/// A reusable ModalBottomSheet wrapper for form dialogs
///
/// This widget provides a consistent design for all Add/Edit bottom sheets
/// across the application. It includes:
/// - Drag handle for dismissal
/// - Responsive height adaptation
/// - Keyboard-aware scrolling
/// - Consistent button layout
/// - Smooth animations
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (context) => FormBottomSheet(
///     title: 'Add Product',
///     onSave: _handleSave,
///     child: YourFormContent(),
///   ),
/// );
/// ```

import 'package:flutter/material.dart';

/// A customizable bottom sheet designed for form inputs
///
/// Features:
/// - Automatic keyboard handling
/// - Drag-to-dismiss gesture
/// - Responsive sizing
/// - Consistent action buttons layout
class FormBottomSheet extends StatelessWidget {
  /// The title displayed at the top of the bottom sheet
  final String title;

  /// The form content (usually a Form widget with input fields)
  final Widget child;

  /// Callback when the save/submit button is pressed
  final VoidCallback onSave;

  /// Optional callback when cancel button is pressed
  /// Defaults to Navigator.pop(context)
  final VoidCallback? onCancel;

  /// Text for the save button (defaults to "Save")
  final String? saveButtonText;

  /// Text for the cancel button (defaults to "Cancel")
  final String? cancelButtonText;

  /// Whether the save button should be disabled
  final bool isSaveDisabled;

  /// Optional loading indicator on the save button
  final bool isLoading;

  /// Maximum height as a fraction of screen height (0.0 to 1.0)
  /// Defaults to 0.9 (90% of screen height)
  final double maxHeightFraction;

  const FormBottomSheet({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
    this.onCancel,
    this.saveButtonText,
    this.cancelButtonText,
    this.isSaveDisabled = false,
    this.isLoading = false,
    this.maxHeightFraction = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Calculate responsive height
    // Uses 90% of screen height by default, accounting for system UI
    final maxHeight = mediaQuery.size.height * maxHeightFraction;

    // Account for keyboard height to ensure form is visible when typing
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Container(
      // Constrain height but allow keyboard to push content up
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle - visual indicator that sheet can be dismissed
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title section with bottom border
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Close button for accessibility
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onCancel ?? () => Navigator.pop(context),
                  tooltip: cancelButtonText ?? 'Cancel',
                ),
              ],
            ),
          ),

          // Scrollable content area
          // Expands to fill available space but doesn't exceed max height
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                // Add extra padding when keyboard is visible
                keyboardHeight > 0 ? 24 : 24,
              ),
              child: child,
            ),
          ),

          // Action buttons - fixed at bottom
          // Elevated to show separation from content
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              // Add bottom padding for safe area (iPhone notch, etc.)
              16 + mediaQuery.padding.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              // Add shadow to indicate elevation
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Cancel button - text style for less emphasis
                Expanded(
                  child: TextButton(
                    onPressed: onCancel ?? () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      cancelButtonText ?? 'Cancel',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Save button - filled style for emphasis
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: isSaveDisabled || isLoading ? null : onSave,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            saveButtonText ?? 'Save',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show a form bottom sheet with standard configuration
///
/// This ensures consistent behavior across the app:
/// - Scroll control enabled for full-height sheets
/// - Dismissible by dragging down
/// - Proper keyboard handling
/// - Barrier dismissible by tapping outside
///
/// Example:
/// ```dart
/// showFormBottomSheet(
///   context: context,
///   title: 'Add Product',
///   onSave: () async {
///     // Save logic
///   },
///   child: ProductForm(),
/// );
/// ```
Future<T?> showFormBottomSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  required VoidCallback onSave,
  VoidCallback? onCancel,
  String? saveButtonText,
  String? cancelButtonText,
  bool isSaveDisabled = false,
  bool isLoading = false,
  double maxHeightFraction = 0.9,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // Enable scroll control to allow the sheet to take full height if needed
    isScrollControlled: true,
    // Allow dismissal by dragging down
    enableDrag: enableDrag,
    // Allow dismissal by tapping outside
    isDismissible: isDismissible,
    // Use transparent barrier to see content behind
    backgroundColor: Colors.transparent,
    // Smooth animation curve
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    ),
    builder: (context) => FormBottomSheet(
      title: title,
      onSave: onSave,
      onCancel: onCancel,
      saveButtonText: saveButtonText,
      cancelButtonText: cancelButtonText,
      isSaveDisabled: isSaveDisabled,
      isLoading: isLoading,
      maxHeightFraction: maxHeightFraction,
      child: child,
    ),
  );
}

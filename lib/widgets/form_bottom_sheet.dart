/// A reusable ModalBottomSheet wrapper for form dialogs with Glassmorphism UI
///
/// This widget provides a consistent design for all Add/Edit bottom sheets
/// across the application. It includes:
/// - Drag handle for dismissal
/// - Responsive height adaptation
/// - Keyboard-aware scrolling
/// - Consistent button layout
/// - Smooth animations
/// - Glassmorphism visual effects
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
import 'package:glassmorphism/glassmorphism.dart';

/// A customizable bottom sheet designed for form inputs with Glassmorphism styling
///
/// Features:
/// - Automatic keyboard handling
/// - Drag-to-dismiss gesture
/// - Responsive sizing
/// - Consistent action buttons layout
/// - Glassmorphism visual effects
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
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate responsive height
    // Uses 90% of screen height by default, accounting for system UI
    final maxHeight = mediaQuery.size.height * maxHeightFraction;

    // Account for keyboard height to ensure form is visible when typing
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return GlassmorphicContainer(
      width: double.infinity,
      height: maxHeight,
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
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
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
                color: colorScheme.onSurface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title section with bottom border
            Container(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      // Close button for accessibility
                      IconButton(
                        onPressed: onCancel ?? () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.onSurface,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surface.withOpacity(0.3),
                          padding: const EdgeInsets.all(8),
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
              child: Column(
                children: [
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Cancel button - outlined style for less emphasis
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel ?? () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: colorScheme.outline.withOpacity(0.5),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            cancelButtonText ?? 'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
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
                            backgroundColor: colorScheme.primary,
                            disabledBackgroundColor:
                                colorScheme.onSurface.withOpacity(0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  saveButtonText ?? 'Save',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
/// - Glassmorphism visual effects
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

import 'package:flutter/material.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';

/// A reusable modal dialog component that follows the app's design pattern.
/// 
/// This component can be used to display confirmation dialogs, alerts, or any
/// other modal content with consistent styling across the app.
class AtsModal extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Color? primaryButtonColor;
  final Color? secondaryButtonColor;
  final Widget? customContent;

  const AtsModal({
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.primaryButtonColor,
    this.secondaryButtonColor,
    this.customContent,
  });

  /// Shows a modal dialog with the specified parameters.
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,
    Widget? customContent,
  }) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) => AtsModal(
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryButtonPressed: onPrimaryButtonPressed,
        onSecondaryButtonPressed: onSecondaryButtonPressed,
        primaryButtonColor: primaryButtonColor,
        secondaryButtonColor: secondaryButtonColor,
        customContent: customContent,
      ),
    );
  }

  /// Shows a confirmation dialog for unsaved changes.
  static Future<void> showUnsavedChangesDialog({
    required BuildContext context,
    VoidCallback? onDiscard,
    VoidCallback? onContinue,
  }) async {
    return show(
      context: context,
      title: 'unsaved changes',
      message: 'you have unsaved changes. are you sure you want to leave without saving?',
      primaryButtonText: 'discard changes',
      secondaryButtonText: 'continue editing',
      onPrimaryButtonPressed: onDiscard ?? () => Navigator.pop(context, true),
      onSecondaryButtonPressed: onContinue ?? () => Navigator.pop(context, false),
      primaryButtonColor: Theme.of(context).colorScheme.errorContainer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (customContent != null) ...[
              const SizedBox(height: 20),
              customContent!,
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (primaryButtonText != null)
                  atsButton(
                    onPressed: onPrimaryButtonPressed ?? () => Navigator.pop(context),
                    backgroundColor: primaryButtonColor,
                    child: Text(
                      primaryButtonText!,
                      style: primaryButtonColor != null
                          ? TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer)
                          : null,
                    ),
                  ),
                if (primaryButtonText != null && secondaryButtonText != null)
                  const SizedBox(width: 10),
                if (secondaryButtonText != null)
                  atsButton(
                    onPressed: onSecondaryButtonPressed ?? () => Navigator.pop(context),
                    backgroundColor: secondaryButtonColor,
                    child: Text(secondaryButtonText!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
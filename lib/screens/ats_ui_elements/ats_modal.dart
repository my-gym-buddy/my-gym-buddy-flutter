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
    // Wrap in a try-catch to handle any Navigation errors gracefully
    try {
      return await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        useSafeArea: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        builder: (BuildContext context) => AtsModal(
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
    } catch (e) {
      // Handle any navigation errors here
      print('Error showing modal: $e');
      // Return a completed future to prevent the error from propagating
      return Future.value();
    }
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
      message:
          'you have unsaved changes. are you sure you want to leave without saving?',
      primaryButtonText: 'discard changes',
      secondaryButtonText: 'continue editing',
      onPrimaryButtonPressed: onDiscard ??
          () {
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            });
          },
      onSecondaryButtonPressed: onContinue ??
          () {
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                Navigator.of(context).pop(false);
              }
            });
          },
      primaryButtonColor: Theme.of(context).colorScheme.errorContainer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
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
                    onPressed: onPrimaryButtonPressed ??
                        () {
                          // Use try-catch to handle any potential navigation errors
                          try {
                            Navigator.of(context).pop();
                          } catch (e) {
                            print('Error closing modal: $e');
                          }
                        },
                    backgroundColor: primaryButtonColor,
                    child: Text(
                      primaryButtonText!,
                      style: primaryButtonColor != null
                          ? TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer)
                          : null,
                    ),
                  ),
                if (primaryButtonText != null && secondaryButtonText != null)
                  const SizedBox(width: 10),
                if (secondaryButtonText != null)
                  atsButton(
                    onPressed: onSecondaryButtonPressed ??
                        () {
                          // Use try-catch to handle any potential navigation errors
                          try {
                            Navigator.of(context).pop();
                          } catch (e) {
                            print('Error closing modal: $e');
                          }
                        },
                    backgroundColor: secondaryButtonColor,
                    child: Text(secondaryButtonText!),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

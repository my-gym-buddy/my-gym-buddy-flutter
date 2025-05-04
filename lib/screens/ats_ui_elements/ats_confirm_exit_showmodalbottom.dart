import 'package:flutter/material.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';

Future<bool> atsConfirmExitDialog(
  BuildContext context, {
  String title = 'Discard changes?',
  String description = 'You have unsaved changes. Are you sure you want to leave?',
  String confirmButtonText = 'Discard',
  String cancelButtonText = 'Cancel',
}) async {
  final bool? result = await showModalBottomSheet<bool>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(description),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                atsButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  child: Text(
                    confirmButtonText,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                ),
                const SizedBox(width: 10),
                atsButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    cancelButtonText,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}

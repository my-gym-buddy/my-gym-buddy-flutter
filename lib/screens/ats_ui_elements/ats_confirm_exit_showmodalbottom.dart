import 'package:flutter/material.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';

Future<bool> atsConfirmExitDialog(BuildContext context) async {
  final bool? result = await showModalBottomSheet<bool>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Discard changes?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
                'You have unsaved changes. Are you sure you want to leave?'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                atsButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  child: Text(
                    'Discard',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                ),
                const SizedBox(width: 10),
                atsButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
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

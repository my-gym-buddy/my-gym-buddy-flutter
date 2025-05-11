import 'package:flutter/material.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_checkbox.dart';

/// A class that provides help content for the app
class AppHelpContent {
  // Track completed steps
  static final Map<int, bool> _completedSteps = {};
  
  // Callback for when all steps are completed
  static Function? _onAllStepsCompleted;

  /// Returns true if all steps are completed
  static bool areAllStepsCompleted() {
    return _completedSteps.values.every((isCompleted) => isCompleted == true) &&
        _completedSteps.length >= 4; // Ensure all 4 steps have values
  }
  
  /// Sets a callback to be called when all steps are completed
  static void setOnAllStepsCompletedCallback(Function callback) {
    _onAllStepsCompleted = callback;
  }

  /// Returns a Widget with app usage instructions
  static Widget getHelpContent(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpStep(
            context,
            1,
            'create exercises',
            'Go to all exercises and add your exercises with details. Check this box when completed.',
            setState,
          ),
          _buildHelpStep(
            context,
            2,
            'create workouts',
            'Create workout templates with your exercises. Check this box when completed.',
            setState,
          ),
          _buildHelpStep(
            context,
            3,
            'start a workout',
            'Start a workout from homepage and track your progress. Check this box when completed.',
            setState,
          ),
          _buildHelpStep(
            context,
            4,
            'view statistics',
            'Check your progress in the statistics section. Check this box when completed.',
            setState,
          ),
        ],
      );
    });
  }

  /// Helper to build a consistent step widget with checkbox
  static Widget _buildHelpStep(
    BuildContext context,
    int stepNumber,
    String title,
    String description,
    Function setState,
  ) {
    // Initialize step status if needed
    _completedSteps[stepNumber] ??= false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox instead of number circle
          atsCheckbox(
            checked: _completedSteps[stepNumber] ?? false,
            onChanged: (bool value) {
              _completedSteps[stepNumber] = value;
              setState(() {});
              
              // Call the callback when all steps are completed
              if (areAllStepsCompleted() && _onAllStepsCompleted != null) {
                _onAllStepsCompleted!();
              }
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

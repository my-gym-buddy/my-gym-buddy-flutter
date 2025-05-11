import 'package:flutter/material.dart';

/// A class that provides help content for the app
class AppHelpContent {
  /// Returns a Widget with app usage instructions
  static Widget getHelpContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'how to use my gym buddy',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 15),
        _buildHelpStep(
          context,
          '1',
          'create exercises',
          'Go to all exercises and add your exercises with details',
        ),
        _buildHelpStep(
          context,
          '2',
          'create workouts',
          'Create workout templates with your exercises',
        ),
        _buildHelpStep(
          context,
          '3',
          'start a workout',
          'Start a workout from homepage and track your progress',
        ),
        _buildHelpStep(
          context,
          '4',
          'view statistics',
          'Check your progress in the statistics section',
        ),
      ],
    );
  }

  /// Helper to build a consistent step widget
  static Widget _buildHelpStep(
    BuildContext context,
    String stepNumber,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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

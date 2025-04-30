import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/exercises/widgets/exercise_form.dart';

class AddExerciseScreen extends StatelessWidget {
  final Exercise? exercise;

  const AddExerciseScreen({super.key, this.exercise});

  @override
  Widget build(BuildContext context) {
    return ExerciseForm(
      exercise: exercise,
      onSave: (exercise) async {
        final success = await DatabaseHelper.saveExercise(exercise);
        if (success) {
          if (context.mounted) {
            // The context is mounted, so it's safe to use it
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exercise saved!')),
            );
            Navigator.pop(context);
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save exercise')),
            );
          }
        }
      },
    );
  }
}

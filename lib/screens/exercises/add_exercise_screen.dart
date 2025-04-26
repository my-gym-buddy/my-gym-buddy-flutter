import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_dropdown.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exercise saved!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save exercise')),
          );
        }
      },
    );
  }
}

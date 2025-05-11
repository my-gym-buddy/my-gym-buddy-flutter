import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/exercises/exercise_detail_screen.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool editMode;

  const ExerciseCard(
      {super.key, required this.exercise, required this.editMode});

  Color _getDifficultyColor(String? difficulty) {
    if (difficulty == null) return Colors.grey.shade200;

    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green.shade100;
      case 'intermediate':
        return Colors.orange.shade100;
      case 'expert':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, bottom: 3),
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        title: Text(exercise.name.toLowerCase(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(exercise.description ?? 'no description',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: Theme.of(context).textTheme.bodySmall),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ExerciseDetailScreen(
                    exercise: exercise, editMode: editMode)),
          );
        },
      ),
    );
  }
}

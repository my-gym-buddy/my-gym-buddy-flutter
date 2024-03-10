import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/exercises/single_exercise_screen.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(right: 15.0, left: 15.0, top: 3, bottom: 3),
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        title: Text(exercise.name.toLowerCase(),
            style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(exercise.videoID ?? 'no video available',
            style: Theme.of(context).textTheme.bodySmall),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SingleExerciseScreen(exercise: exercise)),
          );
        },
      ),
    );
  }
}

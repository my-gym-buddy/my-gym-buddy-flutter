import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/workouts/single_workout_screen.dart';

class WorkoutCard extends StatelessWidget {
  WorkoutCard({super.key, required this.workout, this.refresh});

  final Workout workout;
  Function? refresh;

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
        title: Text(workout.name.toLowerCase(),
            style: Theme.of(context).textTheme.titleSmall),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SingleWorkoutScreen(workout: workout)),
          );
          if (refresh != null) {
            refresh!();
          }
        },
      ),
    );
  }
}

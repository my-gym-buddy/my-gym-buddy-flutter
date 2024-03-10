import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/widgets/set_row_display.dart';

class ExercisesRepSetDisplay extends StatelessWidget {
  ExercisesRepSetDisplay({super.key, required this.workout});

  Workout workout;

  @override
  Widget build(BuildContext context) {
    return workout.exercises != null
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workout.exercises!.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(workout.exercises![index].name),
                  subtitle: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: workout.exercises![index].sets.length,
                    itemBuilder: (context, setIndex) {
                      return SetRowDisplay(
                        setIndex: setIndex,
                        index: index,
                        selectedExercises: workout.exercises!,
                      );
                    },
                  ));
            },
          )
        : const CircularProgressIndicator();
  }
}

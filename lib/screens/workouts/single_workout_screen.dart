import 'package:flutter/material.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/workouts/active_workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/widgets/set_row_display.dart';
import 'package:gym_buddy_app/screens/workouts/widgets/exercises_rep_set_display.dart';

class SingleWorkoutScreen extends StatefulWidget {
  SingleWorkoutScreen({super.key, required this.workout});

  Workout workout;

  @override
  State<SingleWorkoutScreen> createState() => _SingleWorkoutScreenState();
}

class _SingleWorkoutScreenState extends State<SingleWorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.workout.exercises == null) {
      DatabaseHelper.getWorkoutGivenID(widget.workout.id!).then((value) {
        setState(() {
          widget.workout = value;
        });
      });
    }

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: atsButton(
            child: const Text('start workout'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ActiveWorkout(
                            workoutTemplate: widget.workout,
                          )));
            }),
        appBar: AppBar(
          title: Text(widget.workout.name),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child:
                  atsIconButton(icon: const Icon(Icons.edit), onPressed: () {}),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'there is no description for this workout',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'exercises',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ExercisesRepSetDisplay(workout: widget.workout)
              ],
            ),
          ),
        ));
  }
}

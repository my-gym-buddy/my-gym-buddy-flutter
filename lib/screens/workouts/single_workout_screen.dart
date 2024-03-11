import 'package:flutter/material.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/workouts/active_workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/widgets/set_row_display.dart';
import 'package:gym_buddy_app/screens/workouts/add_workout_screen.dart';

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
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ActiveWorkout(
                          workoutTemplate:
                              Workout.fromJson(widget.workout.toJson()))));

              widget.workout.exercises = null;
              setState(() {});
            }),
        appBar: AppBar(
          title: Text(widget.workout.name),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: atsIconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    var editedWorkout = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddWorkoutScreen(
                                  workout: widget.workout,
                                )));

                    if (editedWorkout == null) {
                      Navigator.pop(context);
                      return;
                    } else {
                      setState(() {
                        widget.workout = editedWorkout;
                      });
                    }
                  }),
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
                widget.workout.exercises != null
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.workout.exercises!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              title:
                                  Text(widget.workout.exercises![index].name),
                              subtitle: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: widget
                                    .workout.exercises![index].sets.length,
                                itemBuilder: (context, setIndex) {
                                  return SetRowDisplay(
                                    setIndex: setIndex,
                                    index: index,
                                    selectedExercises:
                                        widget.workout.exercises!,
                                  );
                                },
                              ));
                        },
                      )
                    : const CircularProgressIndicator(),
              ],
            ),
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/active_workout.dart';
import 'package:gym_buddy_app/screens/widgets/set_row.dart';
import 'package:gym_buddy_app/screens/widgets/set_row_display.dart';

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
        print(value.exercises!.first.sets);
        setState(() {
          widget.workout = value;
        });
      });
    }

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveWorkout(
                      workoutTemplate: widget.workout,
                    ),
                  ));
            },
            label: const Text('Start Workout')),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.workout.name),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: widget.workout.exercises != null
                      ? ListView.builder(
                          itemCount: widget.workout.exercises!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                title:
                                    Text(widget.workout.exercises![index].name),
                                subtitle: ListView.builder(
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
                      : const CircularProgressIndicator()),
            ],
          ),
        ));
  }
}

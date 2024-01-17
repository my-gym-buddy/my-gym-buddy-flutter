import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/widgets/set_row.dart';

class SingleWorkoutScreen extends StatefulWidget {
  SingleWorkoutScreen({super.key, required this.workout});

  Workout workout;

  @override
  State<SingleWorkoutScreen> createState() => _SingleWorkoutScreenState();
}

class _SingleWorkoutScreenState extends State<SingleWorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {}, label: const Text('Start Workout')),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.workout.name),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                itemCount: widget.workout.exercises.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(widget.workout.exercises[index].name),
                      subtitle: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.workout.exercises[index].sets.length,
                        itemBuilder: (context, setIndex) {
                          return SetRow(
                              setIndex: setIndex,
                              index: index,
                              selectedExercises: widget.workout.exercises,
                              refresh: null);
                        },
                      ));
                },
              )),
            ],
          ),
        ));
  }
}

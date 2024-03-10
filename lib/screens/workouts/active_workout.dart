import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';

class ActiveWorkout extends StatefulWidget {
  const ActiveWorkout({super.key, required this.workoutTemplate});

  final Workout workoutTemplate;

  @override
  State<ActiveWorkout> createState() => _ActiveWorkoutState();
}

class _ActiveWorkoutState extends State<ActiveWorkout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutTemplate.name),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: atsButton(child: Text("1h 21m 30s"), onPressed: () {}),
          )
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              atsButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                child: Text('cancel workout',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
              atsButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('finish workout'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

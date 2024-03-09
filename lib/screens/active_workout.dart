import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/workout.dart';

class ActiveWorkout extends StatefulWidget {
  const ActiveWorkout({super.key, required this.workoutTemplate});

  final Workout workoutTemplate;

  @override
  State<ActiveWorkout> createState() => _ActiveWorkoutState();
}

class _ActiveWorkoutState extends State<ActiveWorkout> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

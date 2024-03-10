import 'package:flutter/material.dart';
import 'package:gym_buddy_app/screens/exercises/all_exercises_screen.dart';
import 'package:gym_buddy_app/screens/workouts/all_workout_screen.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Ready to workout?',
      )),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Activities"),
            const SizedBox(
              height: 10,
            ),
            const Text("Workout Routines"),
            atsButton(
                child: Text('all workout routines'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllWorkoutScreen()));
                }),
            const SizedBox(
              height: 10,
            ),
            const Text("Statistics"),
            atsButton(child: Text('statistics'), onPressed: () {}),
            const SizedBox(
              height: 10,
            ),
            const Text("Exercises"),
            atsButton(
                child: Text('all excerises'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllExercisesScreen()));
                }),
          ],
        ),
      ),
    );
  }
}

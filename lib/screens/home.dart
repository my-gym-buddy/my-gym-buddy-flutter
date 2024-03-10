import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gym_buddy_app/database_helper.dart';
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
            const Text("today's activities"),
            const SizedBox(
              height: 10,
            ),
            const Text("workout routines"),
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
            const Text("statistics"),
            atsButton(child: Text('statistics'), onPressed: null),
            const SizedBox(
              height: 10,
            ),
            const Text("exercises"),
            atsButton(
                child: Text('all excerises'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllExercisesScreen()));
                }),
            const SizedBox(
              height: 10,
            ),
            const Text("settings"),
            atsButton(
                child: Text('export database'),
                onPressed: () {
                  DatabaseHelper.exportDatabase();
                }),
            atsButton(child: Text('import database'), onPressed: null),
            atsButton(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                child: Text(
                  'reset database',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                onPressed: () {
                  DatabaseHelper.resetDatabase();
                  if (kDebugMode) print('database reset');
                }),
          ],
        ),
      ),
    );
  }
}

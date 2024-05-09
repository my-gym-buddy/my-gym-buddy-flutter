import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/exercises/all_exercises_screen.dart';
import 'package:gym_buddy_app/screens/settings.dart';
import 'package:gym_buddy_app/screens/statistics/statistics.dart';
import 'package:gym_buddy_app/screens/workouts/active_workout.dart';
import 'package:gym_buddy_app/screens/workouts/all_workout_screen.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/workouts/single_workout_screen.dart';

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
          actions: [
            atsIconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Settings()));
                })
          ],
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
            const Text("recommended workouts for today"),
            const SizedBox(
              height: 10,
            ),
            FutureBuilder(
                future: DatabaseHelper.getTodayRecommendedWorkouts(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return SizedBox(
                          height: 75,
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data.length + 2,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index == snapshot.data.length) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: atsButton(
                                            child: const Text('all workouts'),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const AllWorkoutScreen()));
                                            }),
                                      );
                                    }

                                    if (index == snapshot.data.length + 1) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: atsButton(
                                            child: const Text(
                                                'start empty workout'),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => ActiveWorkout(
                                                          workoutTemplate: Workout(
                                                              name:
                                                                  'empty workout',
                                                              exercises: []))));
                                            }),
                                      );
                                    }

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: atsButton(
                                          child:
                                              Text(snapshot.data[index].name),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SingleWorkoutScreen(
                                                            workout: snapshot
                                                                .data[index])));
                                          }),
                                    );
                                  })));
                    } else {
                      return const Text('no recommended workouts for today');
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
            const SizedBox(
              height: 10,
            ),
            const Text("statistics"),
            atsButton(
                child: Text('statistics'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StatisticsScreen()));
                }),
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
          ],
        ),
      ),
    );
  }
}

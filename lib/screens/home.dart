import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/exercises/all_exercises_screen.dart';
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
            const Text("settings"),
            atsButton(
                child: Text('export database'),
                onPressed: () {
                  DatabaseHelper.exportDatabase();
                }),
            atsButton(
                child: Text('import database'),
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    File file = File(result.files.single.path!);
                    await DatabaseHelper.importDatabase(file);
                    setState(() {});
                  } else {
                    //todo: handle error
                  }
                }),
            atsButton(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                child: Text(
                  'reset database',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                onPressed: () async {
                  await showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'reset database?',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    'are you sure you want to reset the database. This will delete all your data and cannot be undone.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error)),
                                const Text(
                                  'Consider exporting your data before resetting the database.',
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    atsButton(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .errorContainer,
                                      child: Text('yes',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onErrorContainer)),
                                      onPressed: () {
                                        DatabaseHelper.resetDatabase();
                                        Navigator.pop(context);
                                      },
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    atsButton(
                                      child: const Text('no'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      });
                }),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: DropdownButtonFormField(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.primaryContainer,
                    border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                  ),
                  isExpanded: true,
                  alignment: Alignment.center,
                  value: Config.unit,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                  items: const [
                    DropdownMenuItem(
                        alignment: Alignment.center,
                        value: 'metric',
                        child: Text(
                          'metric (kg)',
                        )),
                    DropdownMenuItem(
                        alignment: Alignment.center,
                        value: 'imperial',
                        child: Text('imperial (lb)'))
                  ],
                  onChanged: (value) {
                    Config.unit = value.toString();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

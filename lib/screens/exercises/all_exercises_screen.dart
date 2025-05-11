import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/exercises/add_exercise_screen.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';

import 'package:gym_buddy_app/screens/exercises/widgets/exercise_card.dart';
import 'package:gym_buddy_app/screens/home.dart';

class AllExercisesScreen extends StatefulWidget {
  const AllExercisesScreen({super.key});

  @override
  State<AllExercisesScreen> createState() => _AllExercisesScreenState();
}

class _AllExercisesScreenState extends State<AllExercisesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('all exercises',
              style: Theme.of(context).textTheme.titleLarge),
          leading: atsIconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Home()));
              }),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: atsIconButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddExerciseScreen()),
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.add)),
            ),
          ],
        ),
        body: FutureBuilder(
          future: DatabaseHelper.getExercises(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Exercise exercise = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExerciseCard(exercise: exercise, editMode: true),
                      );
                    },
                  ),
                );
              } else {
                return const Center(child: Text('no exercises found'));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}

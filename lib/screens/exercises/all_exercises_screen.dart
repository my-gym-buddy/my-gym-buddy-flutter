import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/exercises/add_exercise_screen.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/widgets/exercise_card.dart';

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
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Exercise exercise = snapshot.data![index];
                    return ExerciseCard(exercise: exercise);
                  },
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

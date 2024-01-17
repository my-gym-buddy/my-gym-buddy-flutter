import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/pocketbase_helper.dart';
import 'package:gym_buddy_app/screens/add_exercise_screen.dart';
import 'package:gym_buddy_app/screens/single_exercise_screen.dart';

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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('All Exercises'),
          actions: [
            IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddExerciseScreen()),
                  );
                  setState(() {});
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: FutureBuilder(
          future: PocketBaseHelper.getExercises(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Exercise exercise = snapshot.data![index];
                    return ListTile(
                      title: Text(exercise.name),
                      subtitle: Text(exercise.videoID ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SingleExerciseScreen(exercise: exercise)),
                        );
                      },
                    );
                  },
                );
              } else {
                return const Center(child: Text('No exercises found'));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}

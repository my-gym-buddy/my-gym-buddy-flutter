import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/add_workout_screen.dart';
import 'package:gym_buddy_app/screens/single_workout_screen.dart';

class AllWorkoutScreen extends StatefulWidget {
  const AllWorkoutScreen({super.key});

  @override
  State<AllWorkoutScreen> createState() => _AllWorkoutScreenState();
}

class _AllWorkoutScreenState extends State<AllWorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('All Workouts'),
          actions: [
            IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddWorkoutScreen()),
                  );
                  setState(() {});
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: FutureBuilder(
          future: DatabaseHelper.getWorkoutList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Workout workout = snapshot.data![index];
                    return ListTile(
                      title: Text(workout.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SingleWorkoutScreen(workout: workout)),
                        );
                      },
                    );
                  },
                );
              } else {
                return const Center(child: Text('No workouts found'));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/workouts/add_workout_screen.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/widgets/workout_card.dart';

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
          title: const Text('all workouts'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: atsIconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddWorkoutScreen()),
                    );
                    setState(() {});
                  }),
            )
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
                    return WorkoutCard(
                      workout: workout,
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

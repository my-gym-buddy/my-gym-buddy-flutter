import 'package:flutter/material.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/home.dart';
import 'package:gym_buddy_app/screens/workouts/active_workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_modal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.openLocalDatabase(newDatabase: false);

  Config.loadConfig();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gym Buddy',
        theme: ThemeData(
          fontFamily: 'Montserrat',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: DatabaseHelper.hasTemporaryWorkout(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == true) {
                // We have a temporary workout to recover
                return const WorkoutRecoveryScreen();
              }
              return const Home();
            }
            // Show loading indicator while checking
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ));
  }
}

class WorkoutRecoveryScreen extends StatelessWidget {
  const WorkoutRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Recovery'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Unfinished Workout Detected',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'It looks like your last workout session was interrupted. Would you like to resume where you left off or start a new session?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  atsButton(
                    onPressed: () {
                      // Clear the temporary workout
                      DatabaseHelper.clearTemporaryWorkout();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    },
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    child: Text(
                      'discard',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  atsButton(
                    onPressed: () async {
                      // Retrieve the temporary workout
                      final tempWorkout = await DatabaseHelper.getTemporaryWorkout();
                      if (tempWorkout != null && context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ActiveWorkout(
                              workoutTemplate: tempWorkout,
                            ),
                          ),
                        );
                      } else if (context.mounted) {
                        // Failed to retrieve the workout
                        AtsModal.show(
                          context: context,
                          title: 'error',
                          message: 'Could not recover the previous workout.',
                          primaryButtonText: 'ok',
                          onPrimaryButtonPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const Home()),
                            );
                          },
                        );
                      }
                    },
                    child: const Text('resume'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

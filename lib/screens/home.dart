import 'package:flutter/material.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_modal.dart';
import 'package:gym_buddy_app/screens/exercises/all_exercises_screen.dart';
import 'package:gym_buddy_app/screens/help/temporary_guide.dart';
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
  void initState() {
    super.initState();
    // Check for unfinished workouts when Home screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUnfinishedWorkout();
    });
  }

  // Check for unfinished workout and show recovery modal if found
  Future<void> _checkForUnfinishedWorkout() async {
    bool hasTemporaryWorkout = await DatabaseHelper.hasTemporaryWorkout();

    if (hasTemporaryWorkout && mounted) {
      _showWorkoutRecoveryModal();
    }
  } // Show modal for workout recovery

  void _showWorkoutRecoveryModal() async {
    // First, get the temporary workout to display its details
    final tempWorkout = await DatabaseHelper.getTemporaryWorkout();

    if (tempWorkout == null || !mounted) {
      return;
    }

    // Calculate how many sets are left to complete
    int totalSets = 0;
    int completedSets = 0;

    for (var exercise in tempWorkout.exercises ?? []) {
      for (var set in exercise.sets) {
        totalSets++;
        if (set.completed) {
          completedSets++;
        }
      }
    }

    int setsLeft = totalSets - completedSets;
    int exerciseCount = tempWorkout.exercises?.length ?? 0;
    // Get the workout duration if available
    int workoutDuration = tempWorkout.duration ?? 0;

    // Format duration as HH:MM:SS
    String formatDuration(int seconds) {
      int hours = seconds ~/ 3600;
      int minutes = (seconds % 3600) ~/ 60;
      int remainingSeconds = seconds % 60;

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    // Format date for the start time
    String startTimeStr = tempWorkout.startTime != null
        ? '${tempWorkout.startTime!.hour.toString().padLeft(2, '0')}:${tempWorkout.startTime!.minute.toString().padLeft(2, '0')}'
        : 'Not available';

    // Using showModalBottomSheet directly for more control instead of AtsModal.show
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // Prevent dismissal by tapping outside
      enableDrag: false, // Prevent dismissal by dragging down
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (BuildContext context) => AtsModal(
        title: 'Unfinished Workout Detected',
        message:
            'It looks like your last workout session was interrupted. Would you like to resume where you left off or start a new session?',
        primaryButtonText: 'discard',
        secondaryButtonText: 'resume',
        customContent: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('workout details:',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              Text('name: ${tempWorkout.name}',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('started at: $startTimeStr',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('duration: ${formatDuration(workoutDuration)}',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('exercises: $exerciseCount',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('sets completed: $completedSets / $totalSets',
                  style: Theme.of(context).textTheme.bodyMedium),
              if (setsLeft > 0)
                Text('sets left: $setsLeft',
                    style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        onPrimaryButtonPressed: () {
          // Clear the temporary workout
          DatabaseHelper.clearTemporaryWorkout();
          Navigator.of(context).pop();
        },
        onSecondaryButtonPressed: () {
          if (mounted) {
            Navigator.of(context).pop(); // Close the modal
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ActiveWorkout(
                  workoutTemplate: tempWorkout,
                ),
              ),
            );
          } else if (mounted) {
            // This code is unreachable now, but keeping for safety
            // Failed to retrieve the workout
            Navigator.of(context).pop(); // Close the first modal

            // Show error modal with non-dismissible behavior
            showModalBottomSheet(
              context: context,
              isDismissible: false,
              enableDrag: false,
              useSafeArea: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
              ),
              builder: (BuildContext context) => AtsModal(
                title: 'error',
                message: 'Could not recover the previous workout.',
                primaryButtonText: 'ok',
                onPrimaryButtonPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          }
        },
        primaryButtonColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
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
                                                        builder: (context) =>
                                                            ActiveWorkout(
                                                                workoutTemplate:
                                                                    Workout(
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
                                                              workout:
                                                                  snapshot.data[
                                                                      index])));
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
                  child: const Text('statistics'),
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
                  child: const Text('all excerises'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AllExercisesScreen()));
                  }),
              const SizedBox(
                height: 10,
              ),
              // Show temporary guide if user hasn't seen it yet
              if (!Config.hasSeenGuide) const TemporaryGuide(),
            ],
          ),
        ),
      ),
    );
  }
}

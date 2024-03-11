import 'package:flutter/material.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/workouts/widgets/exercises_rep_set_display.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class ActiveWorkout extends StatefulWidget {
  ActiveWorkout({super.key, required this.workoutTemplate});

  final Workout workoutTemplate;

  final stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);

  String displayTime = "";

  @override
  State<ActiveWorkout> createState() => _ActiveWorkoutState();
}

class _ActiveWorkoutState extends State<ActiveWorkout> {
  @override
  void initState() {
    super.initState();
    widget.stopWatchTimer.onStartTimer();
  }

  @override
  void dispose() async {
    super.dispose();
    await widget.stopWatchTimer.dispose(); // Need to call dispose function.
  }

  void showCancelWorkoutModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'cancel workout session?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'are you sure you want to cancel the workout session? This will end the current workout and discard all the data.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      atsButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                        child: Text('cancel workout',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer)),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      atsButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('continue workout'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void showEndWorkoutModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'end workout session?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'are you sure you want to end the workout session? This will end the current workout and save all the data.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      atsButton(
                        onPressed: () async {
                          List<Exercise> exerciseToRemove = [];
                          for (final exercise
                              in widget.workoutTemplate.exercises!) {
                            List<RepSet> repSetToRemove = [];
                            for (final repSet in exercise.sets) {
                              if (repSet.completed == false) {
                                repSetToRemove.add(repSet);
                              }
                            }
                            for (final repSet in repSetToRemove) {
                              exercise.sets.remove(repSet);
                            }
                            if (exercise.sets.isEmpty) {
                              exerciseToRemove.add(exercise);
                            }
                          }
                          for (final exercise in exerciseToRemove) {
                            widget.workoutTemplate.exercises!.remove(exercise);
                          }

                          DatabaseHelper.saveWorkoutSession(
                              widget.workoutTemplate,
                              widget.stopWatchTimer.secondTime.value);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                        child: Text('end & save',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer)),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      atsButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('continue workout'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutTemplate.name),
        leading: atsIconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              showEndWorkoutModal();
            }),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: atsButton(
                child: StreamBuilder<int>(
                  stream: widget.stopWatchTimer.rawTime,
                  initialData: 0,
                  builder: (context, snapshot) {
                    final value = snapshot.data;
                    final displayTime = StopWatchTimer.getDisplayTime(value!,
                        milliSecond: false);
                    return Text(displayTime);
                  },
                ),
                onPressed: () {}),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'there is no description for this workout',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ExercisesRepSetDisplay(
                  isActiveWorkout: true,
                  physics: const NeverScrollableScrollPhysics(),
                  workoutTemplate: widget.workoutTemplate),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  atsButton(
                    onPressed: () {
                      showCancelWorkoutModal();
                    },
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    child: Text('cancel workout',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer)),
                  ),
                  atsButton(
                    onPressed: () {
                      showEndWorkoutModal();
                    },
                    child: Text(
                      'end workout',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}

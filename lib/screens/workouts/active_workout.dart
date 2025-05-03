import 'package:flutter/material.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_modal.dart';
import 'package:gym_buddy_app/screens/workouts/widgets/exercises_rep_set_display.dart';
import 'package:search_page/search_page.dart';
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
  List<Exercise> allExercises = [];

  @override
  void initState() {
    super.initState();
    widget.stopWatchTimer.onStartTimer();

    DatabaseHelper.getExercises().then((value) {
      setState(() {
        allExercises = value;
      });
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await widget.stopWatchTimer.dispose(); // Need to call dispose function.
  }

  void showEmptyWorkoutErrorMessage() {
    AtsModal.show(
      context: context,
      title: 'empty workout',
      message: 'you cannot end a workout with no exercises. Please add exercises to the workout before ending it.',
      primaryButtonText: 'cancel workout',
      secondaryButtonText: 'continue workout',
      onPrimaryButtonPressed: () {
        if (context.mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
      onSecondaryButtonPressed: () {
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      primaryButtonColor: Theme.of(context).colorScheme.errorContainer,
    );
  }

  void showCancelWorkoutModal() {
    AtsModal.show(
      context: context,
      title: 'cancel workout session?',
      message: 'are you sure you want to cancel the workout session? This will end the current workout and discard all the data.',
      primaryButtonText: 'cancel workout',
      secondaryButtonText: 'continue workout',
      onPrimaryButtonPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
      onSecondaryButtonPressed: () {
        Navigator.pop(context);
      },
      primaryButtonColor: Theme.of(context).colorScheme.errorContainer,
    );
  }

  Future<void> showEndWorkoutSummaryModal() async {
    await AtsModal.show(
      context: context,
      title: 'workout summary',
      message: 'duration: ${StopWatchTimer.getDisplayTime(widget.stopWatchTimer.rawTime.value, milliSecond: false)}\ntotal weight lifted: ${Helper.getWeightInCorrectUnit(Helper.calculateTotalWeightLifted(widget.workoutTemplate)).toStringAsFixed(2)} ${Config.getUnitAbbreviation()}',
      primaryButtonText: 'share',
      secondaryButtonText: 'close',
      onPrimaryButtonPressed: () {
        Helper.shareWorkoutSummary(
            widget.workoutTemplate,
            widget.stopWatchTimer.secondTime.value);
      },
      onSecondaryButtonPressed: () {
        Navigator.pop(context);
      },
      customContent: Expanded(
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              ...widget.workoutTemplate.exercises!
                  .map((exercise) => Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          Text(
                            exercise.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall,
                          ),
                          ...exercise.sets
                              .map((repSet) => Text(
                                  '${Helper.getWeightInCorrectUnit(repSet.weight).toStringAsFixed(2)} ${Config.getUnitAbbreviation()}x ${repSet.reps} reps',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium))
                              .toList(),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ))
                  .toList(),
            ]),
          ),
        ),
      ),
    );
  }

  void showEndWorkoutConfirmationModal() async {
    AtsModal.show(
      context: context,
      title: 'end workout session?',
      message: 'are you sure you want to end the workout session? This will end the current workout and save all the data.',
      primaryButtonText: 'end & save',
      secondaryButtonText: 'continue workout',
      onPrimaryButtonPressed: () async {
        List<Exercise> exerciseToRemove = [];
        for (final exercise in widget.workoutTemplate.exercises!) {
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

        if (widget.workoutTemplate.exercises!.isNotEmpty) {
          DatabaseHelper.saveWorkoutSession(
              widget.workoutTemplate,
              widget.stopWatchTimer.secondTime.value);

          widget.stopWatchTimer.onStopTimer();

          await showEndWorkoutSummaryModal();
          if (context.mounted) {
            Navigator.pop(context);
            Navigator.pop(context);
          }
        } else {
          if (context.mounted) {
            Navigator.pop(context);
            showEmptyWorkoutErrorMessage();
          }
        }
      },
      onSecondaryButtonPressed: () {
        Navigator.pop(context);
      },
      primaryButtonColor: Theme.of(context).colorScheme.errorContainer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (status) {
        showEndWorkoutConfirmationModal();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.workoutTemplate.name),
          leading: atsIconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                showEndWorkoutConfirmationModal();
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
                widget.workoutTemplate.description != null
                    ? Text(
                        widget.workoutTemplate.description ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : const SizedBox(),
                const SizedBox(height: 20),
                ExercisesRepSetDisplay(
                    isActiveWorkout: true,
                    physics: const NeverScrollableScrollPhysics(),
                    workoutTemplate: widget.workoutTemplate),
                const SizedBox(height: 20),
                Center(
                  child: atsButton(
                      onPressed: () => showSearch(
                          context: context,
                          delegate: SearchPage<Exercise>(
                              showItemsOnEmpty: true,
                              items: allExercises,
                              searchLabel: 'search exercises',
                              failure: const Center(
                                child: Text('no exercises found'),
                              ),
                              filter: (exercise) => [
                                    exercise.name,
                                  ],
                              builder: (exercise) => ListTile(
                                    title: Text(exercise.name.toLowerCase()),
                                    onTap: () {
                                      setState(() {
                                        widget.workoutTemplate.exercises!.add(
                                            Exercise.fromJson(
                                                exercise.toJson()));
                                      });
                                      Navigator.pop(context);
                                    },
                                  ))),
                      child: const Text('add exercise')),
                ),
                const SizedBox(
                  width: 10,
                ),
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
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer)),
                    ),
                    atsButton(
                      onPressed: () {
                        showEndWorkoutConfirmationModal();
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
      ),
    );
  }
}

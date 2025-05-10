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
  static const String cancelWorkoutText = 'cancel workout';
  static const String continueWorkoutText = 'continue workout';

  @override
  void initState() {
    super.initState();

    // Set start time if not already set
    if (widget.workoutTemplate.startTime == null) {
      widget.workoutTemplate.startTime = DateTime.now();
    }

    widget.stopWatchTimer.onStartTimer();
    // We're no longer doing automatic periodic saving here
    // The saving is triggered only when a checkbox is clicked in SetRow

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
      message:
          'you cannot end a workout with no exercises. Please add exercises to the workout before ending it.',
      primaryButtonText: cancelWorkoutText,
      secondaryButtonText: continueWorkoutText,
      onPrimaryButtonPressed: () {
        if (context.mounted) {
          // Use Future.delayed to avoid Navigator lock issues
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          });
        }
      },
      onSecondaryButtonPressed: () {
        if (context.mounted) {
          // Use Future.delayed to avoid Navigator lock issues
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pop();
            // We don't reset the startTime here to maintain workout continuity
          });
        }
      },
      primaryButtonColor: Theme.of(context).colorScheme.errorContainer,
    );
  }

  void showCancelWorkoutModal() {
    AtsModal.show(
      context: context,
      title: 'cancel workout session?',
      message:
          'are you sure you want to cancel the workout session? This will end the current workout and discard all the data.',
      primaryButtonText: cancelWorkoutText,
      secondaryButtonText: continueWorkoutText,
      onPrimaryButtonPressed: () {
        // Clear temporary workout data when canceling
        DatabaseHelper.clearTemporaryWorkout().then((_) {
          if (context.mounted) {
            // Use Future.delayed to avoid Navigator lock issues
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
          }
        });
      },
      onSecondaryButtonPressed: () {
        // Use Future.delayed to avoid Navigator lock issues
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pop();
        });
      },
      primaryButtonColor: Theme.of(context).colorScheme.errorContainer,
    );
  }

  Future<void> showEndWorkoutSummaryModal() async {
    return AtsModal.show(
      context: context,
      title: 'workout summary',
      message:
          'duration: ${StopWatchTimer.getDisplayTime(widget.stopWatchTimer.rawTime.value, milliSecond: false)}\ntotal weight lifted: ${Helper.getWeightInCorrectUnit(Helper.calculateTotalWeightLifted(widget.workoutTemplate)).toStringAsFixed(2)} ${Config.getUnitAbbreviation()}',
      primaryButtonText: 'share',
      secondaryButtonText: 'close',
      onPrimaryButtonPressed: () {
        Helper.shareWorkoutSummary(
            widget.workoutTemplate, widget.stopWatchTimer.secondTime.value);
      },
      onSecondaryButtonPressed: () {
        Navigator.of(context).pop();
      },
      customContent: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              ...widget.workoutTemplate.exercises!
                  .map((exercise) => Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            exercise.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          ...exercise.sets
                              .map((repSet) => Text(
                                  '${Helper.getWeightInCorrectUnit(repSet.weight).toStringAsFixed(2)} ${Config.getUnitAbbreviation()}x ${repSet.reps} reps',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium))
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

  void showEndWorkoutConfirmationModal() {
    // First check if workout has any completed exercises
    bool hasCompletedExercises = false;

    // Check if any exercise has at least one completed set
    for (final exercise in widget.workoutTemplate.exercises ?? []) {
      for (final repSet in exercise.sets) {
        if (repSet.completed) {
          hasCompletedExercises = true;
          break;
        }
      }
      if (hasCompletedExercises) break;
    }

    // If no completed exercises, show the error message directly
    if (!hasCompletedExercises) {
      showEmptyWorkoutErrorMessage();
      return;
    }

    // Store the logic to be executed after confirming
    confirmEndWorkout() async {
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
            widget.workoutTemplate, widget.stopWatchTimer.secondTime.value);

        widget.stopWatchTimer.onStopTimer();

        // Clear temporary workout data after successful save
        await DatabaseHelper.clearTemporaryWorkout();

        if (mounted) {
          Navigator.of(context).pop(); // Pop the confirmation modal
          // Show the summary in a separate step after the pop completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showEndWorkoutSummaryModal().then((_) {
              if (mounted) {
                Navigator.of(context)
                    .pop(); // Pop back to previous screen after summary
              }
            });
          });
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).pop(); // Pop the confirmation modal
          // Show the error message in a separate step after the pop completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showEmptyWorkoutErrorMessage();
          });
        }
      }
    }

    // Proceed with normal confirmation dialog if there are completed exercises
    AtsModal.show(
      context: context,
      title: 'end workout session?',
      message:
          'are you sure you want to end the workout session? This will end the current workout and save all the data.',
      primaryButtonText: 'end & save',
      secondaryButtonText: continueWorkoutText,
      onPrimaryButtonPressed: confirmEndWorkout,
      onSecondaryButtonPressed: () {
        Navigator.of(context).pop();
      },
      primaryButtonColor: Theme.of(context).colorScheme.errorContainer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (status, result) {
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
                      child: Text(cancelWorkoutText,
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
                      child: const Text(
                        'end workout',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

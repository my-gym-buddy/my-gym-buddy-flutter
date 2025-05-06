import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/widgets/set_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:gym_buddy_app/screens/workouts/widgets/rest_timer_widget.dart';

class ExercisesRepSetDisplay extends StatefulWidget {
  // Add these properties
  // final VoidCallback? pauseWorkoutTimer;
  // final VoidCallback? resumeWorkoutTimer;

  ExercisesRepSetDisplay({
    super.key,
    required this.workoutTemplate,
    this.physics = const ScrollPhysics(),
    this.isActiveWorkout = false,
    this.isEditMode = false,
    this.onChanged,
    // this.pauseWorkoutTimer, // Add these parameters
    // this.resumeWorkoutTimer,
  });

  Workout workoutTemplate;
  final VoidCallback? onChanged;
  bool isActiveWorkout;
  bool isEditMode; // Add this parameter to control edit functionality
  ScrollPhysics physics;

  @override
  State<ExercisesRepSetDisplay> createState() => _ExercisesRepSetDisplayState();
}

class _ExercisesRepSetDisplayState extends State<ExercisesRepSetDisplay> {
  // Add this logging function at the top of your class
  void _logRestTimeValues(Exercise exercise, int setIndex) {
    print('---------- REST TIME DEBUG ----------');
    print('Exercise: ${exercise.name}');
    print('Exercise-level restBetweenSets: ${exercise.restBetweenSets}');
    print('Exercise-level restAfterSet: ${exercise.restAfterSet}');
    if (setIndex >= 0 && setIndex < exercise.sets.length) {
      print('Set $setIndex restBetweenSets: ${exercise.sets[setIndex].restBetweenSets}');
    }
    print('-------------------------------------');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.workoutTemplate.exercises == null ||
        widget.workoutTemplate.exercises!.isEmpty) {
      return const Center(
        child: Text('No exercises added'),
      );
    }

    // If only one item, disable reordering
    if (widget.workoutTemplate.exercises!.length == 1) {
      return _buildExerciseColumn(0);
    }

    return ReorderableListView(
      shrinkWrap: true,
      physics: widget.physics,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final Exercise item =
              widget.workoutTemplate.exercises!.removeAt(oldIndex);
          widget.workoutTemplate.exercises!.insert(newIndex, item);
        });
      },
      children: <Widget>[
        for (int index = 0;
            index < widget.workoutTemplate.exercises!.length;
            index += 1)
          _buildExerciseColumn(index),
      ],
    );
  }

  // Extract column building to a separate method
  Widget _buildExerciseColumn(int index) {
    final exercise = widget.workoutTemplate.exercises![index];
    _logRestTimeValues(exercise, -1); // Log overall exercise values
    double paddingForMinRest = 9;
    return Column(
      key: ValueKey('exercise_${exercise.name}_$index'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side with exercise name
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  exercise.name.toLowerCase(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 10),
                if (widget.isEditMode) // Only show delete button in edit mode
                  atsIconButton(
                    size: 35,
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                    onPressed: () {
                      setState(() {
                        widget.workoutTemplate.exercises!.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.delete),
                  ),
              ],
            ),

            // Timer button only in edit mode
            if (widget.isEditMode)
              atsIconButton(
                size: 35,
                backgroundColor: exercise.restBetweenSets != null ||
                        exercise.restAfterSet != null
                    ? Theme.of(context).colorScheme.tertiaryFixed
                    : Theme.of(context).colorScheme.errorContainer,
                foregroundColor: exercise.restBetweenSets != null ||
                        exercise.restAfterSet != null
                    ? Colors.white
                    : Theme.of(context).colorScheme.onErrorContainer,
                onPressed: () {
                  _showRestTimeModal(exercise);
                },
                icon: const Icon(Icons.timelapse_outlined),
              ),
          ],
        ),

        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (int setIndex = -1;
                setIndex < widget.workoutTemplate.exercises![index].sets.length;
                setIndex += 1)
              Column(
                children: [
                  // The set row
                  SetRow(
                    isActiveWorkout: widget.isActiveWorkout,
                    setIndex: setIndex,
                    index: index,
                    selectedExercises: widget.workoutTemplate.exercises!,
                    refresh: () {
                      setState(() {});
                    },
                    isEditable: true,
                  ),

                  // Show rest time after each set (except the last one)
                  if (setIndex >= 0 &&
                      setIndex <
                          widget.workoutTemplate.exercises![index].sets.length -
                              1 &&
                      widget.workoutTemplate.exercises![index].restBetweenSets !=
                          null)
                    StatefulBuilder(
                      builder: (context, setStateLocal) {
                        final set = widget
                            .workoutTemplate.exercises![index].sets[setIndex];

                        // Check if set is completed and show timer based on that
                        bool isTimerActive = set.completed ?? false;

                        return Column(
                          children: [
                            // Display rest time text ONLY in edit mode
                            if (widget.isEditMode)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryFixed,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatRestTimeSimple(widget.workoutTemplate.exercises![index].restBetweenSets!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiaryFixed,
                                    ),
                                  ),
                                ],
                              ),

                            // Only show timer progress bar if set is completed in active workout mode
                            if (isTimerActive && widget.isActiveWorkout)
                              RestTimerWidget(
                                restDuration: widget.workoutTemplate.exercises![index].restBetweenSets!,
                                exercise: widget.workoutTemplate.exercises![index],
                                isBetweenSets: true,
                                setIndex: setIndex,
                                onComplete: () {
                                  setStateLocal(() {
                                    // Force update rest time values when saving
                                    if (widget.onChanged != null) {
                                      // This will trigger saving to the database with current values
                                      widget.onChanged!();
                                    }
                                  });
                                },
                              ),
                          ],
                        );
                      },
                    ),
                ],
              ),
          ],
        ),

        // Add the "Rest after set" display here
        if (exercise.restAfterSet != null)
          StatefulBuilder(
            builder: (context, setStateLocal) {
              // Check if all sets in this exercise are completed
              bool allSetsCompleted = exercise.sets.isNotEmpty && 
                                      exercise.sets.every((set) => set.completed == true);
              
              return Column(
                children: [
                  // Display rest time text ONLY in edit mode
                  if (widget.isEditMode)
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, paddingForMinRest, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: Theme.of(context).colorScheme.tertiaryFixed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatRestTimeSimple(exercise.restAfterSet!),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.tertiaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Only show timer progress bar if all sets are completed in active workout mode
                  if (allSetsCompleted && widget.isActiveWorkout)
                    RestTimerWidget(
                      restDuration: exercise.restAfterSet!,
                      exercise: exercise,
                      isBetweenSets: false, // This is rest AFTER set
                      setIndex: exercise.sets.length - 1, // Last set
                      onComplete: () {
                        setStateLocal(() {
                          // Force update rest time values when saving
                          if (widget.onChanged != null) {
                            widget.onChanged!();
                          }
                        });
                      },
                    ),
                ],
              );
            },
          ),

        // Keep the "add set" button only in edit mode
      
          atsButton(
            onPressed: () {
              RepSet? lastRepSet;

              if (widget.workoutTemplate.exercises![index].sets.isNotEmpty) {
                lastRepSet = widget.workoutTemplate.exercises![index].sets.last;
              }

              setState(() {
                widget.workoutTemplate.exercises![index].sets.add(RepSet(
                  reps: lastRepSet != null ? lastRepSet.reps : 0,
                  weight: lastRepSet != null ? lastRepSet.weight : 0,
                  note: null,
                  restBetweenSets: exercise.restBetweenSets,
                  restAfterSet: exercise.restAfterSet));
              });
            },
            child: const Text('add set')),
      ],
    );
  }

  String _formatRestTimeSimple(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;

    if (mins > 0) {
      if (secs > 0) {
        return '$mins:${secs.toString().padLeft(2, '0')} min rest';
      } else {
        return '$mins min rest';
      }
    } else {
      return '$secs sec rest';
    }
  }

  void _showRestTimeModal(Exercise exercise) {
    print('---------- REST TIME MODAL DEBUG ----------');
    print('Before setting: Exercise ${exercise.name}');
    print('restBetweenSets: ${exercise.restBetweenSets}');
    print('restAfterSet: ${exercise.restAfterSet}');

    final bool hasMultipleSets = exercise.sets.length > 1;

    int betweenSetsMinutes = 0;
    int betweenSetsSeconds = 0;
    int afterSetMinutes = 0;
    int afterSetSeconds = 0;

    // Initialize with existing values if any
    if (exercise.restBetweenSets != null) {
      betweenSetsMinutes = exercise.restBetweenSets! ~/ 60;
      betweenSetsSeconds = exercise.restBetweenSets! % 60;
    }

    if (exercise.restAfterSet != null) {
      afterSetMinutes = exercise.restAfterSet! ~/ 60;
      afterSetSeconds = exercise.restAfterSet! % 60;
    }

    showModalBottomSheet(
      context: context, // Use the class context
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 350 + (hasMultipleSets ? 100 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Only show rest between sets for multiple sets
                if (hasMultipleSets) ...[
                  const Text(
                    'Rest between each sets',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 32,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                betweenSetsMinutes = index;
                              });
                            },
                            scrollController: FixedExtentScrollController(
                              initialItem: betweenSetsMinutes,
                            ),
                            children: List.generate(60, (index) {
                              return Center(child: Text('$index min'));
                            }),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 32,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                betweenSetsSeconds = index;
                              });
                            },
                            scrollController: FixedExtentScrollController(
                              initialItem: betweenSetsSeconds,
                            ),
                            children: List.generate(60, (index) {
                              return Center(child: Text('$index sec'));
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Text(
                  'Rest after whole set',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 32,
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              afterSetMinutes = index;
                            });
                          },
                          scrollController: FixedExtentScrollController(
                            initialItem: afterSetMinutes,
                          ),
                          children: List.generate(60, (index) {
                            return Center(child: Text('$index min'));
                          }),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 32,
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              afterSetSeconds = index;
                            });
                          },
                          scrollController: FixedExtentScrollController(
                            initialItem: afterSetSeconds,
                          ),
                          children: List.generate(60, (index) {
                            return Center(child: Text('$index sec'));
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final int betweenSetsTotal = hasMultipleSets
                            ? (betweenSetsMinutes * 60 + betweenSetsSeconds)
                            : 0;

                        final int afterSetTotal =
                            afterSetMinutes * 60 + afterSetSeconds;

                        print('New values being set:');
                        print('betweenSetsTotal: $betweenSetsTotal');
                        print('afterSetTotal: $afterSetTotal');

                        setState(() {
                          // Store the rest time at exercise level for future sets
                          exercise.restBetweenSets =
                              hasMultipleSets && betweenSetsTotal > 0
                                  ? betweenSetsTotal
                                  : null;

                          // Update all existing sets with the new rest time
                          for (var set in exercise.sets) {
                            set.restBetweenSets = exercise.restBetweenSets;
                            set.restAfterSet =
                                exercise.restAfterSet; // Add this line
                          }

                          // Store after-set rest time
                          exercise.restAfterSet =
                              afterSetTotal > 0 ? afterSetTotal : null;

                          print('After setting: Exercise ${exercise.name}');
                          print('restBetweenSets: ${exercise.restBetweenSets}');
                          print('restAfterSet: ${exercise.restAfterSet}');

                          if (widget.onChanged != null) {
                            widget.onChanged!();
                          }
                        });

                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

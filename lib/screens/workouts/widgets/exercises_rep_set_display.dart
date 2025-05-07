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
      print(
          'Set $setIndex restBetweenSets: ${exercise.sets[setIndex].restBetweenSets}');
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

  Widget _buildExerciseColumn(int index) {
    final exercise = widget.workoutTemplate.exercises![index];
    _logRestTimeValues(exercise, -1); // Log overall exercise values

    return Column(
      key: ValueKey('exercise_${exercise.name}_$index'),
      children: [
        _buildExerciseHeader(exercise, index),
        _buildSetsList(exercise, index),
        _buildRestAfterExercise(exercise),
        _buildAddSetButton(index, exercise),
      ],
    );
  }

  Widget _buildExerciseHeader(Exercise exercise, int index) {
    return Row(
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
            _buildDeleteButton(index),
          ],
        ),
        _buildTimerButton(exercise),
      ],
    );
  }

  Widget _buildDeleteButton(int index) {
    if (!widget.isEditMode) return const SizedBox.shrink();

    return atsIconButton(
      size: 35,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      onPressed: () {
        setState(() {
          widget.workoutTemplate.exercises!.removeAt(index);
        });
      },
      icon: const Icon(Icons.delete),
    );
  }

  Widget _buildTimerButton(Exercise exercise) {
    if (!widget.isEditMode) return const SizedBox.shrink();

    final bool hasRestTime =
        exercise.restBetweenSets != null || exercise.restAfterSet != null;

    return atsIconButton(
      size: 35,
      backgroundColor: hasRestTime
          ? Theme.of(context).colorScheme.tertiaryFixed
          : Theme.of(context).colorScheme.errorContainer,
      foregroundColor: hasRestTime
          ? Colors.white
          : Theme.of(context).colorScheme.onErrorContainer,
      onPressed: () => _showRestTimeModal(exercise),
      icon: const Icon(Icons.timelapse_outlined),
    );
  }

  Widget _buildSetsList(Exercise exercise, int index) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int setIndex = -1;
            setIndex < widget.workoutTemplate.exercises![index].sets.length;
            setIndex += 1)
          _buildSetWithRest(exercise, index, setIndex),
      ],
    );
  }

  Widget _buildSetWithRest(Exercise exercise, int exerciseIndex, int setIndex) {
    return Column(
      children: [
        SetRow(
          isActiveWorkout: widget.isActiveWorkout,
          setIndex: setIndex,
          index: exerciseIndex,
          selectedExercises: widget.workoutTemplate.exercises!,
          refresh: () => setState(() {}),
          isEditable: true,
        ),
        _buildRestBetweenSets(exercise, setIndex),
      ],
    );
  }

  Widget _buildRestBetweenSets(Exercise exercise, int setIndex) {
    final bool isLastSet = setIndex >= exercise.sets.length - 1;
    final bool hasRestBetweenSets = exercise.restBetweenSets != null;

    if (setIndex < 0 || isLastSet || !hasRestBetweenSets) {
      return const SizedBox.shrink();
    }

    return StatefulBuilder(
      builder: (context, setStateLocal) {
        final set = exercise.sets[setIndex];
        final bool isTimerActive = set.completed ?? false;

        return Column(
          children: [
            _buildRestTimeLabel(
                exercise.restBetweenSets!, Icons.timer_outlined),
            _buildRestTimer(
              isActive: isTimerActive && widget.isActiveWorkout,
              exercise: exercise,
              duration: exercise.restBetweenSets!,
              isBetweenSets: true,
              setIndex: setIndex,
              setStateLocal: setStateLocal,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRestAfterExercise(Exercise exercise) {
    if (exercise.restAfterSet == null) return const SizedBox.shrink();

    return StatefulBuilder(
      builder: (context, setStateLocal) {
        final bool allSetsCompleted = exercise.sets.isNotEmpty &&
            exercise.sets.every((set) => set.completed == true);

        return Column(
          children: [
            _buildRestTimeLabel(exercise.restAfterSet!, Icons.timer,
                padding: 9),
            _buildRestTimer(
              isActive: allSetsCompleted && widget.isActiveWorkout,
              exercise: exercise,
              duration: exercise.restAfterSet!,
              isBetweenSets: false,
              setIndex: exercise.sets.length - 1,
              setStateLocal: setStateLocal,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRestTimeLabel(int duration, IconData icon,
      {double padding = 0}) {
    if (!widget.isEditMode) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, padding, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.tertiaryFixed,
          ),
          const SizedBox(width: 4),
          Text(
            _formatRestTimeSimple(duration),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiaryFixed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimer({
    required bool isActive,
    required Exercise exercise,
    required int duration,
    required bool isBetweenSets,
    required int setIndex,
    required StateSetter setStateLocal,
  }) {
    if (!isActive) return const SizedBox.shrink();

    return RestTimerWidget(
      restDuration: duration,
      exercise: exercise,
      isBetweenSets: isBetweenSets,
      setIndex: setIndex,
      onComplete: () {
        setStateLocal(() {
          widget.onChanged?.call();
        });
      },
    );
  }

  Widget _buildAddSetButton(int index, Exercise exercise) {
    return atsButton(
        onPressed: () => _addNewSet(index, exercise),
        child: const Text('add set'));
  }

  void _addNewSet(int index, Exercise exercise) {
    setState(() {
      RepSet? lastRepSet;
      if (widget.workoutTemplate.exercises![index].sets.isNotEmpty) {
        lastRepSet = widget.workoutTemplate.exercises![index].sets.last;
      }

      widget.workoutTemplate.exercises![index].sets.add(RepSet(
          reps: lastRepSet?.reps ?? 0,
          weight: lastRepSet?.weight ?? 0,
          note: null,
          restBetweenSets: exercise.restBetweenSets,
          restAfterSet: exercise.restAfterSet));
    });
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
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                      ),
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

                          widget.onChanged?.call();
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

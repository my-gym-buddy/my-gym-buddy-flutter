import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/widgets/set_row.dart';
import 'package:gym_buddy_app/screens/workouts/modals/rest_timer_settings_modal.dart';
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
    final bool hasRestAfterSet = exercise.restAfterSet != null;

    // Skip if this is header row or if no rest time is configured
    if (setIndex < 0 ||
        (!hasRestBetweenSets && !(isLastSet && hasRestAfterSet))) {
      return const SizedBox.shrink();
    }

    // For last set, either show nothing (if rest after exercise will handle it)
    // or show the between sets rest timer
    if (isLastSet && hasRestAfterSet) {
      return const SizedBox.shrink();
    }

    return StatefulBuilder(
      builder: (context, setStateLocal) {
        final set = exercise.sets[setIndex];
        final bool isTimerActive = set.completed;

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
        // Check if the last set is completed (not necessarily all sets)
        final bool lastSetCompleted =
            exercise.sets.isNotEmpty && (exercise.sets.last.completed);

        return Column(
          children: [
            _buildRestTimeLabel(exercise.restAfterSet!, Icons.timer,
                padding: 9),
            _buildRestTimer(
              isActive: lastSetCompleted && widget.isActiveWorkout,
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
    RestTimerSettingsModal.show(
      context,
      exercise: exercise,
      onRestTimeUpdated: (updatedExercise) {
        setState(() {
          widget.onChanged?.call();
        });
      },
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/workout.dart';

/// Model class for set row functionality that can be shared between different widget implementations.
class SetRowModel {
  final List<Exercise> selectedExercises;
  final int setIndex;
  final int index;
  final bool? isEditable;
  final Function? refresh;
  final bool? isActiveWorkout;

  SetRowModel({
    required this.selectedExercises,
    required this.setIndex,
    required this.index,
    required this.isEditable,
    required this.refresh,
    this.isActiveWorkout = false,
  });

  String getPreviousWeight() {
    // Safely check if the index is valid
    if (index >= selectedExercises.length) return "-";

    if (selectedExercises[index].previousSets == null) return "-";

    if (setIndex > selectedExercises[index].previousSets!.length - 1) {
      return '-';
    } else {
      return '${Helper.getWeightInCorrectUnit(selectedExercises[index].previousSets![setIndex].weight).toStringAsFixed(1)}${Config.getUnitAbbreviation()} x ${selectedExercises[index].previousSets![setIndex].reps}';
    }
  }

  // Copy values from previous set
  void copyFromPreviousSet() {
    if (!hasPreviousSet()) return;

    selectedExercises[index].sets[setIndex].weight =
        selectedExercises[index].previousSets![setIndex].weight;
    selectedExercises[index].sets[setIndex].reps =
        selectedExercises[index].previousSets![setIndex].reps;
    refresh!();
  }

  // Check if previous set data is available
  bool hasPreviousSet() {
    if (selectedExercises[index].previousSets == null) return false;
    if (setIndex > selectedExercises[index].previousSets!.length - 1) {
      return false;
    }
    return true;
  }

  // Check if indices are valid
  bool areIndicesValid() {
    if (index >= selectedExercises.length) return false;
    if (setIndex >= selectedExercises[index].sets.length) return false;
    return true;
  }

  // Create a workout object for saving
  Workout createWorkout() {
    return Workout(
      name:
          selectedExercises.isNotEmpty ? selectedExercises[0].name : "Workout",
      id: "temp_workout",
      exercises: selectedExercises,
      startTime: DateTime.now(),
    );
  }

  // Log workout debug info
  void logWorkoutDebugInfo(Workout workout) {
    if (!kDebugMode) return;

    print('Saving workout with ${selectedExercises.length} exercises');
    for (var ex in selectedExercises) {
      print('Exercise: ${ex.name} with ${ex.sets.length} sets');
      for (var set in ex.sets) {
        print(
            '  Set: ${set.reps} reps, ${set.weight} kg, completed: ${set.completed}');
      }
    }
  }

  // Save the workout to database
  void saveWorkout(Workout workout) {
    // Calculate workout duration
    int workoutDuration = 0;
    if (workout.startTime != null) {
      workoutDuration = DateTime.now().difference(workout.startTime!).inSeconds;
    }

    // Save to temporary storage
    DatabaseHelper.saveTemporaryWorkout(workout, workoutDuration)
        .then((success) {
      if (kDebugMode) {
        print(
            'Temporary workout saved: $success with duration: ${workoutDuration}s');
      }
    });
  }
  
  // Handle checkbox state changes
  void handleCheckboxChanged(bool value) {
    if (!areIndicesValid()) return;
    
    selectedExercises[index].sets[setIndex].completed = value;
    refresh!();

    if (isActiveWorkout == true) {
      final workout = createWorkout();
      logWorkoutDebugInfo(workout);
      saveWorkout(workout);
    }
  }
  
  // Update weight value
  void updateWeight(String value) {
    selectedExercises[index].sets[setIndex].weight =
        Helper.convertToKg(double.tryParse(value) ?? 0);
  }
  
  // Update reps value
  void updateReps(String value) {
    selectedExercises[index].sets[setIndex].reps =
        int.tryParse(value) ?? 0;
  }
}

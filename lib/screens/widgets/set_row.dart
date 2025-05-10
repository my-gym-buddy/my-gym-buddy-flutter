import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Add this import
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_checkbox.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';

class SetRow extends StatelessWidget {
  const SetRow(
      {super.key,
      required this.setIndex,
      required this.index,
      required this.selectedExercises,
      required this.isEditable,
      required this.refresh,
      this.isActiveWorkout = false});

  final bool? isEditable;
  final Function? refresh;

  final bool? isActiveWorkout;
  final int setIndex;
  final int index;

  final List<Exercise> selectedExercises;
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

  @override
  Widget build(BuildContext context) {
    // Handle header row case
    if (setIndex == -1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: Center(child: Text('set'))),
          const Expanded(flex: 4, child: Center(child: Text('previous'))),
          Expanded(
              flex: 4,
              child: Center(child: Text('+${Config.getUnitAbbreviation()}'))),
          const Expanded(flex: 4, child: Center(child: Text('reps'))),
          const Expanded(flex: 2, child: Center(child: Text(''))),
        ],
      );
    }

    // Handle editable set row with Slidable
    if (isEditable != null) {
      return Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                selectedExercises[index].sets.removeAt(setIndex);
                refresh!();
              },
              borderRadius: BorderRadius.circular(40),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: _buildSetRow(context),
      );
    }

    // Handle non-editable set row
    return _buildSetRow(context);
  }
  // Method to copy values from previous set
  void _copyFromPreviousSet() {
    if (!_isPreviousSetAvailable()) return;
    
    selectedExercises[index].sets[setIndex].weight =
        selectedExercises[index].previousSets![setIndex].weight;
    selectedExercises[index].sets[setIndex].reps =
        selectedExercises[index].previousSets![setIndex].reps;
    refresh!();
  }

  // Check if previous set exists and is available
  bool _isPreviousSetAvailable() {
    if (selectedExercises[index].previousSets == null) return false;
    if (setIndex > selectedExercises[index].previousSets!.length - 1) return false;
    return true;
  }

  // Build the set number cell
  Widget _buildSetNumberCell() {
    return Expanded(child: Center(child: Text('${setIndex + 1}')));
  }

  // Build the previous weight cell with gesture detector
  Widget _buildPreviousWeightCell() {
    return Expanded(
      flex: 4,
      child: Center(
        child: GestureDetector(
          onTap: _copyFromPreviousSet,
          child: Text(getPreviousWeight()),
        ),
      ),
    );
  }

  // Build the weight input field
  Widget _buildWeightInputField() {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 30,
          child: atsTextField(
            selectAllOnTap: true,
            textEditingController: TextEditingController(
              text: Helper.getWeightInCorrectUnit(
                selectedExercises[index].sets[setIndex].weight
              ).toStringAsFixed(1),
            ),
            textAlign: TextAlign.center,
            labelText: '',
            keyboardType: TextInputType.number,
            enabled: isEditable != null,
            onChanged: (value) {
              selectedExercises[index].sets[setIndex].weight =
                  Helper.convertToKg(double.tryParse(value) ?? 0);
            },
          ),
        ),
      ),
    );
  }

  // Build the reps input field
  Widget _buildRepsInputField() {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 30,
          child: atsTextField(
            selectAllOnTap: true,
            textEditingController: TextEditingController(
              text: selectedExercises[index].sets[setIndex].reps.toString()
            ),
            textAlign: TextAlign.center,
            labelText: '',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              selectedExercises[index].sets[setIndex].reps =
                  int.tryParse(value) ?? 0;
            },
            enabled: isEditable != null,
          ),
        ),
      ),
    );
  }

  // Create workout object for saving
  Workout _createTemporaryWorkout() {
    return Workout(
      name: selectedExercises.isNotEmpty ? selectedExercises[0].name : "Workout",
      id: "temp_workout",
      exercises: selectedExercises,
      startTime: null,
    );
  }

  // Debug log workout details
  void _logWorkoutDebugInfo() {
    if (!kDebugMode) return;
    
    print('Saving workout with ${selectedExercises.length} exercises');
    for (var ex in selectedExercises) {
      print('Exercise: ${ex.name} with ${ex.sets.length} sets');
      for (var set in ex.sets) {
        print('  Set: ${set.reps} reps, ${set.weight} kg, completed: ${set.completed}');
      }
    }
  }

  // Apply start time to workout from existing or create new
  void _applyWorkoutStartTime(Workout currentWorkout, Workout? existingWorkout) {
    if (existingWorkout != null && existingWorkout.startTime != null) {
      currentWorkout.startTime = existingWorkout.startTime;
      if (kDebugMode) {
        print('Using existing start time: ${currentWorkout.startTime}');
      }
    } else {
      currentWorkout.startTime = DateTime.now();
      if (kDebugMode) {
        print('Setting new start time: ${currentWorkout.startTime}');
      }
    }
  }

  // Calculate workout duration in seconds
  int _calculateWorkoutDuration(Workout workout) {
    if (workout.startTime == null) return 0;
    return DateTime.now().difference(workout.startTime!).inSeconds;
  }

  // Save workout to temporary storage
  void _saveWorkoutToTemporaryStorage(Workout workout, int duration) {
    DatabaseHelper.saveTemporaryWorkout(workout, duration).then((success) {
      if (kDebugMode) {
        print('Temporary workout saved: $success with duration: ${duration}s');
      }
    });
  }

  // Handle checkbox state change
  void _handleCheckboxChanged(bool value) {
    if (!_isValidSetIndex()) return;
    
    selectedExercises[index].sets[setIndex].completed = value;
    refresh!();
    
    if (isActiveWorkout == true && selectedExercises.isNotEmpty) {
      _saveActiveWorkout();
    }
  }

  // Check if index and setIndex are valid
  bool _isValidSetIndex() {
    return index < selectedExercises.length && 
           setIndex < selectedExercises[index].sets.length;
  }

  // Save active workout
  void _saveActiveWorkout() {
    final currentWorkout = _createTemporaryWorkout();
    _logWorkoutDebugInfo();
    
    DatabaseHelper.getTemporaryWorkout().then((existingWorkout) {
      _applyWorkoutStartTime(currentWorkout, existingWorkout);
      
      final workoutDuration = _calculateWorkoutDuration(currentWorkout);
      _saveWorkoutToTemporaryStorage(currentWorkout, workoutDuration);
    });
  }

  // Build the checkbox cell
  Widget _buildCompletionCheckbox() {
    if (isActiveWorkout != true) return const SizedBox();
    
    return atsCheckbox(
      checked: _isValidSetIndex() 
          ? selectedExercises[index].sets[setIndex].completed
          : false,
      onChanged: _handleCheckboxChanged,
    );
  }

  // Main method to build the row
  Widget _buildSetRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSetNumberCell(),
        _buildPreviousWeightCell(),
        _buildWeightInputField(),
        _buildRepsInputField(),
        Expanded(flex: 2, child: _buildCompletionCheckbox()),
      ],
    );
  }
}

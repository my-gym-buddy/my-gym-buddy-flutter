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

    // Safety check for invalid index
    if (index >= selectedExercises.length) {
      return const SizedBox(); // Return empty widget if index is invalid
    }

    // Handle editable set row with Slidable
    if (isEditable != null) {
      return Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                // Safety check before removing
                if (index < selectedExercises.length &&
                    setIndex < selectedExercises[index].sets.length) {
                  selectedExercises[index].sets.removeAt(setIndex);
                  refresh!();
                }
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

  // Copy values from previous set
  void _copyFromPreviousSet() {
    if (!_hasPreviousSet()) return;

    selectedExercises[index].sets[setIndex].weight =
        selectedExercises[index].previousSets![setIndex].weight;
    selectedExercises[index].sets[setIndex].reps =
        selectedExercises[index].previousSets![setIndex].reps;
    refresh!();
  }

  // Check if previous set data is available
  bool _hasPreviousSet() {
    if (selectedExercises[index].previousSets == null) return false;
    if (setIndex > selectedExercises[index].previousSets!.length - 1) {
      return false;
    }
    return true;
  }

  // Check if indices are valid
  bool _areIndicesValid() {
    if (index >= selectedExercises.length) return false;
    if (setIndex >= selectedExercises[index].sets.length) return false;
    return true;
  }

  // Build set number cell
  Widget _buildSetNumberCell() {
    return Expanded(child: Center(child: Text('${setIndex + 1}')));
  }

  // Build previous weight cell
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

  // Build weight input field
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
                        selectedExercises[index].sets[setIndex].weight)
                    .toStringAsFixed(1)),
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

  // Build reps input field
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
                text: selectedExercises[index].sets[setIndex].reps.toString()),
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

  // Create a workout object for saving
  Workout _createWorkout() {
    return Workout(
      name:
          selectedExercises.isNotEmpty ? selectedExercises[0].name : "Workout",
      id: "temp_workout",
      exercises: selectedExercises,
      startTime: DateTime.now(),
    );
  }

  // Log workout debug info
  void _logWorkoutDebugInfo(Workout workout) {
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
  void _saveWorkout(Workout workout) {
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
  void _handleCheckboxChanged(bool value) {
    selectedExercises[index].sets[setIndex].completed = value;
    refresh!();

    if (isActiveWorkout == true) {
      final workout = _createWorkout();
      _logWorkoutDebugInfo(workout);
      _saveWorkout(workout);
    }
  }

  // Build the completion checkbox
  Widget _buildCompletionCheckbox() {
    if (isActiveWorkout != true) return const SizedBox();

    return atsCheckbox(
      checked: selectedExercises[index].sets[setIndex].completed,
      onChanged: _handleCheckboxChanged,
    );
  }

  // Extract the row content to a separate method
  Widget _buildSetRow(BuildContext context) {
    // Safety check for invalid indices
    if (!_areIndicesValid()) {
      return const SizedBox();
    }

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

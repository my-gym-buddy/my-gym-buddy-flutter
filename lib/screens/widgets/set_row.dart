import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Add this import
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_checkbox.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';

class SetRow extends StatelessWidget {
  SetRow(
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

  List<Exercise> selectedExercises;

  String getPreviousWeight() {
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
              child:
                  Center(child: Text('+${Config.getUnitAbbreviation()}'))),
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
              backgroundColor:
                  Theme.of(context).colorScheme.errorContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onErrorContainer,
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

  // Extract the row content to a separate method
  Widget _buildSetRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Center(child: Text('${setIndex + 1}'))),
        Expanded(
            flex: 4,
            child: Center(
                child: GestureDetector(
                    onTap: () {
                      if (selectedExercises[index].previousSets == null) {
                        return;
                      }
                      if (setIndex >
                          selectedExercises[index].previousSets!.length - 1) {
                        return;
                      }
                      selectedExercises[index].sets[setIndex].weight =
                          selectedExercises[index]
                              .previousSets![setIndex]
                              .weight;
                      selectedExercises[index].sets[setIndex].reps =
                          selectedExercises[index].previousSets![setIndex].reps;
                      refresh!();
                    },
                    child: Text(getPreviousWeight())))),
        Expanded(
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
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 30,
              child: atsTextField(
                selectAllOnTap: true,
                textEditingController: TextEditingController(
                    text: selectedExercises[index]
                        .sets[setIndex]
                        .reps
                        .toString()),
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
        ),
        Expanded(
          flex: 2,
          child: isActiveWorkout == true
              ? atsCheckbox(
                  checked: selectedExercises[index].sets[setIndex].completed,
                  onChanged: (value) {
                    selectedExercises[index].sets[setIndex].completed = value;
                    refresh!();
                  },
                )
              : const SizedBox(),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
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
    print(selectedExercises[index].previousSets);

    if (selectedExercises[index].previousSets == null) return "-";

    if (setIndex > selectedExercises[index].previousSets!.length - 1) {
      return '-';
    } else {
      return '${selectedExercises[index].previousSets![setIndex].weight}kg x ${selectedExercises[index].previousSets![setIndex].reps}';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('set row build called');
    return setIndex == -1
        ? const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Center(child: Text('set'))),
              Expanded(flex: 4, child: Center(child: Text('previous'))),
              Expanded(flex: 4, child: Center(child: Text('+kgs'))),
              Expanded(flex: 4, child: Center(child: Text('reps'))),
              Expanded(flex: 2, child: Center(child: Text(''))),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Center(child: Text('${setIndex + 1}'))),
              Expanded(
                  flex: 4, child: Center(child: Text(getPreviousWeight()))),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 30,
                    child: atsTextField(
                      textEditingController: TextEditingController(
                          text: selectedExercises[index]
                              .sets[setIndex]
                              .weight
                              .toString()),
                      textAlign: TextAlign.center,
                      labelText: '',
                      keyboardType: TextInputType.number,
                      enabled: isEditable != null,
                      onChanged: (value) {
                        selectedExercises[index].sets[setIndex].weight =
                            double.parse(value);
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
                            int.parse(value);
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
                        checked:
                            selectedExercises[index].sets[setIndex].completed,
                        onChanged: (value) {
                          selectedExercises[index].sets[setIndex].completed =
                              value;
                          refresh!();
                        },
                        onHold: isEditable != null
                            ? () {
                                selectedExercises[index]
                                    .sets
                                    .removeAt(setIndex);
                                refresh!();
                              }
                            : null,
                      )
                    : atsIconButton(
                        size: 35,
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onErrorContainer,
                        onPressed: isEditable != null
                            ? () {
                                selectedExercises[index]
                                    .sets
                                    .removeAt(setIndex);
                                refresh!();
                              }
                            : null,
                        icon: const Icon(Icons.delete),
                      ),
              )
            ],
          );
  }
}

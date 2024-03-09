import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';

class SetRow extends StatelessWidget {
  SetRow(
      {super.key,
      required this.setIndex,
      required this.index,
      required this.selectedExercises,
      required this.refresh});

  final Function? refresh;

  final int setIndex;
  final int index;

  List<Exercise> selectedExercises;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Center(child: Text('${setIndex + 1}'))),
        Expanded(flex: 4, child: Center(child: Text('999kg x 999'))),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 30,
              child: atsTextField(
                textAlign: TextAlign.center,
                labelText: '',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  selectedExercises[index].sets[setIndex].reps =
                      int.parse(value);
                  refresh!();
                },
                enabled: refresh != null,
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
                textAlign: TextAlign.center,
                labelText: '',
                keyboardType: TextInputType.number,
                enabled: refresh != null,
                onChanged: (value) {
                  selectedExercises[index].sets[setIndex].weight =
                      double.parse(value);
                  refresh!();
                },
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: atsIconButton(
            size: 35,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            onPressed: refresh != null
                ? () {
                    selectedExercises[index].sets.removeAt(setIndex);
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

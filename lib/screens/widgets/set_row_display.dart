import 'package:flutter/material.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';

class SetRowDisplay extends StatelessWidget {
  SetRowDisplay(
      {super.key,
      required this.setIndex,
      required this.index,
      required this.selectedExercises});

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Center(child: Text('${setIndex + 1}'))),
        Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text(getPreviousWeight())),
            )),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                '${Helper.getWeightInCorrectUnit(selectedExercises[index].sets[setIndex].weight).toStringAsFixed(1)} ${Config.getUnitAbbreviation()}'),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${selectedExercises[index].sets[setIndex].reps} reps'),
          ),
        ),
      ],
    );
  }
}

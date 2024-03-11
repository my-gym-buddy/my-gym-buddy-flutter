import 'package:flutter/material.dart';
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
      return '${selectedExercises[index].previousSets![setIndex].weight}kg x ${selectedExercises[index].previousSets![setIndex].reps}';
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
            child: Text('${selectedExercises[index].sets[setIndex].weight} kg'),
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

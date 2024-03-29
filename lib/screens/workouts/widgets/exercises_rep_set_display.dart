import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/widgets/set_row.dart';

class ExercisesRepSetDisplay extends StatefulWidget {
  ExercisesRepSetDisplay(
      {super.key,
      required this.workoutTemplate,
      this.physics = const ScrollPhysics(),
      this.isActiveWorkout = false});

  Workout workoutTemplate;

  bool isActiveWorkout;

  ScrollPhysics physics;

  @override
  State<ExercisesRepSetDisplay> createState() => _ExercisesRepSetDisplayState();
}

class _ExercisesRepSetDisplayState extends State<ExercisesRepSetDisplay> {
  @override
  Widget build(BuildContext context) {
    return widget.workoutTemplate.exercises == null
        ? const Center(
            child: Text('No exercises added'),
          )
        : ReorderableListView(
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
                Column(
                  key: ValueKey(widget.workoutTemplate.exercises![index].name +
                      (Random().nextInt(10000)).toString()),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.workoutTemplate.exercises![index].name
                              .toLowerCase(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        atsIconButton(
                          size: 35,
                          backgroundColor:
                              Theme.of(context).colorScheme.errorContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onErrorContainer,
                          onPressed: () {
                            setState(() {
                              widget.workoutTemplate.exercises!.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.delete),
                        )
                      ],
                    ),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (int setIndex = -1;
                            setIndex <
                                widget.workoutTemplate.exercises![index].sets
                                    .length;
                            setIndex += 1)
                          SetRow(
                              isActiveWorkout: widget.isActiveWorkout,
                              setIndex: setIndex,
                              index: index,
                              selectedExercises:
                                  widget.workoutTemplate.exercises!,
                              refresh: () {
                                setState(() {});
                              },
                              isEditable: true),
                      ],
                    ),
                    atsButton(
                        onPressed: () {
                          RepSet? lastRepSet;

                          if (widget.workoutTemplate.exercises![index].sets
                              .isNotEmpty) {
                            lastRepSet = widget
                                .workoutTemplate.exercises![index].sets.last;
                          }

                          setState(() {
                            widget.workoutTemplate.exercises![index].sets.add(
                                RepSet(
                                    reps: lastRepSet != null
                                        ? lastRepSet.reps
                                        : 0,
                                    weight: lastRepSet != null
                                        ? lastRepSet.weight
                                        : 0,
                                    note: null));
                          });
                        },
                        child: const Text('add set')),
                  ],
                ),
            ],
          );
  }
}

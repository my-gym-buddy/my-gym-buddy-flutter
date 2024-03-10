import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';
import 'package:gym_buddy_app/screens/widgets/set_row.dart';
import 'package:search_page/search_page.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  List<Exercise> exercises = [];
  List<Exercise> selectedExercises = [];
  TextEditingController workoutNameTextController = TextEditingController();
  TextEditingController workoutDescriptionTextController =
      TextEditingController();

  Workout workout = Workout('');

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper.getExercises().then((value) {
      setState(() {
        exercises = value;
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('add workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            atsTextField(
              textEditingController: workoutNameTextController,
              labelText: 'workout name',
            ),
            const SizedBox(height: 15),
            atsTextField(
              textEditingController: workoutDescriptionTextController,
              labelText: 'description',
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ReorderableListView(
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final Exercise item = selectedExercises.removeAt(oldIndex);
                    selectedExercises.insert(newIndex, item);
                  });
                },
                children: <Widget>[
                  for (int index = 0;
                      index < selectedExercises.length;
                      index += 1)
                    Column(
                      key: ValueKey(selectedExercises[index]),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              selectedExercises[index].name.toLowerCase(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            atsIconButton(
                              size: 35,
                              backgroundColor:
                                  Theme.of(context).colorScheme.errorContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                              onPressed: () {
                                setState(() {
                                  selectedExercises.removeAt(index);
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
                                setIndex < selectedExercises[index].sets.length;
                                setIndex += 1)
                              if (setIndex == -1)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Center(child: Text('set'))),
                                    Expanded(
                                        flex: 4,
                                        child: Center(child: Text('previous'))),
                                    Expanded(
                                        flex: 4,
                                        child: Center(child: Text('reps'))),
                                    Expanded(
                                        flex: 4,
                                        child: Center(child: Text('weight'))),
                                    Expanded(
                                        flex: 2,
                                        child: Center(child: Text(''))),
                                  ],
                                )
                              else
                                SetRow(
                                    setIndex: setIndex,
                                    index: index,
                                    selectedExercises: selectedExercises,
                                    refresh: refresh),
                          ],
                        ),
                        atsButton(
                            onPressed: () {
                              setState(() {
                                selectedExercises[index].sets.add(
                                    RepSet(reps: 0, weight: 0, note: null));
                              });
                            },
                            child: const Text('add set')),
                      ],
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                atsButton(
                    onPressed: () => showSearch(
                        context: context,
                        delegate: SearchPage<Exercise>(
                            showItemsOnEmpty: true,
                            items: exercises,
                            searchLabel: 'search exercises',
                            failure: const Center(
                              child: Text('no exercises found'),
                            ),
                            filter: (exercise) => [
                                  exercise.name,
                                ],
                            builder: (exercise) => ListTile(
                                  title: Text(exercise.name.toLowerCase()),
                                  onTap: () {
                                    setState(() {
                                      selectedExercises.add(exercise);
                                    });
                                    Navigator.pop(context);
                                  },
                                ))),
                    child: const Text('add exercise')),
                SizedBox(
                  width: 10,
                ),
                atsButton(
                  onPressed: () async {
                    workout.exercises = selectedExercises;
                    workout.name = workoutNameTextController.text;
                    await DatabaseHelper.saveWorkout(workout);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout added'),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('save'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
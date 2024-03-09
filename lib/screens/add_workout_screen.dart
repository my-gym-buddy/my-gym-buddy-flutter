import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/database_helper.dart';
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Workout'),
        actions: [
          ElevatedButton(
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
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: workoutNameTextController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Workout Name',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => showSearch(
                    context: context,
                    delegate: SearchPage<Exercise>(
                        showItemsOnEmpty: true,
                        items: exercises,
                        searchLabel: 'Search Exercises',
                        failure: const Center(
                          child: Text('No exercises found :('),
                        ),
                        filter: (exercise) => [
                              exercise.name,
                            ],
                        builder: (exercise) => ListTile(
                              title: Text(exercise.name),
                              onTap: () {
                                setState(() {
                                  selectedExercises.add(exercise);
                                });
                                Navigator.pop(context);
                              },
                            ))),
                child: const Text('Add Exercise')),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedExercises[index].name),
                            IconButton(
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
                                    Expanded(child: Center(child: Text('Set'))),
                                    Expanded(
                                        flex: 4,
                                        child: Center(child: Text('Previous'))),
                                    Expanded(
                                        flex: 4,
                                        child: Center(child: Text('Reps'))),
                                    Expanded(
                                        flex: 4,
                                        child: Center(child: Text('Weight'))),
                                    Expanded(child: Center(child: Text(''))),
                                  ],
                                )
                              else
                                SetRow(
                                    setIndex: setIndex,
                                    index: index,
                                    selectedExercises: selectedExercises,
                                    refresh: refresh)
                          ],
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                selectedExercises[index].sets.add(
                                    RepSet(reps: 0, weight: 0, note: null));
                              });
                            },
                            child: const Text('Add Set'))
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

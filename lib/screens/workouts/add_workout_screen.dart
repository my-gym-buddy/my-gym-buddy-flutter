import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';
import 'package:gym_buddy_app/screens/workouts/widgets/exercises_rep_set_display.dart';
import 'package:search_page/search_page.dart';

class AddWorkoutScreen extends StatefulWidget {
  AddWorkoutScreen({super.key, this.workout});

  Workout? workout;

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  List<Exercise> allExercises = [];
  TextEditingController workoutNameTextController = TextEditingController();
  TextEditingController workoutDescriptionTextController =
      TextEditingController();

  Workout workout = Workout(name: "", exercises: []);

  @override
  void initState() {
    super.initState();

    if (widget.workout != null) {
      workout = widget.workout!;
      workoutNameTextController.text = workout.name;
    }

    DatabaseHelper.getExercises().then((value) {
      setState(() {
        allExercises = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(child: ExercisesRepSetDisplay(workoutTemplate: workout)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.workout != null
                    ? atsButton(
                        onPressed: () async {
                          await DatabaseHelper.deleteWorkout(widget.workout!);
                          Navigator.pop(context);
                          return null;
                        },
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                        child: Text('delete',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer)),
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 10,
                ),
                atsButton(
                    onPressed: () => showSearch(
                        context: context,
                        delegate: SearchPage<Exercise>(
                            showItemsOnEmpty: true,
                            items: allExercises,
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
                                      workout.exercises!.add(
                                          Exercise.fromJson(exercise.toJson()));
                                    });
                                    Navigator.pop(context);
                                  },
                                ))),
                    child: const Text('add exercise')),
                const SizedBox(
                  width: 10,
                ),
                atsButton(
                  onPressed: () async {
                    workout.exercises = workout.exercises!;
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

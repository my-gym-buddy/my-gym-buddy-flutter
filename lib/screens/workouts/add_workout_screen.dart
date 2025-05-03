import 'package:flutter/material.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_checkbox.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';
import 'package:gym_buddy_app/screens/workouts/widgets/exercises_rep_set_display.dart';
import 'package:search_page/search_page.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_confirm_exit_showmodalbottom.dart';

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
  bool nameError = false;
  bool descriptionError = false;
  bool _hasChanges = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    if (widget.workout != null) {
      workout = widget.workout!;
      workoutNameTextController.text = workout.name;
      workoutDescriptionTextController.text = workout.description ?? "";
      workout.daysOfWeek = workout.daysOfWeek;
    }

    if (workout.daysOfWeek == null) {
      workout.daysOfWeek = Set();
    }

    DatabaseHelper.getExercises().then((value) {
      setState(() {
        allExercises = value;
      });
    });

    void markAsChanged() {
      if (!_hasChanges) setState(() => _hasChanges = true);
    }

    workoutNameTextController.addListener(markAsChanged);
    workoutDescriptionTextController.addListener(markAsChanged);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges || _isSubmitting,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (!mounted) return;
        final shouldPop = await atsConfirmExitDialog(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.workout != null ? 'edit workout' : 'add workout'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (!_hasChanges || await atsConfirmExitDialog(context)) {
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                atsTextField(
                  textEditingController: workoutNameTextController,
                  labelText: 'workout name',
                  error: nameError,
                  onChanged: (value) {
                    setState(() {
                      nameError = value.trim().isEmpty;
                    });
                  },
                ),
                const SizedBox(height: 15),
                atsTextField(
                  textEditingController: workoutDescriptionTextController,
                  labelText: 'description',
                  error: descriptionError,
                  onChanged: (value) {
                    setState(() {
                      descriptionError = value.trim().isEmpty;
                    });
                  },
                ),
                const SizedBox(height: 15),
                Text('days of the week',
                    style: Theme.of(context).textTheme.titleMedium),

                // horizontal scrollable list of days of the week
                SizedBox(
                  height: 50,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var day in Helper.daysInWeek.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: atsCheckbox(
                                width: 100,
                                height: 40,
                                checked: workout.daysOfWeek!.contains(
                                    Helper.daysInWeek.keys.firstWhere((key) =>
                                        Helper.daysInWeek[key] == day)),
                                onChanged: (value) {
                                  setState(() {
                                    int dayIndex = Helper.daysInWeek.keys
                                        .firstWhere((key) =>
                                            Helper.daysInWeek[key] == day);
                                    if (value) {
                                      workout.daysOfWeek!.add(dayIndex);
                                    } else {
                                      workout.daysOfWeek!.remove(dayIndex);
                                    }
                                  });
                                },
                                child: Center(child: Text(day))),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ExercisesRepSetDisplay(workoutTemplate: workout),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.workout != null
                        ? atsButton(
                            onPressed: () async {
                              await DatabaseHelper.deleteWorkout(
                                  widget.workout!);
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
                                              Exercise.fromJson(
                                                  exercise.toJson()));
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
                          setState(() => _isSubmitting = true);
                          setState(() {
                            nameError =
                                workoutNameTextController.text.trim().isEmpty;
                            descriptionError = workoutDescriptionTextController
                                .text
                                .trim()
                                .isEmpty;
                          });

                          if (nameError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('please enter a workout name'),
                              ),
                            );
                            return;
                          }

                          if (descriptionError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('please enter a description'),
                              ),
                            );
                            return;
                          }

                          if (workout.daysOfWeek == null ||
                              workout.daysOfWeek!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'please select at least one day of the week'),
                              ),
                            );
                            return;
                          }

                          workout.exercises = workout.exercises!;
                          workout.name = workoutNameTextController.text.trim();
                          workout.description =
                              workoutDescriptionTextController.text.trim();

                          widget.workout != null
                              ? DatabaseHelper.updateWorkout(workout)
                              : await DatabaseHelper.saveWorkout(workout);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(widget.workout != null
                                  ? 'workout updated'
                                  : 'workout added'),
                            ),
                          );
                          Navigator.pop(context, widget.workout);
                        },
                        child: const Text("save")),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

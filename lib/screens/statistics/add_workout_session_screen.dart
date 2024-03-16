import 'package:flutter/material.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';
import 'package:gym_buddy_app/screens/workouts/widgets/exercises_rep_set_display.dart';
import 'package:search_page/search_page.dart';

class AddWorkoutSessionScreen extends StatefulWidget {
  AddWorkoutSessionScreen({super.key, this.workout});

  Workout? workout;

  @override
  State<AddWorkoutSessionScreen> createState() =>
      _AddWorkoutSessionScreenState();
}

class _AddWorkoutSessionScreenState extends State<AddWorkoutSessionScreen> {
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
      workoutDescriptionTextController.text = workout.description ?? '';
    } else {
      workout.startTime = DateTime.now();
      workout.duration = 0;
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
        title: Text(widget.workout != null ? 'edit session' : 'add session'),
        leading: atsIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, widget.workout);
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
              ),
              const SizedBox(height: 15),
              atsTextField(
                textEditingController: workoutDescriptionTextController,
                labelText: 'description',
              ),
              const SizedBox(height: 15),
              atsButton(
                  child: Text(
                      'choose duration (${Helper.prettyTime(workout.duration!)})'),
                  onPressed: () {
                    showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: workout.duration! ~/ 3600,
                          minute: (workout.duration! % 3600) ~/ 60),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          workout.duration =
                              value.hour * 3600 + value.minute * 60;
                        });
                      }
                    });
                  }),
              const SizedBox(height: 10),
              atsButton(
                  child: Text(
                      'choose start date  (${workout.startTime!.toIso8601String().split('T')[0]})'),
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: workout.startTime!,
                      firstDate: DateTime(2015),
                      lastDate: DateTime(2101),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          workout.startTime = DateTime(
                              value.year,
                              value.month,
                              value.day,
                              workout.startTime!.hour,
                              workout.startTime!.minute);
                        });
                      }
                    });
                  }),
              const SizedBox(height: 10),
              atsButton(
                  child: Text(
                      'choose start time  (${workout.startTime!.toIso8601String().split('T')[1].split('.')[0]})'),
                  onPressed: () {
                    showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: workout.startTime!.hour,
                          minute: workout.startTime!.minute),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          workout.startTime = DateTime(
                              workout.startTime!.year,
                              workout.startTime!.month,
                              workout.startTime!.day,
                              value.hour,
                              value.minute);
                        });
                      }
                    });
                  }),
              const SizedBox(height: 20),
              ExercisesRepSetDisplay(workoutTemplate: workout),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  widget.workout != null
                      ? atsButton(
                          onPressed: () async {
                            await DatabaseHelper.deleteWorkoutSession(
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
                        workout.exercises = workout.exercises!;
                        workout.name = workoutNameTextController.text;
                        workout.description =
                            workoutDescriptionTextController.text;

                        widget.workout != null
                            ? DatabaseHelper.updateWorkoutSession(workout)
                            : await DatabaseHelper.saveWorkoutSession(
                                workout, workout.duration!);

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
    );
  }
}

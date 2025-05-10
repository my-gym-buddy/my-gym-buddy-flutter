import 'package:flutter/material.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/statistics/add_workout_session_screen.dart';
import 'package:gym_buddy_app/screens/widgets/set_row_display.dart';

class SingleWorkoutStatsisticsScreen extends StatefulWidget {
  SingleWorkoutStatsisticsScreen({super.key, required this.workout});

  Workout workout;

  @override
  State<SingleWorkoutStatsisticsScreen> createState() =>
      _SingleWorkoutStatsisticsScreenState();
}

class _SingleWorkoutStatsisticsScreenState
    extends State<SingleWorkoutStatsisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: atsButton(
          child: const Text('share'),
          onPressed: () async {
            Helper.shareWorkoutSummary(
                widget.workout, widget.workout.duration!);
          }),
      appBar: AppBar(
        title: Text(widget.workout.name),
        leading: atsIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: atsIconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  var editedWorkout = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddWorkoutSessionScreen(
                                workout: widget.workout,
                              )));

                  if (editedWorkout != null) {
                    setState(() {
                      widget.workout = editedWorkout;
                    });
                  } else {
                    if (context.mounted) {
                    Navigator.pop(context);
                    }
                  }
                }),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('notes: ${widget.workout.description}'),
              Text('date: ${widget.workout.startTime}'),
              Text('duration: ${Helper.prettyTime(widget.workout.duration!)}'),
              Text(
                  'total weight lifted: ${Helper.getWeightInCorrectUnit(Helper.calculateTotalWeightLifted(widget.workout)).toStringAsFixed(2)} ${Config.getUnitAbbreviation()}'),
              const SizedBox(
                height: 20,
              ),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.workout.exercises!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        title: Text(widget.workout.exercises![index].name),
                        subtitle: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              widget.workout.exercises![index].sets.length,
                          itemBuilder: (context, setIndex) {
                            return SetRowDisplay(
                              setIndex: setIndex,
                              index: index,
                              selectedExercises: widget.workout.exercises!,
                            );
                          },
                        ));
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

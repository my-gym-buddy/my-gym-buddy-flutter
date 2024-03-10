import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/workouts/widgets/exercises_rep_set_display.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class ActiveWorkout extends StatefulWidget {
  ActiveWorkout({super.key, required this.workoutTemplate});

  final Workout workoutTemplate;

  final stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);

  String displayTime = "";

  @override
  State<ActiveWorkout> createState() => _ActiveWorkoutState();
}

class _ActiveWorkoutState extends State<ActiveWorkout> {
  @override
  void initState() {
    super.initState();
    widget.stopWatchTimer.onStartTimer();
  }

  @override
  void dispose() async {
    super.dispose();
    await widget.stopWatchTimer.dispose(); // Need to call dispose function.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutTemplate.name),
        leading: atsIconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.stopWatchTimer.onStartTimer();
              Navigator.pop(context);
            }),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: atsButton(
                child: StreamBuilder<int>(
                  stream: widget.stopWatchTimer.rawTime,
                  initialData: 0,
                  builder: (context, snapshot) {
                    final value = snapshot.data;
                    final displayTime = StopWatchTimer.getDisplayTime(value!,
                        milliSecond: false);
                    return Text(displayTime);
                  },
                ),
                onPressed: () {}),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              ExercisesRepSetDisplay(
                  isActiveWorkout: true,
                  physics: const NeverScrollableScrollPhysics(),
                  workoutTemplate: widget.workoutTemplate),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  atsButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    child: Text('cancel workout',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer)),
                  ),
                  atsButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('finish workout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/exercises/add_exercise_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SingleExerciseScreen extends StatefulWidget {
  SingleExerciseScreen({super.key, required this.exercise});

  Exercise exercise;

  @override
  State<SingleExerciseScreen> createState() => _SingleExerciseScreenState();
}

class _SingleExerciseScreenState extends State<SingleExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.exercise.name.toLowerCase()),
          leading: atsIconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: atsIconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    Exercise? updatedExercise = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddExerciseScreen(exercise: widget.exercise)),
                    );

                    if (updatedExercise != null) {
                      setState(() {
                        widget.exercise = updatedExercise;
                      });
                    }
                  }),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                YoutubePlayer.convertUrlToId(widget.exercise.videoID ?? '') !=
                        null
                    ? YoutubePlayer(
                        controller: YoutubePlayerController(
                          initialVideoId: widget.exercise.videoID ?? '',
                          flags: const YoutubePlayerFlags(
                            autoPlay: true,
                            mute: true,
                          ),
                        ),
                      )
                    : Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('no video available'),
                        ),
                      ),
                const SizedBox(height: 20),
                Text(
                  'description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  widget.exercise.description ?? 'no description available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'no data available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ));
  }
}

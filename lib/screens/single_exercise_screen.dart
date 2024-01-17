import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.exercise.name),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              YoutubePlayer(
                controller: YoutubePlayerController(
                  initialVideoId: widget.exercise.videoID ?? '',
                  flags: YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

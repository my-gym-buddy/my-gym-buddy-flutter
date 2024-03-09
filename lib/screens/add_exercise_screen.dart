import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'TywmpMQYojs',
    flags: YoutubePlayerFlags(
      hideControls: true,
      loop: true,
      autoPlay: true,
      mute: false,
    ),
  );

  TextEditingController exerciseNameTextController = TextEditingController();
  TextEditingController videoIDTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Add Exercise'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: exerciseNameTextController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Exercise Name',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: videoIDTextController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Youtube Video URL or ID',
                ),
              ),
              Text('Video ID: ${_controller.metadata.videoId}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  var videoID =
                      YoutubePlayer.convertUrlToId(videoIDTextController.text);

                  _controller.load(videoID ?? 'INVALID_ID');

                  DatabaseHelper.saveExercise(Exercise(
                          name: exerciseNameTextController.text,
                          videoID: videoID))
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exercise saved!'),
                      ),
                    );
                  });
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ));
  }
}

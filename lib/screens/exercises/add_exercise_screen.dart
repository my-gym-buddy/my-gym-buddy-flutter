import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key, this.exercise});

  final Exercise? exercise;

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  bool validURL = false;

  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'YJXkSFOVZZw',
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
          title:
              Text(widget.exercise == null ? 'add exercise' : 'edit exercise'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                validURL
                    ? YoutubePlayer(
                        controller: _controller,
                        showVideoProgressIndicator: true,
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
                atsTextField(
                  textEditingController: exerciseNameTextController,
                  labelText: 'exercise name',
                ),
                const SizedBox(height: 20),
                atsTextField(
                  textEditingController: videoIDTextController,
                  labelText: 'Youtube Video URL or ID',
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    var videoID = YoutubePlayer.convertUrlToId(
                        videoIDTextController.text);
                    if (videoID != null) {
                      setState(() {
                        validURL = true;
                      });
                      _controller.load(videoID);
                    } else {
                      setState(() {
                        validURL = false;
                      });
                    }
                    videoIDTextController.text = videoID ?? '';
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.exercise != null
                        ? atsButton(
                            child: Text("delete"),
                            onPressed: () {},
                          )
                        : Container(),
                    atsButton(
                      child: Text("save"),
                      onPressed: () {
                        var videoID = YoutubePlayer.convertUrlToId(
                            videoIDTextController.text);

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
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

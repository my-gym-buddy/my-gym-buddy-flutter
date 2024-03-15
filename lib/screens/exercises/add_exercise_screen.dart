import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
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
    initialVideoId: '',
    flags: YoutubePlayerFlags(
      hideControls: true,
      loop: true,
      autoPlay: true,
      mute: false,
    ),
  );

  TextEditingController exerciseNameTextController = TextEditingController();
  TextEditingController videoIDTextController = TextEditingController();
  TextEditingController exerciseDescriptionTextController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.exercise != null) {
      exerciseNameTextController.text = widget.exercise!.name;
      videoIDTextController.text = widget.exercise!.videoID ?? '';
      var videoID =
          YoutubePlayer.convertUrlToId(widget.exercise!.videoID ?? '');

      if (videoID != null) {
        setState(() {
          validURL = true;
          _controller.load(videoID);
        });
      } else {
        setState(() {
          validURL = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text(widget.exercise == null ? 'add exercise' : 'edit exercise'),
          leading: atsIconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
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
                  textEditingController: exerciseDescriptionTextController,
                  labelText: 'Description',
                  maxLines: 4,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.exercise != null
                        ? atsButton(
                            child: Text("delete",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer)),
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            onPressed: () {
                              DatabaseHelper.deleteExercise(widget.exercise!)
                                  .then((value) {
                                if (value) {
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Failed to delete exercise as it is in use in a workout.'),
                                    ),
                                  );
                                }
                              });
                            },
                          )
                        : Container(),
                    const SizedBox(
                      width: 10,
                    ),
                    atsButton(
                      child: Text("save"),
                      onPressed: () {
                        var videoID = YoutubePlayer.convertUrlToId(
                            videoIDTextController.text);

                        _controller.load(videoID ?? 'INVALID_ID');

                        if (widget.exercise == null) {
                          DatabaseHelper.saveExercise(Exercise(
                            name: exerciseNameTextController.text,
                            videoID: videoID,
                            description: exerciseDescriptionTextController.text,
                          )).then((value) {
                            if (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Exercise saved!'),
                                ),
                              );

                              Navigator.pop(context);
                            }
                          });
                        } else {
                          Exercise exercise = Exercise(
                            id: widget.exercise!.id,
                            name: exerciseNameTextController.text,
                            description: exerciseDescriptionTextController.text,
                            videoID: videoID,
                          );

                          DatabaseHelper.updateExercise(exercise).then((value) {
                            if (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Exercise updated!'),
                                ),
                              );
                              Navigator.pop(context, exercise);
                            }
                          });
                        }
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

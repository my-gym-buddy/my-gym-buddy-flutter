import 'package:gym_buddy_app/models/rep_set.dart';

class Exercise {
  final String? id;

  final String name;
  final String? videoID;

  List<RepSet> sets = [];

  Exercise(
      {required this.name,
      required this.videoID,
      this.id,
      this.sets = const []});

  Exercise.fromJson(Map<String, dynamic> json, {this.id})
      : name = json['exercise_name'],
        videoID = json['exercise_video'];
}

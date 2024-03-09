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

  Map<String, dynamic> toJson() => {
        'exercise_name': name,
        'exercise_video': videoID,
      };

  Exercise.fromJson(Map<String, dynamic> json)
      : name = json['exercise_name'],
        videoID = json['exercise_video'],
        id = json['id'].toString();
}

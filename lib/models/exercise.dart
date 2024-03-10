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
        'id': id,
        'exercise_name': name,
        'exercise_video': videoID,
        'sets': sets.map((e) => e.toJson()).toList(),
      };

  // add sets to the exercise
  void addSetFromJson(Map<String, dynamic> json) {
    sets.add(RepSet.fromJson(json));
  }

  Exercise.fromJson(Map<String, dynamic> json)
      : name = json['exercise_name'],
        videoID = json['exercise_video'],
        id = json['id'].toString() {
    if (json['sets'] == null) return;

    for (var set in json['sets']) {
      addSetFromJson(set);
    }
  }
}

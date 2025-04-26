import 'package:gym_buddy_app/models/rep_set.dart';

class Exercise {
  final String? id;

  final String name;
  final String? videoURL;

  String? description;
  String? category;
  String? difficulty;

  List<String>? images;

  List<RepSet> sets = [];
  List<RepSet>? previousSets;

  Exercise(
      {required this.name,
       this.videoURL,
      this.description,
      this.id,
      this.category,
      this.difficulty,
      this.images,
      this.sets = const []});

  Map<String, dynamic> toJson() => {
        'id': id,
        'exercise_name': name,
        'exercise_description': description,
        'exercise_video': videoURL,
        'exercise_category': category,
        'exercise_difficulty': difficulty,
        'images': images,
        'sets': sets.map((e) => e.toJson()).toList(),
        'previousSets': previousSets?.map((e) => e.toJson()).toList(),
      };

  // add sets to the exercise
  void addSetFromJson(Map<String, dynamic> json) {
    sets.add(RepSet.fromJson(json));
  }

  void addPreviousSetsFromJson(Map<String, dynamic> json) {
    previousSets = [];
    for (var set in json['sets']) {
      previousSets!.add(RepSet.fromJson(set));
    }
  }

  Exercise.fromJson(Map<String, dynamic> json)
      : name = json['exercise_name'] ?? json['name'],
        videoURL = json['exercise_video'],
        description = json['exercise_description'] ?? json['instructions']?.join('\n'),
        category = json['exercise_category'] ?? json['category'],
        difficulty = json['exercise_difficulty'] ?? json['level'],
        images = (json['images'] as List<dynamic>?)?.cast<String>(),
        id = (json['id'] ?? '').toString() {
    if (json['sets'] != null) {
      for (var set in json['sets']) {
        addSetFromJson(set);
      }
    }

    if (json['previousSets'] != null) {
      previousSets = [];
      for (var set in json['previousSets']) {
        previousSets!.add(RepSet.fromJson(set));
      }
    }
  }
}

import 'package:gym_buddy_app/models/exercise.dart';

class Workout {
  String? id;

  String name;

  String? description;

  int? duration;
  DateTime? startTime;
  double? totalWeightLifted;

  List<Exercise>? exercises;

  Workout({required this.name, this.id, this.exercises});

  Map<String, dynamic> toJson() {
    var exercisesJson = [];

    if (exercises != null) {
      for (var exercise in exercises!) {
        exercisesJson.add(exercise.toJson());
      }
    }

    return {
      'id': id,
      'workout_name': name,
      'exercises': exercisesJson,
      'workout_description': description,
    };
  }

  Workout.fromJson(Map<String, dynamic> json) : name = json['workout_name'] {
    id = json['id'].toString();
    description = json['workout_description'];
    List<Exercise> tempExercises = [];

    if (json['exercises'] == null) return;

    for (var exercise in json['exercises']) {
      tempExercises.add(Exercise.fromJson(exercise));
    }

    exercises = tempExercises;
  }
}

import 'package:gym_buddy_app/models/exercise.dart';

class Workout {
  String? id;

  String name;

  int? duration;
  DateTime? startTime;

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
    };
  }

  Workout.fromJson(Map<String, dynamic> json) : name = json['workout_name'] {
    id = json['id'].toString();
    List<Exercise> tempExercises = [];

    if (json['exercises'] == null) return;

    for (var exercise in json['exercises']) {
      tempExercises.add(Exercise.fromJson(exercise));
    }

    exercises = tempExercises;
  }
}

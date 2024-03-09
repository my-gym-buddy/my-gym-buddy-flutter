import 'package:gym_buddy_app/models/exercise.dart';

class Workout {
  String? id;

  String name;

  List<Exercise> exercises = [];

  Workout(this.name, {this.id});

  Workout.fromJson(Map<String, dynamic> json) : name = json['workout_name'] {
    id = json['id'];
  }
}

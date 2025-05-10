import 'package:gym_buddy_app/models/exercise.dart';

class Workout {
  String? id;

  String name;

  String? description;

  Set<int>? daysOfWeek;

  int? duration;
  DateTime? startTime;
  double? totalWeightLifted;
  List<Exercise>? exercises;

  Workout({
    required this.name, 
    this.id, 
    this.exercises, 
    this.description, 
    this.daysOfWeek, 
    this.duration, 
    this.startTime, 
    this.totalWeightLifted
  });

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
      'workout_days': getWorkoutDaysAsInt() == 0 ? null : getWorkoutDaysAsInt(),
    };
  }

  int getWorkoutDaysAsInt() {
    String workoutDays = "";

    if (daysOfWeek != null) {
      for (var day in daysOfWeek!) {
        workoutDays += day.toString();
      }
    }

    if (workoutDays == "") {
      return 0;
    }
    return int.parse(workoutDays);
  }

  Workout.fromJson(Map<String, dynamic> json) : name = json['workout_name'] {
    id = json['id'].toString();
    description = json['workout_description'];
    List<Exercise> tempExercises = [];

    if (json['workout_day'] != null) {
      daysOfWeek =
          json['workout_day'].toString().split('').map(int.parse).toSet();
      print(daysOfWeek);
    } else {
      daysOfWeek = {};
    }

    if (json['exercises'] == null) return;

    for (var exercise in json['exercises']) {
      tempExercises.add(Exercise.fromJson(exercise));
    }

    exercises = tempExercises;
  }
}

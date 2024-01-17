import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseHelper {
  static final PocketBaseHelper _instance = PocketBaseHelper._internal();

  factory PocketBaseHelper() => _instance;

  PocketBaseHelper._internal();

  static PocketBaseHelper get instance => _instance;

  static PocketBase pb = PocketBase('http://10.0.2.2:8090/');

  static Future<bool> saveExercise(Exercise exercise) async {
    final body = <String, dynamic>{
      "exercise_name": exercise.name,
      "exercise_video": exercise.videoID,
    };

    await pb.collection('exercises').create(body: body);

    return true;
  }

  static Future<bool> saveWorkout(Workout workout) async {
    final body = <String, dynamic>{
      "workout_name": workout.name,
    };

    var rawWorkout =
        await pb.collection('workout_templates').create(body: body);

    int index = 0;
    for (final exercise in workout.exercises) {
      var rep_set = {'sets': []};

      for (final set in exercise.sets) {
        rep_set['sets']!
            .add({'reps': set.reps, 'weight': set.weight, 'note': set.note});
      }

      final body = <String, dynamic>{
        "exercise_id": exercise.id,
        "workout_template_id": rawWorkout.id,
        "rep_set": rep_set,
        "index": index,
      };

      await pb.collection('workout_template_exercises').create(body: body);
      index++;
    }

    return true;
  }

  static Future<List<Exercise>> getExercises() async {
    final records = await pb.collection('exercises').getFullList();

    List<Exercise> exercises = [];
    for (final record in records) {
      exercises.add(Exercise.fromJson(record.data, id: record.id));
    }

    return exercises;
  }

  static Future<Exercise> getExerciseGivenID(String id) async {
    final record = await pb.collection('exercises').getOne(id);

    return Exercise.fromJson(record.data, id: record.id);
  }

  static Future<List<Workout>> getWorkouts() async {
    final rawWorkout = await pb.collection('workout_templates').getFullList();

    List<Workout> workouts = [];
    //? loop through each workout
    for (final record in rawWorkout) {
      Workout workout = Workout.fromJson(record.data, id: record.id);

      var rawExercisesInWorkout =
          await pb.collection('workout_template_exercises').getList(
                filter: 'workout_template_id = "${record.id}"',
              );

      //? loop through each exercise in workout
      for (final rawExerciseInWorkout in rawExercisesInWorkout.items) {
        var exercise =
            await getExerciseGivenID(rawExerciseInWorkout.data['exercise_id']);

        //? loop through each set in exercise
        for (final repSet in rawExerciseInWorkout.data['rep_set']['sets']) {
          var set = RepSet(
              reps: repSet['reps'],
              weight: double.parse(repSet['weight'].toString()),
              note: repSet['note']);
          exercise.sets.add(set);
        }
        workout.exercises.add(exercise);
      }

      workouts.add(workout);
    }
    return workouts;
  }
}

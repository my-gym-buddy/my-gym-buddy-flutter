import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  static Database? database;

  static Future<String> getDatabasePath() async {
    var databasesPath = await getDatabasesPath();
    if (kDebugMode) print(databasesPath);
    return '$databasesPath/gym_buddy.db';
  }

  static PocketBase pb = PocketBase('http://10.0.2.2:8090/');

  static Future<bool> saveExercise(Exercise exercise) async {
    database!.insert('exercises', exercise.toJson());

    return true;
  }

  static Future<bool> saveWorkout(Workout workout) async {
    var rawWorkoutID = await database!
        .insert('workout_templates', {'workout_name': workout.name});

    int index = 0;
    for (final exercise in workout.exercises) {
      var repSet = {'sets': []};

      for (final set in exercise.sets) {
        repSet['sets']!
            .add({'reps': set.reps, 'weight': set.weight, 'note': set.note});
      }

      final workoutTemplateExercise = <String, dynamic>{
        "exercise_id": int.parse(exercise.id!),
        "workout_template_id": rawWorkoutID,
        "rep_set": repSet.toString(),
        "exercise_index": index,
      };

      await database!
          .insert('workout_template_exercises', workoutTemplateExercise);
      index++;
    }

    return true;
  }

  static Future<List<Exercise>> getExercises() async {
    if (database == null) {
      await openLocalDatabase();
    }

    final records = await database!.query('exercises');

    List<Exercise> exercises = [];
    for (final record in records) {
      if (kDebugMode) print(record);
      exercises.add(Exercise.fromJson(record));
    }

    return exercises;
  }

  static Future<Exercise> getExerciseGivenID(String id) async {
    final record =
        await database!.query('exercises', where: 'id = ?', whereArgs: [id]);

    return Exercise.fromJson(record.first);
  }

  static Future<List<Workout>> getWorkouts() async {
    // if (database == null) {
    //   await openLocalDatabase();
    // }

    // final rawWorkout = await database!.query('workout_templates');

    // List<Workout> workouts = [];
    // //? loop through each workout
    // for (final record in rawWorkout) {
    //   Workout workout = Workout.fromJson(
    //     record,
    //   );

    //   var rawExercisesInWorkout = await database!.query(
    //       'workout_template_exercises',
    //       where: 'workout_template_id = ?',
    //       whereArgs: [record['id']]);

    //   //? loop through each exercise in workout
    //   for (final rawExerciseInWorkout in rawExercisesInWorkout) {
    //     var exercise = await getExerciseGivenID(
    //         rawExerciseInWorkout['exercise_id'].toString());

    //     if (kDebugMode) print(exercise);

    //     //? loop through each set in exercise
    //     // for (final repSet in rawExerciseInWorkout['rep_set']['sets']) {
    //     //   var set = RepSet(
    //     //       reps: repSet['reps'],
    //     //       weight: double.parse(repSet['weight'].toString()),
    //     //       note: repSet['note']);
    //     //   exercise.sets.add(set);
    //     // }
    //     // workout.exercises.add(exercise);
    //   }

    //   workouts.add(workout);
    // }
    // return workouts;

    return [];
  }

  static Future<Database> openLocalDatabase() async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    if (database == null) {
      database =
          await openDatabase(await getDatabasePath(), onCreate: (db, version) {
        db.execute(
            "CREATE TABLE exercises (id INTEGER PRIMARY KEY, exercise_name TEXT, exercise_video TEXT)");
        db.execute(
            "CREATE TABLE workout_templates (id INTEGER PRIMARY KEY, workout_name TEXT)");
        db.execute(
            "CREATE TABLE workout_template_exercises (id INTEGER PRIMARY KEY, exercise_id INTEGER, workout_template_id INTEGER, rep_set TEXT, exercise_index INTEGER)");
      }, version: 1);
      return database!;
    }

    return database!;
  }
}

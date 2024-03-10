import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';
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

  static Future<bool> saveExercise(Exercise exercise) async {
    if (database == null) {
      await openLocalDatabase();
    }

    var data = exercise.toJson();
    var safeData = {
      'exercise_name': data['exercise_name'],
      'exercise_video': data['exercise_video'],
    };

    database!.insert(
      'exercises',
      safeData,
    );

    return true;
  }

  static Future<bool> saveWorkout(Workout workout) async {
    var rawWorkoutID = await database!
        .insert('workout_templates', {'workout_name': workout.name});

    int index = 0;
    for (final exercise in workout.exercises!) {
      var repSet = {'sets': []};

      for (final set in exercise.sets) {
        repSet['sets']!
            .add({'reps': set.reps, 'weight': set.weight, 'note': set.note});
      }
      print(exercise.id!);

      final workoutTemplateExercise = <String, dynamic>{
        "exercise_id": int.parse(exercise.id!),
        "workout_template_id": rawWorkoutID,
        "rep_set": json.encode(repSet),
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
      print(record);
      exercises.add(Exercise.fromJson(record));
    }

    return exercises;
  }

  static Future<Exercise> getExerciseGivenID(String id) async {
    final record =
        await database!.query('exercises', where: 'id = ?', whereArgs: [id]);

    return Exercise.fromJson(record.first);
  }

  static Future<List<Workout>> getWorkoutList() async {
    if (database == null) {
      await openLocalDatabase();
    }

    final rawWorkout = await database!.query('workout_templates');

    if (kDebugMode) print(rawWorkout);

    List<Workout> workouts = [];
    for (final record in rawWorkout) {
      Workout workout = Workout.fromJson(
        record,
      );
      workouts.add(workout);
    }

    return workouts;
  }

  static Future<Workout> getWorkoutGivenID(String id) async {
    final record = await database!
        .query('workout_templates', where: 'id = ?', whereArgs: [id]);

    final rawExercises = await database!.query('workout_template_exercises',
        where: 'workout_template_id = ?', whereArgs: [id]);

    List<Exercise> exercises = [];
    for (final exercise in rawExercises) {
      final exerciseID = exercise['exercise_id'].toString();
      final exerciseRecord = await getExerciseGivenID(exerciseID);
      final exerciseObject = Exercise.fromJson(exerciseRecord.toJson());

      // convert rep_set to list of rep_set
      final repSet = exercise['rep_set'];
      final repSetMap = json.decode(repSet.toString());

      for (final set in repSetMap['sets']) {
        exerciseObject.sets.add(RepSet.fromJson(set));
      }

      exercises.add(exerciseObject);
    }

    Workout workout = Workout.fromJson(record.first);
    workout.exercises = exercises;

    return workout;
  }

  static Future<Database> openLocalDatabase({bool newDatabase = false}) async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    if (newDatabase) {
      await deleteDatabase(await getDatabasePath());
      database = null;
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
        db.execute(
            "CREATE TABLE workout_session (id INTEGER PRIMARY KEY, workout_template_id INTEGER, start_time TEXT, duration INTEGER)");
        db.execute(
            "CREATE TABLE workout_session_exercises (id INTEGER PRIMARY KEY, workout_session_id INTEGER, exercise_id INTEGER, rep_set TEXT, exercise_index INTEGER)");
      }, version: 1);
      return database!;
    }

    return database!;
  }

  static void resetDatabase() async {
    await deleteDatabase(await getDatabasePath());
    database = null;
  }
}

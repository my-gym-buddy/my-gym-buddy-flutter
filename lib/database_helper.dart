import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:gym_buddy_app/sql_queries.dart';
import 'package:share_plus/share_plus.dart';
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

  static Future<String?> importDatabase(File newDatabase) async {
    if (newDatabase.path.split('.').last != 'db') {
      return "Invalid file type";
    }

    await deleteDatabase(await getDatabasePath());
    File newFile = await newDatabase.copy(await getDatabasePath());
    await newFile.rename(await getDatabasePath());
    await openLocalDatabase(reopen: true);

    return null;
  }

  static Future<void> exportDatabase() async {
    Share.shareXFiles([XFile(await getDatabasePath())],
        subject: 'Gym Buddy Database');
  }

  static Future<List<Workout>> getTodayRecommendedWorkouts() async {
    if (database == null) {
      await openLocalDatabase();
    }

    // workout_day is in format 1234567 where 1 is monday and 7 is sunday
    int day = DateTime.now().weekday;

    final rawWorkout = await database!
        .query('workout_templates', where: "workout_day like '%$day%'");

    List<Workout> workouts = [];
    for (final record in rawWorkout) {
      Workout workout = Workout.fromJson(
        record,
      );
      workouts.add(workout);
    }

    return workouts;
  }

  static Future<bool> saveExercise(Exercise exercise) async {
    if (database == null) {
      await openLocalDatabase();
    }

    var data = exercise.toJson();
    var safeData = {
      'exercise_name': data['exercise_name'],
      'exercise_video': data['exercise_video'],
      'exercise_description': data['exercise_description'],
    };

    database!.insert(
      'exercises',
      safeData,
    );

    return true;
  }

  static Future<bool> saveWorkoutSession(Workout workout, int duration) async {
    var rawWorkoutID = await database!.insert('workout_session', {
      'workout_template_id': workout.id,
      'duration': duration,
      'workout_session_name': workout.name,
      'start_time': workout.startTime != null
          ? workout.startTime!.toIso8601String()
          : DateTime.now()
              .subtract(Duration(seconds: duration))
              .toIso8601String(),
    });

    int index = 0;
    for (final exercise in workout.exercises!) {
      var repSet = {'sets': []};

      for (final set in exercise.sets) {
        repSet['sets']!
            .add({'reps': set.reps, 'weight': set.weight, 'note': set.note});
      }

      final workoutSessionExercise = <String, dynamic>{
        "exercise_id": int.parse(exercise.id!),
        "workout_session_id": rawWorkoutID,
        "rep_set": json.encode(repSet),
        "exercise_index": index,
      };

      await database!
          .insert('workout_session_exercises', workoutSessionExercise);
      index++;
    }

    return true;
  }

  static Future<bool> deleteExercise(Exercise exercise) async {
    final rawWorkout = await database!.query('workout_template_exercises',
        where: 'exercise_id = ?', whereArgs: [exercise.id]);

    final rawWorkoutSession = await database!.query('workout_session_exercises',
        where: 'exercise_id = ?', whereArgs: [exercise.id]);

    if (rawWorkout.isNotEmpty || rawWorkoutSession.isNotEmpty) {
      return false;
    }

    await database!
        .delete('exercises', where: 'id = ?', whereArgs: [exercise.id]);

    return true;
  }

  static Future<bool> updateExercise(Exercise exercise) async {
    var data = exercise.toJson();
    var safeData = {
      'exercise_name': data['exercise_name'],
      'exercise_video': data['exercise_video'],
      'exercise_description': data['exercise_description'],
    };

    database!.update('exercises', safeData,
        where: 'id = ?', whereArgs: [exercise.id]);

    return true;
  }

  static Future<bool> deleteWorkoutSession(Workout workout) async {
    print('deleting workout ${workout.id}');

    await database!
        .delete('workout_session', where: 'id = ?', whereArgs: [workout.id]);
    await database!.delete('workout_session_exercises',
        where: 'workout_session_id = ?', whereArgs: [workout.id]);

    return true;
  }

  static Future<bool> updateWorkoutSession(Workout workout) async {
    //todo: improve that :D
    await deleteWorkoutSession(workout);
    await saveWorkoutSession(workout, workout.duration!);

    return true;
  }

  static Future<bool> updateWorkout(Workout workout) async {
    //todo: improve that :D
    await deleteWorkout(workout);
    await saveWorkout(workout);

    return true;
  }

  static Future<bool> deleteWorkout(Workout workout) async {
    await database!
        .delete('workout_templates', where: 'id = ?', whereArgs: [workout.id]);

    await database!.delete('workout_template_exercises',
        where: 'workout_template_id = ?', whereArgs: [workout.id]);

    return true;
  }

  static Future<bool> saveWorkout(Workout workout) async {
    print(workout.getWorkoutDaysAsInt());
    var rawWorkoutID = await database!.insert('workout_templates', {
      'workout_name': workout.name,
      'workout_description':
          workout.description == '' ? null : workout.description,
      "workout_day": workout.getWorkoutDaysAsInt() == 0
          ? null
          : workout.getWorkoutDaysAsInt(),
    });

    int index = 0;
    for (final exercise in workout.exercises!) {
      var repSet = {'sets': []};

      for (final set in exercise.sets) {
        repSet['sets']!
            .add({'reps': set.reps, 'weight': set.weight, 'note': set.note});
      }

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
      exercises.add(Exercise.fromJson(record));

      final previousRecord = await database!.query('workout_session_exercises',
          where: 'exercise_id = ?',
          whereArgs: [record['id']],
          orderBy: 'id DESC',
          limit: 1);

      if (previousRecord.isNotEmpty) {
        exercises.last.addPreviousSetsFromJson(
            json.decode(previousRecord.first['rep_set'].toString()));
      }
    }

    return exercises;
  }

  static Future<dynamic> getWeeklyStatistics() async {
    if (database == null) {
      await openLocalDatabase();
    }

    final rawWorkout =
        await database!.query('workout_session', orderBy: 'start_time DESC');

    int totalDuration = 0;
    double totalWeightLifted = 0;
    int totalWorkouts = 0;

    Map<DateTime, double> dailyTotalDuration = {};
    Map<DateTime, double> dailyTotalWeightLifted = {};

    for (final record in rawWorkout) {
      totalDuration += record['duration'] as int;

      // only date without time
      var date =
          DateTime.parse(record['start_time'].toString().substring(0, 10));

      dailyTotalDuration[date] = (dailyTotalDuration[date] ?? 0) +
          ((record['duration'] as int) / 3600);

      totalWorkouts++;

      final rawExercises = await database!.query('workout_session_exercises',
          where: 'workout_session_id = ?', whereArgs: [record['id']]);
      for (final exercise in rawExercises) {
        final repSet = exercise['rep_set'];
        final repSetMap = json.decode(repSet.toString());

        for (final set in repSetMap['sets']) {
          totalWeightLifted += (set['weight'] * set['reps']);

          dailyTotalWeightLifted[date] = (dailyTotalWeightLifted[date] ?? 0) +
              ((set['weight'] * set['reps']));
        }
      }
    }

    print({
      'totalDuration': totalDuration,
      'totalWeightLifted': totalWeightLifted,
      'totalWorkouts': totalWorkouts,
      'dailyTotalDuration': dailyTotalDuration,
      'dailyTotalWeightLifted': dailyTotalWeightLifted
    });

    return {
      'totalDuration': totalDuration,
      'totalWeightLifted': totalWeightLifted,
      'totalWorkouts': totalWorkouts,
      'dailyTotalDuration': dailyTotalDuration,
      'dailyTotalWeightLifted': dailyTotalWeightLifted
    };
  }

  static Future<List<Workout>> getAllWorkoutSessions() async {
    if (database == null) {
      await openLocalDatabase();
    }

    final rawWorkout =
        await database!.query('workout_session', orderBy: 'start_time DESC');

    List<Workout> workouts = [];
    for (final record in rawWorkout) {
      Workout workout = Workout(
          id: record['id'].toString(),
          name: record['workout_session_name'] != null
              ? record['workout_session_name'].toString()
              : 'unnamed workout',
          exercises: []);

      workout.startTime = DateTime.parse(record['start_time'].toString());
      workout.duration = record['duration'] as int;
      workout.totalWeightLifted = 0;

      workouts.add(workout);

      final rawExercises = await database!.query('workout_session_exercises',
          where: 'workout_session_id = ?', whereArgs: [record['id']]);

      for (final exercise in rawExercises) {
        final exerciseID = exercise['exercise_id'].toString();
        final exerciseRecord = await getExerciseGivenID(exerciseID);
        final exerciseObject = Exercise.fromJson(exerciseRecord.toJson());

        // convert rep_set to list of rep_set
        final repSet = exercise['rep_set'];
        final repSetMap = json.decode(repSet.toString());

        for (final set in repSetMap['sets']) {
          exerciseObject.sets.add(RepSet.fromJson(set));
          workout.totalWeightLifted =
              workout.totalWeightLifted! + (set['weight'] * set['reps']);
        }

        workout.exercises!.add(exerciseObject);
      }
    }

    return workouts;
  }

  static Future<Exercise> getExerciseGivenID(String id) async {
    final record =
        await database!.query('exercises', where: 'id = ?', whereArgs: [id]);

    // get the last record from session exercises
    final previousRecord = await database!.query('workout_session_exercises',
        where: 'exercise_id = ?',
        whereArgs: [id],
        orderBy: 'id DESC',
        limit: 1);

    Exercise exercise = Exercise.fromJson(record.first);
    if (previousRecord.isNotEmpty) {
      exercise.addPreviousSetsFromJson(
          json.decode(previousRecord.first['rep_set'].toString()));
    }

    return exercise;
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

    if (record.isEmpty) {
      return Workout(name: 'no name', id: '-1');
    }

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

  static Future<Database> openLocalDatabase(
      {bool newDatabase = false, bool reopen = false}) async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    if (newDatabase) {
      await deleteDatabase(await getDatabasePath());
      database = null;
    }

    if (database == null || reopen) {
      database =
          await openDatabase(await getDatabasePath(), onCreate: (db, version) {
        for (final query in SqlQueries.databaseCreationV2) {
          db.execute(query);
        }
      }, onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion == 1 && newVersion == 2) {
          if (kDebugMode) print('upgrading from v1 to v2');
          for (final query in SqlQueries.databaseUpgradeV1toV2) {
            db.execute(query);
          }
          if (kDebugMode) print('upgraded from v1 to v2');
        }
      }, version: 2);
      return database!;
    }

    return database!;
  }

  static void resetDatabase() async {
    await openLocalDatabase(newDatabase: true);
  }
}

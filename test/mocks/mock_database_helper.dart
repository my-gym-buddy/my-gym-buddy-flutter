import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';

class MockDatabaseHelper implements DatabaseHelper {
  static bool shouldSucceed = true;

  @override
  Future<bool> saveExercise(Exercise exercise) async {
    return shouldSucceed;
  }

  @override
  Future<List<String>> getCategories() async {
    return ['strength', 'cardio'];
  }

  @override
  Future<List<String>> getDifficulties() async {
    return ['beginner', 'intermediate', 'advanced'];
  }

  // Add other methods from DatabaseHelper with mock implementations
  // For now, we'll just add the minimum needed for these tests
  @override
  Future<List<Exercise>> getExercises() async {
    return [];
  }

  @override
  Future<Exercise?> getExercise(String id) async {
    return null;
  }

  @override
  Future<bool> deleteExercise(String id) async {
    return shouldSucceed;
  }
} 
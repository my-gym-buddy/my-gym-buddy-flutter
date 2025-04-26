import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gym_buddy_app/models/exercise.dart';

class ExerciseService {
  static List<Exercise> _exercises = [];
  
  static Future<List<Exercise>> loadExercises() async {
    if (_exercises.isNotEmpty) {
      return _exercises;
    }
    
    try {
      final String response = await rootBundle.loadString('lib/exercises.json');
      final List<dynamic> data = json.decode(response);
      
      _exercises = data.map((json) {
        final id = json['id'];
        return Exercise(
          id: id,
          name: json['name'],
          videoURL: null, // No video ID in the JSON
          description: json['instructions']?.join('\n'),
          category: json['category'],
          difficulty: json['level'],
          images: ['assets/exercises/${id}_0.jpg', 'assets/exercises/${id}_1.jpg'],
        );
      }).toList();
      
      return _exercises;
    } catch (e) {
      print('Error loading exercises: $e');
      return [];
    }
  }
  
  static List<String> getUniqueCategories() {
    final categories = _exercises.map((e) => e.category).whereType<String>().toSet().toList();
    categories.sort();
    return categories;
  }
  
  static List<String> getUniqueDifficulties() {
    final difficulties = _exercises.map((e) => e.difficulty).whereType<String>().toSet().toList();
    difficulties.sort();
    return difficulties;
  }
  
  static List<Exercise> filterExercises({
    String? searchQuery,
    String? category,
    String? difficulty,
  }) {
    return _exercises.where((exercise) {
      bool matchesSearch = searchQuery == null || 
          searchQuery.isEmpty || 
          exercise.name.toLowerCase().contains(searchQuery.toLowerCase());
      
      bool matchesCategory = category == null || 
          category.isEmpty || 
          exercise.category == category;
      
      bool matchesDifficulty = difficulty == null || 
          difficulty.isEmpty || 
          exercise.difficulty == difficulty;
      
      return matchesSearch && matchesCategory && matchesDifficulty;
    }).toList();
  }
} 
import 'dart:convert';
import 'package:gym_buddy_app/models/rep_set.dart';

class Exercise {
  final String? id;
  final String name;
  final String? videoURL;
  String? description;
  String? category;
  String? difficulty;
  List<String>? images;
  int? restBetweenSets; // in seconds
  int? restAfterSet; // in seconds

  List<RepSet> sets = [];
  List<RepSet>? previousSets;

  Exercise({
    required this.name,
    this.videoURL,
    this.description,
    this.id,
    this.category,
    this.difficulty,
    this.images,
    this.sets = const [],
    this.previousSets,
    this.restBetweenSets,  // Add this
    this.restAfterSet,     // Add this
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: (json['id'] ?? '').toString(),
      name: json['exercise_name'] ?? json['name'] ?? '',
      videoURL: json['exercise_video'],
      description: json['exercise_description'] ?? (json['instructions'] is List ? (json['instructions'] as List).join('\n') : null),
      category: json['exercise_category'] ?? json['category'],
      difficulty: json['exercise_difficulty'] ?? json['level'],
      images: _parseImages(json['images']),
      sets: (json['sets'] as List?)?.map((e) => RepSet.fromJson(e)).toList() ?? [],
      previousSets: (json['previousSets'] as List?)?.map((e) => RepSet.fromJson(e)).toList(),
      restBetweenSets: json['restBetweenSets'] != null ? int.parse(json['restBetweenSets'].toString()) : null,
      restAfterSet: json['restAfterSet'] != null ? int.parse(json['restAfterSet'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exercise_name': name,
        'exercise_description': description,
        'exercise_video': videoURL,
        'exercise_category': category,
        'exercise_difficulty': difficulty,
        'images': images,
        'sets': sets.map((e) => e.toJson()).toList(),
        'previousSets': previousSets?.map((e) => e.toJson()).toList(),
        'restBetweenSets': restBetweenSets,
        'restAfterSet': restAfterSet,
      };

  void addSetFromJson(Map<String, dynamic> json) {
    sets.add(RepSet.fromJson(json));
  }

  static List<String>? _parseImages(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) return raw.cast<String>();
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) return List<String>.from(decoded);
      } catch (_) {
        return raw.split(',').map((e) => e.trim()).toList();
      }
    }
    return null;
  }
}

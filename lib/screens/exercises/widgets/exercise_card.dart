import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/exercises/add_exercise_screen.dart';
import 'package:gym_buddy_app/screens/exercises/exercise_detail_screen.dart';
import 'package:gym_buddy_app/services/exercise_service.dart';



class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool editMode;

  const ExerciseCard({Key? key, required this.exercise, required this.editMode}) : super(key: key);

  Color _getDifficultyColor(String? difficulty) {
    if (difficulty == null) return Colors.grey.shade200;
    
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green.shade100;
      case 'intermediate':
        return Colors.orange.shade100;
      case 'expert':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(exercise: exercise, editMode: editMode),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            SizedBox(
              height: 180,
              child: PageView.builder(
                itemCount: exercise.images?.length ?? 0,
                itemBuilder: (context, index) {
                  final imageSource = exercise.images?[index] ?? '';
                  final isNetworkImage = imageSource.startsWith('http');
                  
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: isNetworkImage
                        ? Image.network(
                            imageSource,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $imageSource');
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            imageSource,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $imageSource');
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),

            // Exercise Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(exercise.difficulty),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          exercise.difficulty?.toLowerCase() ?? 'beginner',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        exercise.category ?? 'No category',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


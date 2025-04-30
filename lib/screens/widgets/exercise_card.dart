import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/exercises/single_exercise_screen.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.exercise});

  final Exercise exercise;

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
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleExerciseScreen(exercise: exercise),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.category ?? 'No category',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(exercise.difficulty),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      exercise.difficulty ?? 'No difficulty',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  
                  // Horizontal image gallery
                  if (exercise.images != null && exercise.images!.isNotEmpty)
                    ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: exercise.images!.length,
                          itemBuilder: (context, index) {
                            return _buildImageThumbnail(
                              context, 
                              exercise.images![index]
                            );
                          },
                        ),
                      ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageThumbnail(BuildContext context, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/$imagePath',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.fitness_center, size: 24),
            );
          },
        ),
      ),
    );
  }
}

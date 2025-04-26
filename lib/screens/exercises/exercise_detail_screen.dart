import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';
import 'package:gym_buddy_app/screens/exercises/all_exercises_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:gym_buddy_app/screens/exercises/widgets/exercise_form.dart';

class ExerciseDetailScreen extends StatelessWidget {
  static const int numberOfImages = 2;

  final Exercise exercise;
  final bool editMode;
  TextEditingController nameController = TextEditingController();
  ExerciseDetailScreen(
      {Key? key, required this.exercise, required this.editMode})
      : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        leading: atsIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AllExercisesScreen()),
            );
          },
        ),
        actions: [
          if (editMode) ...[
            atsIconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return 
                    DraggableScrollableSheet(
                      initialChildSize: 0.7, // Takes up 70% of screen height
                      minChildSize: 0.5, // Minimum 50% of screen height
                      maxChildSize: 0.75, // Maximum 75% of screen height
                      expand: false,
                      builder: (context, scrollController) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: ExerciseForm(
                            exercise: exercise,
                            isModal: true,
                            onSave: (updatedExercise) async {
                              try {
                                await DatabaseHelper.updateExercise(updatedExercise);
                                Navigator.pop(context);
                                // Refresh the screen with updated exercise
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExerciseDetailScreen(
                                      exercise: updatedExercise,
                                      editMode: true,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to update exercise')),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            atsIconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Exercise'),
                      content: const Text(
                          'Are you sure you want to delete this exercise?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            DatabaseHelper.deleteExercise(exercise)
                                .then((success) {
                              if (success) {
                                Navigator.pop(
                                    context); // Return to previous screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Exercise deleted')),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AllExercisesScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Failed to delete exercise')),
                                );
                              }
                            });
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise images
            SizedBox(
              height: 300,
              width: double.infinity,
              child: _buildExerciseImages(context),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and badges
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category and difficulty chips
                  Row(
                    children: [
                      Chip(
                        label: Text(exercise.category ?? 'No category'),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(exercise.difficulty ?? 'No difficulty'),
                        backgroundColor:
                            _getDifficultyColor(context, exercise.difficulty),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description section
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      exercise.description ?? 'No description available',
                      style: const TextStyle(
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Image gallery (if available)
                  if (exercise.id != null && exercise.id!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Exercise Form',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!editMode) ...{
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                  numberOfImages,
                                  (index) =>
                                      _buildImageThumbnail(context, index)),
                            ),
                          ),
                        } else ...{
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                exercise.images?.length ?? 0,
                                (index) => _buildDatabaseImageThumbnail(context, index),
                              ),
                            ),
                          ),
                        }
                      ],
                    ),

                  const SizedBox(height: 32),

                  // Add to library button
                  if (!editMode)
                    Center(
                      child: atsButton(
                        onPressed: () {
                          print(exercise.images = [
                            'assets/exercises/${exercise.id}_0.jpg',
                            'assets/exercises/${exercise.id}_1.jpg'
                          ]);
                          print(exercise.id);
                          print(exercise.name);
                          DatabaseHelper.saveExercise(Exercise(
                            id: exercise.id,
                            name: exercise.name,
                            description: exercise.description,
                            category: exercise.category,
                            difficulty: exercise.difficulty,
                            images: exercise.images = [
                              'assets/exercises/${exercise.id}_0.jpg',
                              'assets/exercises/${exercise.id}_1.jpg'
                            ],
                            videoURL: '',
                          )).then((success) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Exercise added to your library')),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to add exercise')),
                              );
                            }
                          });
                        },
                        child: const Text('Add to My Exercises'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseImages(BuildContext context) {
    // Extract video ID from URL
    String? getYoutubeVideoId(String? url) {
      if (url == null || url.isEmpty) return null;
      
      RegExp regExp = RegExp(
        r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      );
      
      Match? match = regExp.firstMatch(url);
      return match?.group(1);
    }

    final hasVideo = exercise.videoURL != null && exercise.videoURL!.isNotEmpty;
    final videoId = getYoutubeVideoId(exercise.videoURL);
    final totalItems = ((hasVideo && videoId != null) ? 1 : 0) + (exercise.images?.length ?? 0);
    
    return PageView.builder(
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Show video as first item
        if (hasVideo && videoId != null && index == 0) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      iconTheme: const IconThemeData(color: Colors.white),
                    ),
                    body: Center(
                      child: YoutubePlayer(
                        controller: YoutubePlayerController(
                          initialVideoId: videoId,  // Use extracted ID here
                          flags: const YoutubePlayerFlags(
                            autoPlay: true,
                            mute: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 300,
                  child: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: videoId,  // Use extracted ID here
                      flags: const YoutubePlayerFlags(
                        autoPlay: false,
                        mute: true,
                        hideControls: true,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
              ],
            ),
          );
        } else {
          // Show images after video
          final imageIndex = hasVideo ? index - 1 : index;
          final imageSource = exercise.images![imageIndex];
          final isNetworkImage = imageSource.startsWith('http');

          return GestureDetector(
            onTap: () => _showFullScreenImage(context, imageSource),
            child: isNetworkImage
                ? Image.network(
                    imageSource,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: const Center(
                          child: Icon(Icons.fitness_center, size: 80),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    imageSource,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: const Center(
                          child: Icon(Icons.fitness_center, size: 80),
                        ),
                      );
                    },
                  ),
          );
        }
      },
    );
  }

  Widget _buildImageThumbnail(BuildContext context, int index) {
    String imagePath = 'assets/exercises/${exercise.id}_$index.jpg';
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imagePath),
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDatabaseImageThumbnail(BuildContext context, int index) {
    final imageSource = exercise.images![index];
    final isNetworkImage = imageSource.startsWith('http');
    
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imageSource),
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isNetworkImage
              ? Image.network(
                  imageSource,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    );
                  },
                )
              : Image.asset(
                  imageSource,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(BuildContext context, String? difficulty) {
    if (difficulty == null) return Theme.of(context).colorScheme.surfaceVariant;

    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green[100]!;
      case 'intermediate':
        return Colors.orange[100]!;
      case 'expert':
        return Colors.red[100]!;
      default:
        return Theme.of(context).colorScheme.surfaceVariant;
    }
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    final isNetworkImage = imagePath.startsWith('http');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: isNetworkImage
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 64,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 64,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

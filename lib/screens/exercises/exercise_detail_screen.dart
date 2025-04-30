import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/exercises/all_exercises_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseDetailScreen extends StatelessWidget {
  static const int numberOfImages = 2;

  final Exercise exercise;
  final bool editMode;
  TextEditingController nameController = TextEditingController();
  
  ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.editMode,
  });

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(context),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(context),
                  const SizedBox(height: 32),
                  if (exercise.id != null && exercise.id!.isNotEmpty)
                    _buildExerciseFormSection(context),
                  const SizedBox(height: 32),
                  if (!editMode) _buildAddToLibraryButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(exercise.name),
      leading: _buildBackButton(context),
      actions: editMode ? _buildEditActions(context) : null,
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return atsIconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllExercisesScreen()),
        );
      },
    );
  }

  List<Widget> _buildEditActions(BuildContext context) {
    return [
      _buildEditButton(context),
      _buildDeleteButton(context),
    ];
  }

  Widget _buildEditButton(BuildContext context) {
    return atsIconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => _showEditForm(context),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return atsIconButton(
      icon: const Icon(Icons.delete),
      onPressed: () => _showDeleteConfirmation(context),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: _buildExerciseImages(context),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildCategoryChips(context),
      ],
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return Row(
      children: [
        Chip(
          label: Text(exercise.category ?? 'No category'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        const SizedBox(width: 8),
        Chip(
          label: Text(exercise.difficulty ?? 'No difficulty'),
          backgroundColor: _getDifficultyColor(context, exercise.difficulty),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            style: const TextStyle(height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseFormSection(BuildContext context) {
    return Column(
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
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _buildImageList(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildImageList(BuildContext context) {
    if (editMode) {
      return List.generate(
        exercise.images?.length ?? 0,
        (index) => _buildDatabaseImageThumbnail(context, index),
      );
    }
    return List.generate(
      numberOfImages,
      (index) => _buildImageThumbnail(context, index),
    );
  }

  Widget _buildAddToLibraryButton(BuildContext context) {
    return Center(
      child: atsButton(
        onPressed: () => _handleAddToLibrary(context),
        child: const Text('Add to My Exercises'),
      ),
    );
  }

  void _handleAddToLibrary(BuildContext context) {
    exercise.images = [
      'assets/exercises/${exercise.id}_0.jpg',
      'assets/exercises/${exercise.id}_1.jpg'
    ];
    
    DatabaseHelper.saveExercise(Exercise(
      id: exercise.id,
      name: exercise.name,
      description: exercise.description,
      category: exercise.category,
      difficulty: exercise.difficulty,
      images: exercise.images,
      videoURL: '',
    )).then((success) {
      if (context.mounted) {
        _handleSaveResponse(context, success);
      }
    });
  }

  void _handleSaveResponse(BuildContext context, bool success) {
    if (!context.mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise added to your library')),
      );
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add exercise')),
      );
    }
  }

  Widget _buildExerciseImages(BuildContext context) {
    final videoId = getYoutubeVideoId(exercise.videoURL);
    final hasVideo = exercise.videoURL != null && exercise.videoURL!.isNotEmpty && videoId != null;
    final totalItems = (hasVideo ? 1 : 0) + (exercise.images?.length ?? 0);
    
    return PageView.builder(
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (hasVideo && index == 0) {
          return _buildVideoPlayer(context, videoId!);
        } else {
          return _buildImageView(context, index, hasVideo);
        }
      },
    );
  }

  String? getYoutubeVideoId(String? url) {
    if (url == null || url.isEmpty) return null;
    
    RegExp regExp = RegExp(
      r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
    );
    
    Match? match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Widget _buildVideoPlayer(BuildContext context, String videoId) {
    return GestureDetector(
      onTap: () => _showFullScreenVideo(context, videoId),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 300,
            child: YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: videoId,
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
  }

  Widget _buildImageView(BuildContext context, int index, bool hasVideo) {
    final imageIndex = hasVideo ? index - 1 : index;
    final imageSource = exercise.images![imageIndex];
    final isNetworkImage = imageSource.startsWith('http');

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imageSource),
      child: isNetworkImage
          ? _buildNetworkImage(imageSource)
          : _buildAssetImage(imageSource),
    );
  }

  Widget _buildNetworkImage(String imageSource) {
    return Image.network(
      imageSource,
      fit: BoxFit.cover,
      errorBuilder: _buildErrorWidget,
    );
  }

  Widget _buildAssetImage(String imageSource) {
    return Image.asset(
      imageSource,
      fit: BoxFit.cover,
      errorBuilder: _buildErrorWidget,
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Center(
        child: Icon(Icons.fitness_center, size: 80),
      ),
    );
  }

  void _showFullScreenVideo(BuildContext context, String videoId) {
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
                initialVideoId: videoId,
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
    if (difficulty == null) return Theme.of(context).colorScheme.surfaceContainerHighest;

    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green[100]!;
      case 'intermediate':
        return Colors.orange[100]!;
      case 'expert':
        return Colors.red[100]!;
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
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

  void _showEditForm(BuildContext context) {
    // Implementation of _showEditForm method
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Implementation of _showDeleteConfirmation method
  }
}

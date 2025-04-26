import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/exercises/add_exercise_screen.dart';
import 'package:gym_buddy_app/screens/exercises/exercise_detail_screen.dart';
import 'package:gym_buddy_app/services/exercise_service.dart';

class ExerciseBrowserScreen extends StatefulWidget {
  const ExerciseBrowserScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseBrowserScreen> createState() => _ExerciseBrowserScreenState();
}

class _ExerciseBrowserScreenState extends State<ExerciseBrowserScreen> {
  List<Exercise> exercises = [];
  List<Exercise> filteredExercises = [];
  bool isLoading = true;
  String? selectedCategory;
  String? selectedDifficulty;
  final TextEditingController searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadExercises();
  }
  
  Future<void> _loadExercises() async {
    setState(() {
      isLoading = true;
    });
    
    final loadedExercises = await ExerciseService.loadExercises();
    
    setState(() {
      exercises = loadedExercises;
      filteredExercises = loadedExercises;
      isLoading = false;
    });
  }
  
  void _applyFilters() {
    setState(() {
      filteredExercises = ExerciseService.filterExercises(
        searchQuery: searchController.text,
        category: selectedCategory,
        difficulty: selectedDifficulty,
      );
    });
  }
  
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
    final categories = ['All'] + ExerciseService.getUniqueCategories();
    final difficulties = ['All'] + ExerciseService.getUniqueDifficulties();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('exercise database', style: Theme.of(context).textTheme.titleLarge),
        leading: atsIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: atsIconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
                );
                setState(() {});
              },
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search exercises',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
                const SizedBox(height: 16),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category Filter
                      FilterChip(
                        label: Text(selectedCategory ?? 'All Categories'),
                        selected: selectedCategory != null,
                        onSelected: (bool selected) {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (context) => CategoryFilterSheet(
                              categories: categories,
                              selectedCategory: selectedCategory,
                              onSelect: (category) {
                                setState(() {
                                  selectedCategory = category == 'All' ? null : category;
                                  _applyFilters();
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        avatar: const Icon(Icons.category),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const SizedBox(width: 8),
                      
                      // Difficulty Filter
                      FilterChip(
                        label: Text(selectedDifficulty ?? 'All Difficulties'),
                        selected: selectedDifficulty != null,
                        onSelected: (bool selected) {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (context) => DifficultyFilterSheet(
                              difficulties: difficulties,
                              selectedDifficulty: selectedDifficulty,
                              onSelect: (difficulty) {
                                setState(() {
                                  selectedDifficulty = difficulty == 'All' ? null : difficulty;
                                  _applyFilters();
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        avatar: const Icon(Icons.fitness_center),
                        padding: const EdgeInsets.symmetric(horizontal:  8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Exercise list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredExercises.isEmpty
                    ? const Center(child: Text('No exercises found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];
                          return ExerciseCard(exercise: exercise, editMode: false);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

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

class CategoryFilterSheet extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String) onSelect;

  const CategoryFilterSheet({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category),
                  trailing: category == (selectedCategory ?? 'All')
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () => onSelect(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DifficultyFilterSheet extends StatelessWidget {
  final List<String> difficulties;
  final String? selectedDifficulty;
  final Function(String) onSelect;

  const DifficultyFilterSheet({
    Key? key,
    required this.difficulties,
    required this.selectedDifficulty,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Select Difficulty',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: difficulties.length,
              itemBuilder: (context, index) {
                final difficulty = difficulties[index];
                return ListTile(
                  title: Text(difficulty),
                  trailing: difficulty == (selectedDifficulty ?? 'All')
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () => onSelect(difficulty),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
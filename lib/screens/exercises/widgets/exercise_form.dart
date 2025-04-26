import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_dropdown.dart';

class ExerciseForm extends StatefulWidget {
  final Exercise? exercise;
  final bool isModal;
  final Function(Exercise) onSave;

  const ExerciseForm({
    Key? key,
    this.exercise,
    required this.onSave,
    this.isModal = false,
  }) : super(key: key);

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController videoIDController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  
  List<String> images = [];
  List<String> categories = [];
  List<String> difficulties = [];
  String? selectedCategory;
  String? selectedDifficulty;

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      nameController.text = widget.exercise!.name;
      descriptionController.text = widget.exercise!.description ?? '';
      selectedDifficulty = widget.exercise!.difficulty;
      selectedCategory = widget.exercise!.category;
      videoIDController.text = widget.exercise!.videoURL ?? '';
      images = widget.exercise!.images ?? [];
    }
    _loadCategoriesAndDifficulties();
  }

  Future<void> _loadCategoriesAndDifficulties() async {
    final loadedCategories = await DatabaseHelper.getCategories();
    final loadedDifficulties = await DatabaseHelper.getDifficulties();
    setState(() {
      categories = loadedCategories;
      difficulties = loadedDifficulties;
      
      // Add selected category to the list if it exists and isn't already present
      if (selectedCategory != null && !categories.contains(selectedCategory)) {
        categories.add(selectedCategory!);
      }
      
      // Add selected difficulty to the list if it exists and isn't already present
      if (selectedDifficulty != null && !difficulties.contains(selectedDifficulty)) {
        difficulties.add(selectedDifficulty!);
      }
    });
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageUrlInput(),
            const SizedBox(height: 16),
            atsTextField(
              textEditingController: nameController,
              labelText: 'Exercise Name',
            ),
            const SizedBox(height: 16),
            atsTextField(
              textEditingController: descriptionController,
              labelText: 'Description',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: atsDropdown<String>(
                    value: selectedCategory,
                    items: categories,
                    labelText: 'Category',
                    onChanged: (value) {
                      setState(() => selectedCategory = value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                atsIconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddDialog(
                    title: 'Add Category',
                    hintText: 'Enter new category',
                    onAdd: _addCategory,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: atsDropdown<String>(
                    value: selectedDifficulty,
                    items: difficulties,
                    labelText: 'Difficulty',
                    onChanged: (value) {
                      setState(() => selectedDifficulty = value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                atsIconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddDialog(
                    title: 'Add Difficulty',
                    hintText: 'Enter new difficulty',
                    onAdd: _addDifficulty,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            atsTextField(
              textEditingController: videoIDController,
              labelText: 'Video URL',
            ),
            const SizedBox(height: 24),
            atsButton(
              onPressed: _handleSave,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUrlInput() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: atsTextField(
                textEditingController: imageUrlController,
                labelText: 'Image URL',
              ),
            ),
            const SizedBox(width: 10),
            atsButton(
              onPressed: () {
                if (imageUrlController.text.isNotEmpty) {
                  setState(() {
                    images.add(imageUrlController.text);
                    imageUrlController.clear();
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: Image.network(
                    images[index],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image);
                    },
                  ),
                  title: Text(images[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        images.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Future<void> _showAddDialog({
    required String title,
    required String hintText,
    required Function(String) onAdd,
  }) async {
    final controller = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: atsTextField(
          textEditingController: controller,
          labelText: hintText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onAdd(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(String category) async {
    await DatabaseHelper.addCategory(category);
    final updatedCategories = await DatabaseHelper.getCategories();
    setState(() {
      categories = updatedCategories;
      selectedCategory = category;
    });
  }

  Future<void> _addDifficulty(String difficulty) async {
    await DatabaseHelper.addDifficulty(difficulty);
    final updatedDifficulties = await DatabaseHelper.getDifficulties();
    setState(() {
      difficulties = updatedDifficulties;
      selectedDifficulty = difficulty;
    });
  }

  void _handleSave() {
    final exercise = Exercise(
      id: widget.exercise?.id,
      name: nameController.text,
      description: descriptionController.text,
      category: selectedCategory,
      difficulty: selectedDifficulty,
      images: images,
      videoURL: videoIDController.text,
    );
    widget.onSave(exercise);
  }

  @override
  Widget build(BuildContext context) {
    return widget.isModal
        ? _buildForm()
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise'),
              leading: atsIconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: _buildForm(),
          );
  }
} 
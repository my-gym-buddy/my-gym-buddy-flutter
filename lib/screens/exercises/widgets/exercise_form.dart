import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_dropdown.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_confirm_exit_showmodalbottom.dart';

class ExerciseForm extends StatefulWidget {
  final Exercise? exercise;
  final bool isModal;
  final Function(Exercise) onSave;

  const ExerciseForm({
    super.key,
    this.exercise,
    required this.onSave,
    this.isModal = false,
  });

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

  bool _hasChanges = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    void markAsChanged() {
      if (!_hasChanges) setState(() => _hasChanges = true);
    }

    nameController.addListener(markAsChanged);
    descriptionController.addListener(markAsChanged);
    videoIDController.addListener(markAsChanged);
    imageUrlController.addListener(markAsChanged);

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
      if (selectedDifficulty != null &&
          !difficulties.contains(selectedDifficulty)) {
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
              onChanged: (value) {
                setState(() {});
              },
            ),
            if (videoIDController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildVideoPreview(videoIDController.text),
            ],
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: images.map((url) => _buildImageCard(url)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildImageCard(String url) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              url,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      images.remove(url);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(String url) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          'https://img.youtube.com/vi/${_getYoutubeVideoId(url)}/0.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('Invalid video URL',
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String? _getYoutubeVideoId(String url) {
    // Direct video ID case
    if (!url.contains('/') && !url.contains('.')) {
      return url;
    }

    // Extract from full URL
    RegExp regExp = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).?',
    );
    Match? match = regExp.firstMatch(url);
    return match?[7];
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
    setState(() => _isSubmitting = true);
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

  Widget _wrapWithPopScope(Widget content) {
    return PopScope(
      canPop: !_hasChanges || _isSubmitting,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (!mounted) return;
        final shouldPop = await atsConfirmExitDialog(context);
        if (shouldPop && mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: content,
    );
  }

  Widget _buildScaffold(Widget content) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise'),
        leading: atsIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (!_hasChanges || await atsConfirmExitDialog(context)) {
              if (mounted) Navigator.pop(context);
            }
          },
        ),
      ),
      body: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _buildForm();
    content = _wrapWithPopScope(content);

    return widget.isModal ? content : _buildScaffold(content);
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';

class RestTimerSettingsModal extends StatefulWidget {
  final Exercise exercise;
  final Function(Exercise) onRestTimeUpdated;

  const RestTimerSettingsModal({
    super.key,
    required this.exercise,
    required this.onRestTimeUpdated,
  });

  @override
  State<RestTimerSettingsModal> createState() => _RestTimerSettingsModalState();

  static void show(
    BuildContext context, {
    required Exercise exercise,
    required Function(Exercise) onRestTimeUpdated,
  }) {
 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RestTimerSettingsModal(
        exercise: exercise,
        onRestTimeUpdated: onRestTimeUpdated,
      ),
    );
  }

  // Utility method to initialize time values
  static List<int> _initializeTimeValues(Exercise exercise) {
    int betweenSetsMinutes = 0;
    int betweenSetsSeconds = 0;
    int afterSetMinutes = 0;
    int afterSetSeconds = 0;

    if (exercise.restBetweenSets != null) {
      betweenSetsMinutes = exercise.restBetweenSets! ~/ 60;
      betweenSetsSeconds = exercise.restBetweenSets! % 60;
    }

    if (exercise.restAfterSet != null) {
      afterSetMinutes = exercise.restAfterSet! ~/ 60;
      afterSetSeconds = exercise.restAfterSet! % 60;
    }

    return [betweenSetsMinutes, betweenSetsSeconds, afterSetMinutes, afterSetSeconds];
  }
}

class _RestTimerSettingsModalState extends State<RestTimerSettingsModal> {
  late int betweenSetsMinutes;
  late int betweenSetsSeconds;
  late int afterSetMinutes;
  late int afterSetSeconds;
  late bool hasMultipleSets;

  @override
  void initState() {
    super.initState();
    hasMultipleSets = widget.exercise.sets != null && widget.exercise.sets!.length > 1;
    
    // Initialize time values
    final timeValues = RestTimerSettingsModal._initializeTimeValues(widget.exercise);
    betweenSetsMinutes = timeValues[0];
    betweenSetsSeconds = timeValues[1];
    afterSetMinutes = timeValues[2];
    afterSetSeconds = timeValues[3];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 350 + (hasMultipleSets ? 100 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExerciseHeader(),
          const SizedBox(height: 20),
          if (hasMultipleSets)
            _buildRestBetweenSetsSection(),
          _buildRestAfterSetSection(),
          const SizedBox(height: 20),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Center(
      child: Text(
        widget.exercise.name,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRestBetweenSetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rest between each sets',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  betweenSetsMinutes,
                  (index) => setState(() => betweenSetsMinutes = index),
                  'min',
                ),
              ),
              Expanded(
                child: _buildTimePicker(
                  betweenSetsSeconds,
                  (index) => setState(() => betweenSetsSeconds = index),
                  'sec',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRestAfterSetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rest after whole set',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  afterSetMinutes,
                  (index) => setState(() => afterSetMinutes = index),
                  'min',
                ),
              ),
              Expanded(
                child: _buildTimePicker(
                  afterSetSeconds,
                  (index) => setState(() => afterSetSeconds = index),
                  'sec',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(int initialValue, Function(int) onChanged, String suffix) {
    return CupertinoPicker(
      itemExtent: 32,
      onSelectedItemChanged: onChanged,
      scrollController: FixedExtentScrollController(
        initialItem: initialValue,
      ),
      children: List.generate(60, (index) {
        return Center(child: Text('$index $suffix'));
      }),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _saveRestTimes(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveRestTimes(BuildContext context) {
    // Calculate rest times in seconds
    final int? betweenSetsTotal = hasMultipleSets
        ? betweenSetsMinutes * 60 + betweenSetsSeconds
        : null;

    final int afterSetTotal = afterSetMinutes * 60 + afterSetSeconds;

    // Update exercise
    widget.exercise.restBetweenSets = 
        hasMultipleSets && betweenSetsTotal! > 0 ? betweenSetsTotal : null;
    widget.exercise.restAfterSet = 
        afterSetTotal > 0 ? afterSetTotal : null;

    // Notify parent about changes
    widget.onRestTimeUpdated(widget.exercise);

    Navigator.pop(context);
  }
}
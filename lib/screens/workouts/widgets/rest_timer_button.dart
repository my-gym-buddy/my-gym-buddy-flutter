import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';

class RestTimerButton extends StatefulWidget {
  final Exercise exercise;
  final Function(Exercise) onRestTimeUpdated;

  const RestTimerButton({
    super.key,
    required this.exercise,
    required this.onRestTimeUpdated,
  });

  @override
  State<RestTimerButton> createState() => _RestTimerButtonState();
}

class _RestTimerButtonState extends State<RestTimerButton> {
  @override
  Widget build(BuildContext context) {
    final bool hasRestTimeSet = widget.exercise.restBetweenSets != null ||
        widget.exercise.restAfterSet != null;

    return GestureDetector(
      onTap: () => _showRestTimeModal(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: hasRestTimeSet ? Colors.amber : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.timer,
          color: hasRestTimeSet ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
  }

  void _showRestTimeModal(BuildContext context) {
    final bool hasMultipleSets =
        widget.exercise.sets != null && widget.exercise.sets!.length > 1;

    // Initialize time values
    final timeValues = _initializeTimeValues();
    int betweenSetsMinutes = timeValues[0];
    int betweenSetsSeconds = timeValues[1];
    int afterSetMinutes = timeValues[2];
    int afterSetSeconds = timeValues[3];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 350 + (hasMultipleSets ? 100 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExerciseHeader(),
                const SizedBox(height: 20),
                if (hasMultipleSets)
                  _buildRestBetweenSetsSection(
                    setModalState, 
                    betweenSetsMinutes, 
                    betweenSetsSeconds
                  ),
                _buildRestAfterSetSection(
                  setModalState, 
                  afterSetMinutes, 
                  afterSetSeconds
                ),
                const SizedBox(height: 20),
                _buildActionButtons(
                  context, 
                  hasMultipleSets,
                  betweenSetsMinutes, 
                  betweenSetsSeconds,
                  afterSetMinutes, 
                  afterSetSeconds
                ),
              ],
            ),
          );
        },
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

  Widget _buildRestBetweenSetsSection(
    StateSetter setModalState,
    int betweenSetsMinutes,
    int betweenSetsSeconds,
  ) {
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
                  (index) => setModalState(() => betweenSetsMinutes = index),
                  'min',
                ),
              ),
              Expanded(
                child: _buildTimePicker(
                  betweenSetsSeconds,
                  (index) => setModalState(() => betweenSetsSeconds = index),
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

  Widget _buildRestAfterSetSection(
    StateSetter setModalState,
    int afterSetMinutes,
    int afterSetSeconds,
  ) {
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
                  (index) => setModalState(() => afterSetMinutes = index),
                  'min',
                ),
              ),
              Expanded(
                child: _buildTimePicker(
                  afterSetSeconds,
                  (index) => setModalState(() => afterSetSeconds = index),
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

  Widget _buildActionButtons(
    BuildContext context,
    bool hasMultipleSets,
    int betweenSetsMinutes,
    int betweenSetsSeconds,
    int afterSetMinutes,
    int afterSetSeconds,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _saveRestTimes(
            context,
            hasMultipleSets,
            betweenSetsMinutes,
            betweenSetsSeconds,
            afterSetMinutes,
            afterSetSeconds,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  List<int> _initializeTimeValues() {
    int betweenSetsMinutes = 0;
    int betweenSetsSeconds = 0;
    int afterSetMinutes = 0;
    int afterSetSeconds = 0;

    if (widget.exercise.restBetweenSets != null) {
      betweenSetsMinutes = widget.exercise.restBetweenSets! ~/ 60;
      betweenSetsSeconds = widget.exercise.restBetweenSets! % 60;
    }

    if (widget.exercise.restAfterSet != null) {
      afterSetMinutes = widget.exercise.restAfterSet! ~/ 60;
      afterSetSeconds = widget.exercise.restAfterSet! % 60;
    }

    return [betweenSetsMinutes, betweenSetsSeconds, afterSetMinutes, afterSetSeconds];
  }

  void _saveRestTimes(
    BuildContext context,
    bool hasMultipleSets,
    int betweenSetsMinutes,
    int betweenSetsSeconds,
    int afterSetMinutes,
    int afterSetSeconds,
  ) {
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

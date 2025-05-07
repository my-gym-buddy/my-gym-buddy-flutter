import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/workouts/widgets/rest_timer_settings_modal.dart';

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
    RestTimerSettingsModal.show(
      context,
      exercise: widget.exercise,
      onRestTimeUpdated: widget.onRestTimeUpdated,
    );
  }
}

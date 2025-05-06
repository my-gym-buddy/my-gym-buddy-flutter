import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';

// Timer manager to coordinate between multiple timers
class RestTimerManager {
  static final RestTimerManager _instance = RestTimerManager._internal();
  factory RestTimerManager() => _instance;
  RestTimerManager._internal();

  _RestTimerWidgetState? activeTimerState;

  void setActiveTimer(_RestTimerWidgetState timerState) {
    // Schedule state changes to happen after the current build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activeTimerState != null && activeTimerState != timerState) {
        activeTimerState!._pauseTimer();
      }
      activeTimerState = timerState;
    });
  }
}

class RestTimerWidget extends StatefulWidget {
  final int restDuration; // in seconds
  final VoidCallback? onComplete;
  final Exercise? exercise;
  final bool isBetweenSets; // true for between sets, false for after set
  final int setIndex;

  const RestTimerWidget({
    Key? key,
    required this.restDuration,
    this.onComplete,
    this.exercise,
    this.isBetweenSets = true,
    this.setIndex = 0,
  }) : super(key: key);

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  late Timer _timer;
  bool _isRunning = true;
  int _elapsedSeconds = 0;
  final _timerManager = RestTimerManager();

  @override
  void initState() {
    super.initState();
    
    // Schedule timer registration after the current build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pause the main workout timer when rest timer starts
      // widget.pauseWorkoutTimer();
      // Register as the active timer
      _timerManager.setActiveTimer(this);
    });
    
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isRunning) {
          _elapsedSeconds++;
          
          // Only trigger onComplete once when we first reach the duration
          if (_elapsedSeconds == widget.restDuration) {
            // widget.resumeWorkoutTimer();
            _onTimerComplete();
            // Timer continues running after completion
          }
        }
      });
    });
  }

  // Add this method to expose current timer value
  void updateRestTimeWithCurrentValue() {
    if (widget.exercise != null) {
      final int actualRestTime = _elapsedSeconds;
      
      if (widget.isBetweenSets) {
        widget.exercise!.restBetweenSets = actualRestTime;
        if (widget.setIndex < widget.exercise!.sets.length) {
          widget.exercise!.sets[widget.setIndex].restBetweenSets = actualRestTime;
        }
      } else {
        widget.exercise!.restAfterSet = actualRestTime;
        if (widget.exercise!.sets.isNotEmpty) {
          widget.exercise!.sets.last.restAfterSet = actualRestTime;
        }
      }
    }
  }
  
  // Modify _pauseTimer to update rest time values when paused
  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      // Update rest time values when paused
      updateRestTimeWithCurrentValue();
    });
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
      // Make this the active timer when manually resumed
      _timerManager.setActiveTimer(this);
    });
  }

  void _onTimerComplete() {
    if (widget.exercise != null) {
      final int actualRestTime = _elapsedSeconds; // Get the actual elapsed time
      
      if (widget.isBetweenSets) {
        // Update the exercise-level rest time between sets
        widget.exercise!.restBetweenSets = actualRestTime;
        // Also update the current set's rest time
        if (widget.setIndex < widget.exercise!.sets.length) {
          widget.exercise!.sets[widget.setIndex].restBetweenSets = actualRestTime;
        }
      } else {
        // Update the exercise-level rest time after set
        widget.exercise!.restAfterSet = actualRestTime;
        // Also update the last set's after-set rest time
        if (widget.exercise!.sets.isNotEmpty) {
          widget.exercise!.sets.last.restAfterSet = actualRestTime;
        }
      }
    }
    
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    // Clear as active timer if being disposed
    if (_timerManager.activeTimerState == this) {
      _timerManager.activeTimerState = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _elapsedSeconds / widget.restDuration;
    bool isOvertime = progress >= 1.0;

    // Show elapsed time instead of remaining time
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Progress bar background
          Container(
            width: double.infinity,
          ),

          // Progress bar fill
          FractionallySizedBox(
            widthFactor: progress > 1.0 ? 1.0 : progress,
            child: Container(
              color: isOvertime ? Colors.amber : Colors.green,
            ),
          ),

          // Center controls with black text for visibility
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/pause button
                Container(
                  child: IconButton(
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minHeight: 32,
                      minWidth: 32,
                    ),
                    icon: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      if (_isRunning) {
                        _pauseTimer();
                      } else {
                        _resumeTimer();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                formatTime(_elapsedSeconds), // Changed from remainingTime to _elapsedSeconds
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString()}:${secs.toString().padLeft(2, '0')}';
  }
}

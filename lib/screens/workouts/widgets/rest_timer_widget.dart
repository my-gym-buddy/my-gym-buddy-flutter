import 'dart:async';
import 'package:flutter/material.dart';

class RestTimerWidget extends StatefulWidget {
  final int restDuration; // in seconds
  final VoidCallback onComplete;
  final VoidCallback pauseWorkoutTimer;
  final VoidCallback resumeWorkoutTimer;

  const RestTimerWidget({
    Key? key,
    required this.restDuration,
    required this.onComplete,
    required this.pauseWorkoutTimer,
    required this.resumeWorkoutTimer,
  }) : super(key: key);

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  late Timer _timer;
  bool _isRunning = true;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Pause the main workout timer when rest timer starts
    widget.pauseWorkoutTimer();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isRunning) {
          _elapsedSeconds++;
          
          // Only check completion when running
          if (_elapsedSeconds >= widget.restDuration) {
            // Timer completed - resume workout timer
            widget.resumeWorkoutTimer();
            widget.onComplete();
          }
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _elapsedSeconds / widget.restDuration;
    bool isOvertime = progress >= 1.0;

    // Calculate remaining time
    int remainingTime = widget.restDuration - _elapsedSeconds;
    if (remainingTime < 0) remainingTime = 0;

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
                formatTime(remainingTime),
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

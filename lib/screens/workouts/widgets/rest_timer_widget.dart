import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';

class RestTimerManager {
  static final RestTimerManager _instance = RestTimerManager._internal();
  factory RestTimerManager() => _instance;
  RestTimerManager._internal();

  // Make these fields private since they use a private type
  _RestTimerWidgetState? _activeTimerState;
  final List<_RestTimerWidgetState> _pendingTimers = [];
  bool _isProcessingQueue = false;

  // Make methods that use private types also private
  void _setActiveTimer(_RestTimerWidgetState timerState) {
    // If no active timer, make this the active timer
    if (_activeTimerState == null) {
      _activeTimerState = timerState;
      // Start this timer
      timerState._startTimerIfNotStarted();
    } else {
      // Already have an active timer, add this one to the queue
      _pendingTimers.add(timerState);
      // Don't start this timer yet - it's in a waiting state
    }
  }

  // Make this method private too
  void _timerCompleted(_RestTimerWidgetState timerState) {
    if (_activeTimerState == timerState) {
      // Make sure the current timer is fully stopped
      _activeTimerState = null;

      // Add a slight delay before processing the next timer
      // This ensures the UI has time to update
      Future.delayed(const Duration(milliseconds: 50), () {
        _processNextTimerInQueue();
      });
    }
  }

  void _processNextTimerInQueue() {
    if (_pendingTimers.isEmpty || _isProcessingQueue) return;

    _isProcessingQueue = true;

    // Slight delay to avoid UI jank
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_pendingTimers.isNotEmpty) {
        final nextTimer = _pendingTimers.removeAt(0);
        _activeTimerState = nextTimer;
        nextTimer._startTimerIfNotStarted();
      }
      _isProcessingQueue = false;
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
    super.key,
    required this.restDuration,
    this.onComplete,
    this.exercise,
    this.isBetweenSets = true,
    this.setIndex = 0,
  });

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  late Timer _timer;
  bool _isRunning = false; // Start paused to wait for activation
  int _elapsedSeconds = 0;
  final _timerManager = RestTimerManager();
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();

    // Register with timer manager but don't start yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timerManager._setActiveTimer(this);
    });
  }

  // New method to start timer when activated from queue
  void _startTimerIfNotStarted() {
    if (_timerStarted) return;

    _timerStarted = true;
    _isRunning = true;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isRunning) {
          _elapsedSeconds++;

          // When timer reaches its intended duration
          if (_elapsedSeconds == widget.restDuration) {
            _onTimerComplete();
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
          widget.exercise!.sets[widget.setIndex].restBetweenSets =
              actualRestTime;
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
      _timerManager._setActiveTimer(this);
    });
  }

  // Update the _onTimerComplete method to properly cancel the timer:
  void _onTimerComplete() {
    // First cancel the current timer to stop it from continuing
    _timer.cancel();
    _isRunning = false;

    if (widget.exercise != null) {
      final int actualRestTime = _elapsedSeconds;

      // Update rest times as before
      if (widget.isBetweenSets) {
        widget.exercise!.restBetweenSets = actualRestTime;
        if (widget.setIndex < widget.exercise!.sets.length) {
          widget.exercise!.sets[widget.setIndex].restBetweenSets =
              actualRestTime;
        }
      } else {
        widget.exercise!.restAfterSet = actualRestTime;
        if (widget.exercise!.sets.isNotEmpty) {
          widget.exercise!.sets.last.restAfterSet = actualRestTime;
        }
      }
    }

    // Play a sound or vibrate here if desired

    // Tell the manager this timer is complete
    _timerManager._timerCompleted(this);
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    if (_timerStarted) {
      _timer.cancel();
    }

    // Remove from queue if being disposed
    _timerManager._pendingTimers.remove(this);

    // Clear as active timer if being disposed
    if (_timerManager._activeTimerState == this) {
      _timerManager._activeTimerState = null;
      _timerManager._processNextTimerInQueue();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress only if timer has started
    double progress =
        _timerStarted ? (_elapsedSeconds / widget.restDuration) : 0.0;
    bool isOvertime = progress >= 1.0;
    bool isPending = !_timerStarted;

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
          Container(width: double.infinity),

          // Progress bar fill
          FractionallySizedBox(
            widthFactor: progress > 1.0 ? 1.0 : progress,
            child: Container(
              color: isOvertime
                  ? Theme.of(context).colorScheme.tertiaryFixed
                  : Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          // Center controls
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCenterControl(isPending),
              ],
            ),
          ),

          // Timer display
          if (_timerStarted)
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  formatTime(_elapsedSeconds),
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

  Widget _buildCenterControl(bool isPending) {
    if (isPending) {
      return const Text(
        "Waiting...",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
      );
    } else {
      return IconButton(
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
      );
    }
  }

  String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString()}:${secs.toString().padLeft(2, '0')}';
  }
}

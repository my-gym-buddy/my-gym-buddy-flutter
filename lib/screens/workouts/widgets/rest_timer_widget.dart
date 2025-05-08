import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';

/// Singleton manager to ensure only one timer runs at a time
class RestTimerManager {
  static final RestTimerManager _instance = RestTimerManager._internal();
  factory RestTimerManager() => _instance;
  RestTimerManager._internal();

  _RestTimerWidgetState? _activeTimerState;
  final List<_RestTimerWidgetState> _pendingTimers = [];
  bool _isProcessingQueue = false;

  void _registerTimer(_RestTimerWidgetState timerState) {
    // If there's an active timer, finish it immediately
    if (_activeTimerState != null) {
      _activeTimerState!._forceComplete();
    }
    
    // Make the new timer active
    _activeTimerState = timerState;
    timerState._startTimerIfNotStarted();
  }

  void _timerCompleted(_RestTimerWidgetState timerState) {
    if (_activeTimerState == timerState) {
      _activeTimerState = null;
      Future.delayed(const Duration(milliseconds: 50), _processNextTimerInQueue);
    }
  }

  void _processNextTimerInQueue() {
    if (_pendingTimers.isEmpty || _isProcessingQueue) return;

    _isProcessingQueue = true;
    // Remove unnecessary delay
    if (_pendingTimers.isNotEmpty) {
      final nextTimer = _pendingTimers.removeAt(0);
      _activeTimerState = nextTimer;
      nextTimer._startTimerIfNotStarted();
    }
    _isProcessingQueue = false;
  }
  
  void _removeTimer(_RestTimerWidgetState timerState) {
    _pendingTimers.remove(timerState);
    if (_activeTimerState == timerState) {
      _activeTimerState = null;
      _processNextTimerInQueue();
    }
  }
}

class RestTimerWidget extends StatefulWidget {
  final int restDuration; // in seconds
  final VoidCallback? onComplete;
  final Exercise? exercise;
  final bool isBetweenSets;
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
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  final _timerManager = RestTimerManager();
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timerManager._registerTimer(this);
    });
  }

  void _startTimerIfNotStarted() {
    if (_timerStarted) return;
    
    setState(() {
      _timerStarted = true;
      _isRunning = true;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isRunning) {
          _elapsedSeconds++;
          if (_elapsedSeconds == widget.restDuration) {
            _onTimerComplete();
          }
        }
      });
    });
  }

  // Centralized method to update rest time values
  void _updateRestTimeValues() {
    if (widget.exercise == null) return;
    
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

  void _pauseTimer() {
    // Cancel the timer when pausing
    _timer.cancel();
    
    setState(() {
      _isRunning = false;
      _updateRestTimeValues();
    });
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
    });
    
    // Always create a new timer when resuming
    _startTimer();
    
    // Don't register as a new timer, just make this the active timer
    if (_timerManager._activeTimerState != this) {
      // If there's another active timer, force complete it
      if (_timerManager._activeTimerState != null) {
        _timerManager._activeTimerState!._forceComplete();
      }
      _timerManager._activeTimerState = this;
    }
  }

  void _onTimerComplete() {
    setState(() {
      // We still want to update the rest time values
      _updateRestTimeValues();
    });
    
    // Notify manager timer has completed, but don't stop running
    Future.delayed(const Duration(milliseconds: 300), () {
      _timerManager._timerCompleted(this);
      
      // Only call onComplete if this is not the "rest after set" timer (which would affect the next set)
      if (widget.isBetweenSets || widget.exercise == null) {
        widget.onComplete?.call();
      }
    });
  }

  void _forceComplete() {
    if (_timerStarted) {
      _timer.cancel();
      
      // Ensure we update the UI state before proceeding
      setState(() {
        _isRunning = false;
        _elapsedSeconds = widget.restDuration; // Force elapsed time to match duration
      });
      
      _updateRestTimeValues();
      
      // Add delay to ensure UI updates before proceeding
      Future.delayed(const Duration(milliseconds: 200), () {
        _timerManager._timerCompleted(this);
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    if (_timerStarted) {
      _timer.cancel();
    }
    
    _timerManager._removeTimer(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _timerStarted ? (_elapsedSeconds / widget.restDuration) : 0.0;
    // Ensure progress is never negative
    progress = progress < 0.0 ? 0.0 : progress;
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
          Container(width: double.infinity), // Background
          
          // Progress bar
          FractionallySizedBox(
            widthFactor: progress > 1.0 ? 1.0 : (progress < 0.0 ? 0.0 : progress),
            child: Container(
              color: isOvertime
                  ? Theme.of(context).colorScheme.tertiaryFixed
                  : Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          // Controls
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
                  _formatTime(_elapsedSeconds),
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
    } 
    
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
      onPressed: _isRunning ? _pauseTimer : _resumeTimer,
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString()}:${secs.toString().padLeft(2, '0')}';
  }
}

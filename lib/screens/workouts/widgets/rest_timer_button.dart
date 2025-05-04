import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_buddy_app/models/exercise.dart';

class RestTimerButton extends StatefulWidget {
  final Exercise exercise;
  final Function(Exercise) onRestTimeUpdated;

  const RestTimerButton({
    Key? key, 
    required this.exercise, 
    required this.onRestTimeUpdated,
  }) : super(key: key);

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
    final bool hasMultipleSets = widget.exercise.sets != null && 
                                widget.exercise.sets!.length > 1;
    
    int betweenSetsMinutes = 0;
    int betweenSetsSeconds = 0;
    int afterSetMinutes = 0;
    int afterSetSeconds = 0;
    
    // Initialize with existing values if any
    if (widget.exercise.restBetweenSets != null) {
      betweenSetsMinutes = widget.exercise.restBetweenSets! ~/ 60;
      betweenSetsSeconds = widget.exercise.restBetweenSets! % 60;
    }
    
    if (widget.exercise.restAfterSet != null) {
      afterSetMinutes = widget.exercise.restAfterSet! ~/ 60;
      afterSetSeconds = widget.exercise.restAfterSet! % 60;
    }

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
                Center(
                  child: Text(
                    widget.exercise.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Only show rest between sets for multiple sets
                if (hasMultipleSets) ...[
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
                          child: CupertinoPicker(
                            itemExtent: 32,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                betweenSetsMinutes = index;
                              });
                            },
                            scrollController: FixedExtentScrollController(
                              initialItem: betweenSetsMinutes,
                            ),
                            children: List.generate(60, (index) {
                              return Center(child: Text('$index min'));
                            }),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 32,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                betweenSetsSeconds = index;
                              });
                            },
                            scrollController: FixedExtentScrollController(
                              initialItem: betweenSetsSeconds,
                            ),
                            children: List.generate(60, (index) {
                              return Center(child: Text('$index sec'));
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
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
                        child: CupertinoPicker(
                          itemExtent: 32,
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              afterSetMinutes = index;
                            });
                          },
                          scrollController: FixedExtentScrollController(
                            initialItem: afterSetMinutes,
                          ),
                          children: List.generate(60, (index) {
                            return Center(child: Text('$index min'));
                          }),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 32,
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              afterSetSeconds = index;
                            });
                          },
                          scrollController: FixedExtentScrollController(
                            initialItem: afterSetSeconds,
                          ),
                          children: List.generate(60, (index) {
                            return Center(child: Text('$index sec'));
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Calculate rest times in seconds
                        final int? betweenSetsTotal = hasMultipleSets ? 
                          betweenSetsMinutes * 60 + betweenSetsSeconds : null;
                        
                        final int afterSetTotal = 
                          afterSetMinutes * 60 + afterSetSeconds;
                        
                        // Update exercise
                        widget.exercise.restBetweenSets = 
                          hasMultipleSets && betweenSetsTotal! > 0 ? betweenSetsTotal : null;
                        
                        widget.exercise.restAfterSet = 
                          afterSetTotal > 0 ? afterSetTotal : null;
                        
                        // Notify parent about changes
                        widget.onRestTimeUpdated(widget.exercise);
                        
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
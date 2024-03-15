import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/models/workout.dart';
import 'package:share_plus/share_plus.dart';

class Helper {
  static final Helper _helper = Helper._internal();
  factory Helper() {
    return _helper;
  }
  Helper._internal();

  static double getWeightInCorrectUnit(double weight) {
    if (Config.unit == 'imperial') {
      // only 2 decimal places
      return (weight * 2.20462);
    }

    return weight;
  }

  static double convertToKg(double weight) {
    if (Config.unit == 'imperial') {
      return weight / 2.20462;
    }

    return weight;
  }

  static String prettyTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${hours}h ${minutes.toString().padLeft(2, '0')}m ${remainingSeconds.toString().padLeft(2, '0')}s';
  }

  static double calculateTotalWeightLifted(Workout workout) {
    double totalWeightLifted = 0;

    for (var exercise in workout.exercises!) {
      for (var set in exercise.sets) {
        totalWeightLifted += set.weight * set.reps;
      }
    }

    return totalWeightLifted;
  }

  static String workoutExercisesToText(Workout workout) {
    String exercisesText = 'Exercises:\n';

    for (var exercise in workout.exercises!) {
      exercisesText += '${exercise.name}\n';

      for (var set in exercise.sets) {
        exercisesText +=
            '${getWeightInCorrectUnit(convertToKg(set.weight)).toStringAsFixed(2)} ${Config.getUnitAbbreviation()} x ${set.reps} reps\n';
      }

      exercisesText += '\n';
    }

    return exercisesText;
  }

  static void shareWorkoutSummary(Workout workout, int duration) {
    // duration format - 00h 00m 00s
    Share.share(
        'Workout Name: ${workout.name}\nDate: ${DateTime.now().toString().substring(0, 10)}\nDuration: ${prettyTime(duration)}\nTotal Weight Lifted: ${getWeightInCorrectUnit(calculateTotalWeightLifted(workout)).toStringAsFixed(2)} ${Config.getUnitAbbreviation()}\n\n${workoutExercisesToText(workout)}\n\nTrack your workouts with Gym Buddy App:\nhttps://github.com/my-gym-buddy/my-gym-buddy-flutter');
  }
}

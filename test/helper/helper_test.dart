import 'package:flutter_test/flutter_test.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/rep_set.dart';
import 'package:gym_buddy_app/models/workout.dart';

/// Test suite for the Helper class utility functions
void main() {
  group('Helper Tests', () {
    setUp(() {
      // Reset to default state before each test
      Config.unit = 'metric';
    });

    group('Weight Conversion Tests', () {
      test('getWeightInCorrectUnit converts kg to lb correctly when unit is imperial', () {
        Config.unit = 'imperial';
        expect(Helper.getWeightInCorrectUnit(1.0), closeTo(2.20462, 0.00001));
        expect(Helper.getWeightInCorrectUnit(10.0), closeTo(22.0462, 0.00001));
      });

      test('getWeightInCorrectUnit returns same value when unit is metric', () {
        Config.unit = 'metric';
        expect(Helper.getWeightInCorrectUnit(1.0), 1.0);
        expect(Helper.getWeightInCorrectUnit(10.0), 10.0);
      });

      test('convertToKg converts lb to kg correctly when unit is imperial', () {
        Config.unit = 'imperial';
        expect(Helper.convertToKg(2.20462), closeTo(1.0, 0.00001));
        expect(Helper.convertToKg(22.0462), closeTo(10.0, 0.00001));
      });

      test('convertToKg returns same value when unit is metric', () {
        Config.unit = 'metric';
        expect(Helper.convertToKg(1.0), 1.0);
        expect(Helper.convertToKg(10.0), 10.0);
      });
    });

    group('Time Formatting Tests', () {
      test('prettyTime formats seconds correctly', () {
        expect(Helper.prettyTime(3661), '1h 01m 01s');
        expect(Helper.prettyTime(7323), '2h 02m 03s');
        expect(Helper.prettyTime(59), '0h 00m 59s');
      });
    });

    group('Workout Calculation Tests', () {
      test('calculateTotalWeightLifted sums up all weights correctly', () {
        final workout = Workout(
          name: 'Test Workout',
          exercises: [
            Exercise(
              name: 'Exercise 1',
              sets: [
                RepSet(weight: 10.0, reps: 5),
                RepSet(weight: 20.0, reps: 3),
              ],
            ),
            Exercise(
              name: 'Exercise 2',
              sets: [
                RepSet(weight: 15.0, reps: 4),
              ],
            ),
          ],
        );

        // (10 * 5) + (20 * 3) + (15 * 4) = 50 + 60 + 60 = 170
        expect(Helper.calculateTotalWeightLifted(workout), 170.0);
      });
    });

    group('Text Formatting Tests', () {
      test('workoutExercisesToText formats workout details correctly', () {
        Config.unit = 'metric';
        final workout = Workout(
          name: 'Test Workout',
          exercises: [
            Exercise(
              name: 'Exercise 1',
              sets: [
                RepSet(weight: 10.0, reps: 5),
              ],
            ),
          ],
        );

        const expected = 'Exercises:\nExercise 1\n10.00 kg x 5 reps\n\n';
        expect(Helper.workoutExercisesToText(workout), expected);
      });
    });
  });
} 